import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:rental_admin/core/services/google_places_service.dart';

class PropertyPhotoSearchService {
  /// Makes a Places API Text Search with strict location bias and field masks
  static Future<Map<String, dynamic>> searchExactPlace({
    required String propertyName,
    required String address,
    required double lat,
    required double lng,
  }) async {
    String baseUrl = 'https://places.googleapis.com';
    if (kIsWeb && kReleaseMode) baseUrl = '/api/google-places';

    // Extract a locality hint from the address (e.g. first two parts)
    final parts = address.split(',');
    String localityHint = '';
    if (parts.isNotEmpty) {
      localityHint = parts.take(2).join(', ').trim();
    }
    
    // Use the full property name and locality hint for a highly accurate search.
    final query = localityHint.isNotEmpty ? '$propertyName $localityHint'.trim() : propertyName.trim();

    final payload = {
      "textQuery": query,
      "locationBias": {
        "circle": {
          "center": {
            "latitude": lat,
            "longitude": lng
          },
          "radius": 500.0 // 500m radius to handle slightly inaccurate pins
        }
      }
    };

    int retries = 0;
    while (retries < 2) {
      final apiKey = GooglePlacesService.activeApiKey;
      final url = Uri.parse('$baseUrl/v1/places:searchText?key=$apiKey');
      final headers = {
        'Content-Type': 'application/json',
        'X-Goog-FieldMask': 'places.id,places.displayName,places.formattedAddress,places.location,places.photos,places.types'
      };

      try {
        final response = await http.post(url, headers: headers, body: json.encode(payload));
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final places = data['places'] as List<dynamic>? ?? [];
          return _scoreAndSelectBestCandidate(places, propertyName, address, lat, lng, apiKey);
        } else if (response.statusCode == 429) {
          // Rate Limit Hit
          if (retries == 0) {
            GooglePlacesService.switchKey();
            retries++;
            // Respect basic backoff
            await Future.delayed(const Duration(milliseconds: 1500));
            continue;
          }
          return _buildErrorResult(429, 'Google rate/quota limit hit on both keys. Both keys are rate-limited.');
        } else if (response.statusCode == 403) {
          return _buildErrorResult(403, 'Key rejected: Places API (New) may not be enabled or restricted.');
        } else if (response.statusCode == 400) {
          return _buildErrorResult(400, 'Bad request: likely a field-mask problem. ${response.body}');
        } else {
          return _buildErrorResult(response.statusCode, 'Google API Error: ${response.body}');
        }
      } catch (e) {
        return _buildErrorResult(500, 'Network or proxy error: $e');
      }
    }
    return _buildErrorResult(500, 'Unknown failure during search');
  }

  /// Downloads photo bytes. Uses same proxy pattern.
  static Future<Map<String, dynamic>> fetchPhotoBytes(String photoName, String apiKey) async {
    String baseUrl = 'https://places.googleapis.com';
    if (kIsWeb && kReleaseMode) baseUrl = '/api/google-places';

    int retries = 0;
    while (retries < 2) {
      final url = Uri.parse('$baseUrl/v1/$photoName/media?maxWidthPx=1200&key=$apiKey');
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          return {'success': true, 'bytes': response.bodyBytes, 'status': 200};
        } else if (response.statusCode == 429) {
          if (retries == 0) {
            GooglePlacesService.switchKey(); // Try to switch key, though photoName url also has key inside sometimes it might fail if we can't swap the url param, but we pass apiKey.
            retries++;
            await Future.delayed(const Duration(milliseconds: 1000));
            continue;
          }
          return {'success': false, 'error': 'Rate limited', 'status': 429};
        } else if (response.statusCode == 404) {
           return {'success': false, 'error': 'Photo not found or expired', 'status': 404};
        }
        return {'success': false, 'error': 'Failed with ${response.statusCode}', 'status': response.statusCode};
      } catch (e) {
        return {'success': false, 'error': 'Network error: $e', 'status': 500};
      }
    }
    return {'success': false, 'error': 'Retries exhausted', 'status': 500};
  }

  // Scoring Logic
  static Map<String, dynamic> _scoreAndSelectBestCandidate(List<dynamic> candidates, String pName, String pAddress, double pLat, double pLng, String activeKey) {
    if (candidates.isEmpty) {
      return {'status': 'no_match', 'message': 'No match on Google Maps.'};
    }

    final targetPoint = LatLng(pLat, pLng);
    List<Map<String, dynamic>> scoredCandidates = [];

    for (var c in candidates) {
      final String name = c['displayName']?['text'] ?? '';
      final loc = c['location'];
      double lat = (loc?['latitude'] as num?)?.toDouble() ?? 0.0;
      double lng = (loc?['longitude'] as num?)?.toDouble() ?? 0.0;
      final types = c['types'] as List<dynamic>? ?? [];

      // 1. Distance
      final dist = const Distance().as(LengthUnit.Meter, targetPoint, LatLng(lat, lng));
      
      // Reject if too far (allow up to 600m to handle inaccurate pins)
      if (dist > 600) continue; 

      // 2. Name Similarity (very basic fuzzy)
      final n1Words = pName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), '').split(RegExp(r'\s+'));
      final n2Words = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), '').split(RegExp(r'\s+'));
      
      final fillers = {'hostel', 'pg', 'boys', 'girls', 'mens', 'ladies', 'rooms', 'hotel', 'lodge', 'the', 'and'};
      final n1Sig = n1Words.where((w) => w.isNotEmpty && !fillers.contains(w)).toList();
      final n2Sig = n2Words.where((w) => w.isNotEmpty && !fillers.contains(w)).toList();

      bool nameMatch = false;
      final n1 = pName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      final n2 = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

      if (n1.isNotEmpty && n2.isNotEmpty && (n1.contains(n2) || n2.contains(n1))) {
        nameMatch = true;
      } else if (n1Sig.isNotEmpty && n2Sig.isNotEmpty) {
        for (var w in n1Sig) {
          if (n2Sig.contains(w)) {
             nameMatch = true;
             break;
          }
        }
      }

      // 3. Type Penalty
      bool hasGoodType = types.any((t) => t.toString().contains('lodging') || t.toString().contains('hostel') || t.toString().contains('room'));
      bool isBadType = types.any((t) => t.toString().contains('restaurant') || t.toString().contains('store'));

      double score = 100.0;
      if (dist <= 50) score += 50;
      else if (dist <= 150) score += 20;
      else score -= 30;

      if (nameMatch) score += 50;
      else score -= 40; // Penalize if the name doesn't match at all

      if (hasGoodType) score += 20;
      if (isBadType) score -= 40;
      
      // If it's a generic street address (no name match, not a lodging type), heavy penalty
      if (!nameMatch && !hasGoodType) {
        score -= 100;
      }

      scoredCandidates.add({
        'candidate': c,
        'score': score,
        'distance': dist,
      });
    }

    if (scoredCandidates.isEmpty) {
      return {'status': 'no_match', 'message': 'Candidates found but all rejected (too far or bad type).'};
    }

    scoredCandidates.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
    final best = scoredCandidates.first;

    // Determine status
    if (scoredCandidates.length == 1 && best['score'] > 80) {
      return _formatSuccessPayload('high_confidence', best, activeKey);
    } else if (scoredCandidates.length > 1 && (best['score'] - scoredCandidates[1]['score']) < 30) {
      return {
        'status': 'ambiguous',
        'message': 'Needs match confirmation',
        'candidates': scoredCandidates.map((e) => _formatCandidateData(e['candidate'], e['distance'], activeKey)).toList(),
      };
    } else if (best['score'] > 70) {
       return _formatSuccessPayload('high_confidence', best, activeKey);
    } else {
      return {
        'status': 'ambiguous',
        'message': 'Needs match confirmation (low confidence)',
        'candidates': scoredCandidates.map((e) => _formatCandidateData(e['candidate'], e['distance'], activeKey)).toList(),
      };
    }
  }

  static Map<String, dynamic> _formatSuccessPayload(String status, Map<String, dynamic> scoredCandidate, String activeKey) {
    final c = scoredCandidate['candidate'];
    final photos = c['photos'] as List<dynamic>? ?? [];
    return {
      'status': status,
      'place_id': c['id'],
      'name': c['displayName']?['text'] ?? 'Unknown',
      'address': c['formattedAddress'] ?? '',
      'distance': scoredCandidate['distance'],
      'photos_count': photos.length,
      'photos': photos.map((p) => {
        'name': p['name'], // resource name
        'author': p['authorAttributions'] != null && (p['authorAttributions'] as List).isNotEmpty 
            ? p['authorAttributions'][0]['displayName'] : 'Google Maps User',
        'author_uri': p['authorAttributions'] != null && (p['authorAttributions'] as List).isNotEmpty 
            ? p['authorAttributions'][0]['uri'] : '',
      }).toList(),
      'key_used': activeKey,
    };
  }
  
  static Map<String, dynamic> _formatCandidateData(dynamic c, num distance, String activeKey) {
    final photos = c['photos'] as List<dynamic>? ?? [];
    return {
      'place_id': c['id'],
      'name': c['displayName']?['text'] ?? 'Unknown',
      'address': c['formattedAddress'] ?? '',
      'distance': distance,
      'photos_count': photos.length,
      'photos': photos.map((p) => {
        'name': p['name'],
        'author': p['authorAttributions'] != null && (p['authorAttributions'] as List).isNotEmpty 
            ? p['authorAttributions'][0]['displayName'] : 'Google Maps User',
        'author_uri': p['authorAttributions'] != null && (p['authorAttributions'] as List).isNotEmpty 
            ? p['authorAttributions'][0]['uri'] : '',
      }).toList(),
      'key_used': activeKey,
    };
  }

  static Map<String, dynamic> _buildErrorResult(int code, String msg) {
    return {'status': 'error', 'code': code, 'message': msg};
  }
}

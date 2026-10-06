import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:rental_admin/app/config/env.dart';

class GooglePlaceModel {
  final String id;
  final String title;
  final String address;
  final String? phoneNumber;
  final double lat;
  final double lng;
  final List<String> imageUrls;
  
  GooglePlaceModel({
    required this.id,
    required this.title,
    required this.address,
    this.phoneNumber,
    required this.lat,
    required this.lng,
    required this.imageUrls,
  });

  factory GooglePlaceModel.fromJson(Map<String, dynamic> json) {
    // Extract basic fields (New API format)
    final String id = json['id'] ?? '';
    final String title = json['displayName']?['text'] ?? 'Unknown PG';
    final String address = json['formattedAddress'] ?? '';
    final String? phoneNumber = json['internationalPhoneNumber'] ?? json['nationalPhoneNumber'];
    final double lat = json['location']?['latitude'] ?? 0.0;
    final double lng = json['location']?['longitude'] ?? 0.0;

    // Extract photos using New API photo reference
    final List<String> imageUrls = [];
    if (json['photos'] != null) {
      final photos = json['photos'] as List;
      for (var p in photos) {
        final photoName = p['name']; // e.g. places/123/photos/456
        if (photoName != null) {
          final apiKey = GooglePlacesService.activeApiKey;
          // Direct New API media URL. In production, use Vercel proxy.
          String baseUrl = 'https://places.googleapis.com';
          if (kIsWeb && kReleaseMode) baseUrl = '/api/google-places';
          final url = '$baseUrl/v1/$photoName/media?maxHeightPx=800&maxWidthPx=800&key=$apiKey';
          imageUrls.add(url);
        }
      }
    }

    return GooglePlaceModel(
      id: id,
      title: title,
      address: address,
      phoneNumber: phoneNumber, // Available directly in New API
      lat: lat,
      lng: lng,
      imageUrls: imageUrls,
    );
  }
}

class GooglePlacesService {
  static int _currentKeyIndex = 0;
  
  static String get activeApiKey {
    final k1 = Env.googleMapsApiKey;
    final k2 = Env.googleMapsApiKey2;
    // Fallback if one is empty
    if (_currentKeyIndex == 0) return k1.isNotEmpty ? k1 : k2;
    return k2.isNotEmpty ? k2 : k1;
  }
  
  static void switchKey() {
    _currentKeyIndex = _currentKeyIndex == 0 ? 1 : 0;
    print('Switched to Google Maps API Key $_currentKeyIndex due to Quota Limit');
  }
  /// Get city/area autocomplete suggestions
  static Future<List<String>> getCitySuggestions(String query) async {
    if (query.isEmpty) return [];
    
    String baseUrl = 'https://places.googleapis.com';
    if (kIsWeb && kReleaseMode) baseUrl = '/api/google-places';
    
    final url = Uri.parse('$baseUrl/v1/places:autocomplete?key=$activeApiKey');
    final payload = {
      "input": query,
      "includedPrimaryTypes": ["locality", "administrative_area_level_3"] // Can adjust if needed
    };

    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(url, headers: headers, body: jsonEncode(payload));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final suggestions = data['suggestions'] as List?;
        if (suggestions == null) return [];
        
        return suggestions.map((s) {
          final prediction = s['placePrediction'];
          return prediction['text']['text'] as String;
        }).toList();
      }
    } catch (e) {
      print('Autocomplete Error: $e');
    }
    return [];
  }

  /// Geocodes a city/area name into Lat/Lng using Places API (New)
  static Future<Map<String, double>?> getCoordinatesForCity(String cityName) async {
    String baseUrl = 'https://places.googleapis.com';
    if (kIsWeb && kReleaseMode) baseUrl = '/api/google-places';
    
    final payload = {
      "textQuery": cityName,
    };
    
    for (int retry = 0; retry < 2; retry++) {
      final url = Uri.parse('$baseUrl/v1/places:searchText?key=$activeApiKey');
      final headers = {
        'Content-Type': 'application/json',
        'X-Goog-FieldMask': 'places.location'
      };
      
      try {
        final response = await http.post(url, headers: headers, body: jsonEncode(payload));
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['places'] != null && (data['places'] as List).isNotEmpty) {
            final loc = data['places'][0]['location'];
            if (loc != null) {
              return {
                'lat': loc['latitude'],
                'lng': loc['longitude']
              };
            }
          }
          return null;
        } else if (response.statusCode == 429) {
          if (retry == 0) {
            switchKey();
            continue;
          }
          throw Exception('GOOGLE_QUOTA_EXCEEDED');
        } else {
          throw Exception('Places API Error ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        if (e.toString().contains('GOOGLE_QUOTA_EXCEEDED')) rethrow;
        print('Geocode exception: $e');
        rethrow;
      }
    }
    return null;
  }

  /// Deep Grid Search - Searches for PGs, Hostels, etc. around a central point
  /// Uses the Places API (New) text search
  static Future<List<GooglePlaceModel>> deepSearchProperties(double centerLat, double centerLng, {double radiusKm = 50}) async {
    List<GooglePlaceModel> allResults = [];
    
    // For a 50km deep search, we generate a tighter grid of coordinates.
    // 1 degree lat is approx 111km. 50km is approx 0.45 degrees.
    // We step by 0.1 degrees (~11km) to ensure overlapping dense coverage
    // and extract up to 20 results per small circle.
    
    List<Map<String, double>> gridPoints = [];
    double stepSize = 0.1; // 11km
    double maxDegreeDiff = (radiusKm / 111.0); // 0.45
    
    for (double lat = centerLat - maxDegreeDiff; lat <= centerLat + maxDegreeDiff; lat += stepSize) {
      for (double lng = centerLng - maxDegreeDiff; lng <= centerLng + maxDegreeDiff; lng += stepSize) {
        // Optimization: Only search grid points that are roughly within the circle
        final dist = const Distance().as(LengthUnit.Kilometer, LatLng(centerLat, centerLng), LatLng(lat, lng));
        if (dist <= radiusKm + 5) { // Add 5km buffer for grid overlap
          gridPoints.add({'lat': lat, 'lng': lng});
        }
      }
    }

    Set<String> uniqueIds = {}; // to avoid duplicates
    final centerPoint = LatLng(centerLat, centerLng);

    // Run searches in batches of 5 to avoid rate limiting and speed up
    for (int i = 0; i < gridPoints.length; i += 5) {
      final batch = gridPoints.sublist(i, i + 5 > gridPoints.length ? gridPoints.length : i + 5);
      final futures = batch.map((point) => _searchAtLocation(point['lat']!, point['lng']!));
      final batchResults = await Future.wait(futures);
      
      for (var results in batchResults) {
        for (var r in results) {
          if (!uniqueIds.contains(r.id)) {
            // STRICT FILTERING: Ensure the property is exactly within 50km
            final distToProp = const Distance().as(LengthUnit.Meter, centerPoint, LatLng(r.lat, r.lng));
            if (distToProp <= (radiusKm * 1000)) {
              uniqueIds.add(r.id);
              allResults.add(r);
            }
          }
        }
      }
    }

    return allResults;
  }

  static Future<List<GooglePlaceModel>> _searchAtLocation(double lat, double lng) async {
    String baseUrl = 'https://places.googleapis.com';
    if (kIsWeb && kReleaseMode) baseUrl = '/api/google-places';
    
    final payload = {
      // Expanded query to include everything the user asked for: lodges, hotels, dormitories, rooms, PGs, hostels, etc.
      "textQuery": "lodges OR hotels OR dormitories OR rental rooms OR PGs OR hostels OR guest houses",
      "locationBias": { 
        "circle": {
          "center": {
            "latitude": lat,
            "longitude": lng
          },
          "radius": 11000.0 // 11km radius per grid point
        }
      }
    };

    for (int retry = 0; retry < 2; retry++) {
      final url = Uri.parse('$baseUrl/v1/places:searchText?key=$activeApiKey');
      final headers = {
        'Content-Type': 'application/json',
        'X-Goog-FieldMask': 'places.id,places.displayName,places.formattedAddress,places.internationalPhoneNumber,places.nationalPhoneNumber,places.location,places.photos'
      };
      
      try {
        final response = await http.post(url, headers: headers, body: json.encode(payload));
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['places'] != null) {
            final placesList = data['places'] as List;
            return placesList.map((e) => GooglePlaceModel.fromJson(e)).toList();
          }
          return [];
        } else if (response.statusCode == 429) {
          if (retry == 0) {
            switchKey();
            continue;
          }
          throw Exception('GOOGLE_QUOTA_EXCEEDED');
        } else {
          print('Google Places Error: ${response.body}');
          return [];
        }
      } catch (e) {
        if (e.toString().contains('GOOGLE_QUOTA_EXCEEDED')) rethrow;
        print('Exception in Places Search: $e');
        rethrow;
      }
    }
    
    return [];
  }

  /// Fetch phone number using New API Place Details
  static Future<String?> getPlacePhoneNumber(String placeId) async {
    String baseUrl = 'https://places.googleapis.com';
    if (kIsWeb && kReleaseMode) baseUrl = '/api/google-places';
    
    for (int retry = 0; retry < 2; retry++) {
      final url = Uri.parse('$baseUrl/v1/places/$placeId?key=$activeApiKey');
      final headers = {
        'X-Goog-FieldMask': 'internationalPhoneNumber,nationalPhoneNumber'
      };
      
      try {
        final response = await http.get(url, headers: headers);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return data['internationalPhoneNumber'] ?? data['nationalPhoneNumber'];
        } else if (response.statusCode == 429) {
          if (retry == 0) {
            switchKey();
            continue;
          }
        }
      } catch (e) {
        print('Place details error: $e');
      }
      break;
    }
    return null;
  }
}

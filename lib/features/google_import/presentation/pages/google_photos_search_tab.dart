import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rental_admin/core/widgets/app_snackbar.dart';
import 'package:rental_admin/app/theme/app_theme.dart';
import 'package:rental/core/models/property_model.dart';
import 'package:rental_admin/core/services/property_photo_search_service.dart';
import 'package:image/image.dart' as img;
import 'package:rental_admin/core/services/google_places_service.dart';
import 'package:rental_admin/app/config/env.dart';
import 'package:http/http.dart' as http;

// --- BACKGROUND PROCESSING FUNCTION ---
class ProcessPhotoRequest {
  final Uint8List originalBytes;
  final Uint8List watermarkBytes;
  final String propertyId;
  final String photoName;
  final String author;
  final String authorUri;

  ProcessPhotoRequest({
    required this.originalBytes,
    required this.watermarkBytes,
    required this.propertyId,
    required this.photoName,
    required this.author,
    required this.authorUri,
  });
}

class ProcessPhotoResponse {
  final bool success;
  final Uint8List? processedBytes;
  final int? finalSizeKb;
  final String? error;
  final ProcessPhotoRequest request;

  ProcessPhotoResponse({
    required this.success,
    this.processedBytes,
    this.finalSizeKb,
    this.error,
    required this.request,
  });
}

Future<ProcessPhotoResponse> _processAndCompressImage(ProcessPhotoRequest req) async {
  try {
    img.Image? originalImage = img.decodeImage(req.originalBytes);
    final img.Image? watermarkImg = img.decodeImage(req.watermarkBytes);

    if (originalImage == null || watermarkImg == null) {
      return ProcessPhotoResponse(success: false, error: 'Failed to decode image', request: req);
    }

    // Resize image if it's too large to save memory during compression
    if (originalImage.width > 1200) {
      originalImage = img.copyResize(originalImage, width: 1200);
    }

    // Watermark (proportional size: 1/4 of width)
    img.Image resizedWatermark = img.copyResize(watermarkImg, width: originalImage.width ~/ 4);
    img.compositeImage(
      originalImage, 
      resizedWatermark, 
      dstX: originalImage.width - resizedWatermark.width - (originalImage.width ~/ 20), // proportional margin
      dstY: originalImage.height - resizedWatermark.height - (originalImage.height ~/ 20),
    );

    // Iterative Compression loop to reach ~30KB (30 * 1024 bytes)
    int targetBytes = 35 * 1024; // Slight buffer
    int minQuality = 30; // hard stop
    int currentQuality = 90;
    
    Uint8List? bestBytes;
    
    while (currentQuality >= minQuality) {
      final List<int> encoded = img.encodeJpg(originalImage, quality: currentQuality);
      bestBytes = Uint8List.fromList(encoded);
      if (bestBytes.length <= targetBytes) {
        break;
      }
      currentQuality -= 10;
    }

    return ProcessPhotoResponse(
      success: true,
      processedBytes: bestBytes,
      finalSizeKb: (bestBytes!.length / 1024).round(),
      request: req,
    );
  } catch (e) {
    return ProcessPhotoResponse(success: false, error: e.toString(), request: req);
  }
}

// --- WIDGET ---

class GooglePhotosSearchTab extends StatefulWidget {
  final bool isDark;
  const GooglePhotosSearchTab({Key? key, this.isDark = true}) : super(key: key);

  @override
  State<GooglePhotosSearchTab> createState() => _GooglePhotosSearchTabState();
}

class _GooglePhotosSearchTabState extends State<GooglePhotosSearchTab> {
  final _supabase = Supabase.instance.client;
  
  // 0: Selection, 1: Review/Processing
  int _currentStep = 0; 

  // Data
  List<PropertyModel> _properties = [];
  bool _isLoading = true;
  
  // Selection
  Set<String> _selectedPropIds = {};

  // Status mapping: Property ID -> Status string
  Map<String, String> _propertyStatus = {};
  
  // Matched places cache: Property ID -> Google Place info
  Map<String, Map<String, dynamic>> _matchedPlaces = {};

  // Downloaded bytes cache: Property ID -> Photo resource Name -> bytes
  Map<String, Map<String, Uint8List>> _photoBytesCache = {};
  
  // Review state: Property ID -> list of kept photo resource names
  Map<String, List<Map<String, dynamic>>> _keptPhotos = {};

  // Processed state: Photo resource Name -> ProcessPhotoResponse
  Map<String, ProcessPhotoResponse> _processedPhotos = {};

  // Diagnostics / Activity Log
  List<Map<String, dynamic>> _activityLog = [];
  bool _showDiagnostics = false;

  // Counters
  int _apiCallsCount = 0;
  int _rateLimitsCount = 0;
  int _keySwitchesCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchPendingProperties();
  }

  void _logActivity(String endpoint, String propId, int status, String activeKey, {String? errorMsg, String? retryAfter}) {
    setState(() {
      _apiCallsCount++;
      if (status == 429) _rateLimitsCount++;
      _activityLog.insert(0, {
        'time': DateTime.now(),
        'endpoint': endpoint,
        'propId': propId,
        'status': status,
        'key': activeKey,
        'error': errorMsg,
        'retry_after': retryAfter,
      });
    });
  }

  Future<void> _fetchPendingProperties() async {
    setState(() => _isLoading = true);
    try {
      final res = await _supabase.from('properties').select('*, google_place_id').eq('status', 'pending');
      List<PropertyModel> props = [];
      Map<String, String> statusMap = {};
      
      for (var e in (res as List)) {
        final p = PropertyModel.fromJson(e);
        props.add(p);
        if (e['google_place_id'] != null) {
          statusMap[p.id!] = 'Match found (has Place ID)';
        } else {
          statusMap[p.id!] = 'Not searched';
        }
      }
      
      // Filter out those that already have submitted/pending photos from automation
      props = props.where((p) {
        bool hasGooglePhotos = p.suggestedPhotos.any((ph) => ph['source'] == 'google_maps_automation');
        return !hasGooglePhotos;
      }).toList();

      if (mounted) {
        setState(() {
          _properties = props;
          for (var p in props) {
             _propertyStatus[p.id!] = statusMap[p.id!] ?? 'Not searched';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Error loading properties: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _testApiConnection() async {
    final k1 = Env.googleMapsApiKey;
    final k2 = Env.googleMapsApiKey2;
    
    Future<void> testKey(String key, String label) async {
       try {
         final url = Uri.parse('https://places.googleapis.com/v1/places:searchText?key=$key');
         final res = await http.post(url, headers: {'X-Goog-FieldMask': 'places.id', 'Content-Type': 'application/json'}, body: '{"textQuery": "test"}');
         if (res.statusCode == 200) {
            AppSnackbar.success(context, '$label is Valid & Active');
         } else if (res.statusCode == 429) {
            AppSnackbar.error(context, '$label is Quota Exceeded (429)');
         } else if (res.statusCode == 403) {
            AppSnackbar.error(context, '$label is Permission Denied (403)');
         } else {
            AppSnackbar.error(context, '$label Error: ${res.statusCode}');
         }
       } catch(e) {
         AppSnackbar.error(context, '$label Network Error');
       }
    }
    await testKey(k1, 'Key 1');
    await testKey(k2, 'Key 2');
  }

  // --- Step A: Search Images ---
  Future<void> _startSearch() async {
    if (_selectedPropIds.isEmpty) return;
    
    // Batching to prevent self-inflicted rate limits
    final selectedProps = _properties.where((p) => _selectedPropIds.contains(p.id!)).toList();
    
    for (int i = 0; i < selectedProps.length; i += 3) {
      final batch = selectedProps.sublist(i, i + 3 > selectedProps.length ? selectedProps.length : i + 3);
      final futures = batch.map((p) => _searchSingleProperty(p));
      await Future.wait(futures);
      await Future.delayed(const Duration(milliseconds: 1000)); // Small delay between batches
    }

    if (mounted) {
       AppSnackbar.success(context, 'Search completed for ${_selectedPropIds.length} properties.');
    }
  }

  Future<void> _searchSingleProperty(PropertyModel p) async {
    try {
      if (_propertyStatus[p.id!] == 'Match found (has Place ID)') {
        // Already has a place ID, we can just use it (if we need place details, but we only need photos which requires search or details)
        // For now, if we already have it, we skip re-search unless forced.
        return;
      }

      setState(() {
        _propertyStatus[p.id!] = 'Searching...';
      });

      final activeKeyBefore = GooglePlacesService.activeApiKey;
      final res = await PropertyPhotoSearchService.searchExactPlace(
        propertyName: p.title,
        address: p.locationStr,
        lat: (p.latitude as num?)?.toDouble() ?? 0.0,
        lng: (p.longitude as num?)?.toDouble() ?? 0.0,
      );

    final activeKeyAfter = GooglePlacesService.activeApiKey;
    if (activeKeyBefore != activeKeyAfter) {
       _keySwitchesCount++;
       AppSnackbar.info(context, 'Switched to backup API key due to Quota Limit');
    }

    if (res['status'] == 'error') {
      _logActivity('searchText', p.id!, res['code'], activeKeyAfter, errorMsg: res['message']);
      setState(() => _propertyStatus[p.id!] = 'Error: ${res['message']}');
      
      if (res['code'] == 429) AppSnackbar.error(context, 'Quota Exceeded (429)');
      else if (res['code'] == 403) AppSnackbar.error(context, 'API Key Config Error (403)');
      
    } else if (res['status'] == 'no_match') {
       _logActivity('searchText', p.id!, 200, activeKeyAfter, errorMsg: 'Zero results');
       setState(() => _propertyStatus[p.id!] = 'No match');
    } else if (res['status'] == 'ambiguous') {
       _logActivity('searchText', p.id!, 200, activeKeyAfter);
       setState(() {
         _propertyStatus[p.id!] = 'Needs match confirmation';
         _matchedPlaces[p.id!] = res; // contains 'candidates'
       });
    } else if (res['status'] == 'high_confidence') {
       _logActivity('searchText', p.id!, 200, activeKeyAfter);
       int count = res['photos_count'];
       setState(() {
         _propertyStatus[p.id!] = count > 0 ? 'Match found ($count photos)' : 'No photos on Google';
         _matchedPlaces[p.id!] = res; // contains 'photos'
       });
       
       // Save the place ID to DB immediately so we don't lose it
       if (res['place_id'] != null) {
          _supabase.from('properties').update({'google_place_id': res['place_id']}).eq('id', p.id!);
       }
    }
    } catch (e) {
      if (mounted) {
        setState(() {
          _propertyStatus[p.id!] = 'Error: $e';
        });
      }
    }
  }

  // --- Step B: Fetch Photos for Review ---
  Future<void> _fetchPhotosForReview(String propId) async {
    final match = _matchedPlaces[propId];
    if (match == null || match['photos'] == null) return;
    
    List<dynamic> photos = match['photos'];
    _photoBytesCache[propId] ??= {};
    _keptPhotos[propId] ??= [];

    // Pre-populate kept photos with all if empty
    if (_keptPhotos[propId]!.isEmpty) {
       for (var ph in photos) _keptPhotos[propId]!.add(ph);
    }

    // Download in parallel with max 4
    List<Future> downloads = [];
    for (var ph in photos) {
      final photoName = ph['name'];
      if (_photoBytesCache[propId]!.containsKey(photoName)) continue; // already fetched

      downloads.add(() async {
         final apiKey = GooglePlacesService.activeApiKey;
         final res = await PropertyPhotoSearchService.fetchPhotoBytes(photoName, apiKey);
         _logActivity('photo/media', propId, res['status'], apiKey, errorMsg: res['error']);
         
         if (res['success']) {
           setState(() {
             _photoBytesCache[propId]![photoName] = res['bytes'];
           });
         } else {
           if (res['status'] == 429) AppSnackbar.error(context, 'Quota Limit hit while downloading photo');
         }
      }());

      if (downloads.length >= 4) {
        await Future.wait(downloads);
        downloads.clear();
      }
    }
    if (downloads.isNotEmpty) await Future.wait(downloads);
  }

  Future<void> _openReviewSession() async {
    final toReview = _properties.where((p) => _selectedPropIds.contains(p.id!) && _matchedPlaces.containsKey(p.id!) && _matchedPlaces[p.id!]!['photos'] != null).toList();
    
    if (toReview.isEmpty) {
      AppSnackbar.info(context, 'No selected properties have photos ready for review.');
      return;
    }

    setState(() => _currentStep = 1);
    
    // Lazy fetch bytes
    for (var p in toReview) {
       await _fetchPhotosForReview(p.id!);
    }
  }

  // --- Step C: Processing ---
  bool _isProcessing = false;
  Future<void> _processKeptPhotos() async {
    setState(() => _isProcessing = true);
    
    try {
      final ByteData watermarkData = await rootBundle.load('assets/images/watermark.png');
      final Uint8List watermarkBytes = watermarkData.buffer.asUint8List();

      final toProcess = _properties.where((p) => _selectedPropIds.contains(p.id!)).toList();
      
      for (var p in toProcess) {
        final kept = _keptPhotos[p.id!] ?? [];
        for (var ph in kept) {
           final pName = ph['name'];
           final originalBytes = _photoBytesCache[p.id!]?[pName];
           if (originalBytes != null && !_processedPhotos.containsKey(pName)) {
              
              final req = ProcessPhotoRequest(
                originalBytes: originalBytes,
                watermarkBytes: watermarkBytes,
                propertyId: p.id!,
                photoName: pName,
                author: ph['author'],
                authorUri: ph['author_uri'],
              );
              
              // Run in background isolate
              final res = await compute(_processAndCompressImage, req);
              setState(() {
                 _processedPhotos[pName] = res;
              });
           }
        }
      }
    } catch(e) {
       AppSnackbar.error(context, 'Processing Error: $e');
    }
    
    setState(() => _isProcessing = false);
  }

  // --- Step D: Upload ---
  bool _isUploading = false;
  Future<void> _uploadProcessedPhotos() async {
    setState(() => _isUploading = true);
    int uploadCount = 0;
    
    try {
      final toUploadProps = _properties.where((p) => _selectedPropIds.contains(p.id!)).toList();
      
      for (var p in toUploadProps) {
        final kept = _keptPhotos[p.id!] ?? [];
        List<Map<String, dynamic>> updatedSuggested = List<Map<String, dynamic>>.from(p.suggestedPhotos);
        bool hasUpdates = false;

        for (var ph in kept) {
          final pName = ph['name'];
          final processed = _processedPhotos[pName];
          
          if (processed != null && processed.success && processed.processedBytes != null) {
             // Check if already in suggested (by checking if URL exists, but we don't have URL yet. We can check by metadata/source id later. For now just append.)
             final fileName = 'google_automation/${DateTime.now().millisecondsSinceEpoch}_${pName.replaceAll('/', '_')}.jpg';
             
             await _supabase.storage.from('property_images').uploadBinary(fileName, processed.processedBytes!);
             final publicUrl = _supabase.storage.from('property_images').getPublicUrl(fileName);
             
             updatedSuggested.add({
                'url': publicUrl,
                'status': 'pending', // Pending Admin Approval pipeline
                'source': 'google_maps_automation',
                'author': processed.request.author,
                'author_uri': processed.request.authorUri,
                'google_photo_id': pName,
                'added_at': DateTime.now().toIso8601String(),
             });
             hasUpdates = true;
             uploadCount++;
          }
        }
        
        if (hasUpdates) {
          await _supabase.from('properties').update({'suggested_photos': updatedSuggested}).eq('id', p.id!);
          setState(() => _propertyStatus[p.id!] = 'Submitted');
        }
      }
      
      AppSnackbar.success(context, 'Uploaded $uploadCount photos successfully into pending queue!');
      setState(() {
        _currentStep = 0;
        _selectedPropIds.clear();
      });
      _fetchPendingProperties();
      
    } catch (e) {
      AppSnackbar.error(context, 'Upload failed: $e');
    }
    setState(() => _isUploading = false);
  }


  // --- UI BUILDING ---
  
  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = widget.isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = widget.isDark ? Colors.white12 : Colors.black12;
    final textColor = widget.isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 1,
        title: Text('Google Maps Automation - Photos Pipeline', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        actions: [
           IconButton(
             icon: const Icon(CupertinoIcons.bars),
             onPressed: () => setState(() => _showDiagnostics = !_showDiagnostics),
             tooltip: 'Diagnostics',
             color: textColor,
           ),
           TextButton.icon(
             icon: const Icon(CupertinoIcons.wifi),
             label: const Text('Test Connection'),
             onPressed: _testApiConnection,
           ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: _currentStep == 0 ? _buildSelectionScreen(textColor, cardColor, borderColor) : _buildReviewScreen(textColor, cardColor, borderColor),
          ),
          if (_showDiagnostics) _buildDiagnosticsPanel(cardColor, borderColor, textColor),
        ],
      ),
    );
  }

  Widget _buildSelectionScreen(Color textColor, Color cardColor, Color borderColor) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Step 1: Select Properties & Find Matches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(CupertinoIcons.search),
                    label: Text('Search ${_selectedPropIds.length} Selected'),
                    onPressed: _selectedPropIds.isEmpty ? null : _startSearch,
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryYellow, foregroundColor: Colors.black),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(CupertinoIcons.photo),
                    label: Text('Review Photos'),
                    onPressed: _selectedPropIds.isEmpty ? null : _openReviewSession,
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
              child: _isLoading ? const Center(child: CircularProgressIndicator()) : ListView.separated(
                itemCount: _properties.length,
                separatorBuilder: (_, __) => Divider(color: borderColor, height: 1),
                itemBuilder: (ctx, i) {
                   final p = _properties[i];
                   final status = _propertyStatus[p.id!] ?? 'Unknown';
                   final isSelected = _selectedPropIds.contains(p.id);
                   
                   return ListTile(
                     leading: Checkbox(
                       value: isSelected,
                       onChanged: (val) {
                          setState(() {
                             if (val == true) _selectedPropIds.add(p.id!);
                             else _selectedPropIds.remove(p.id!);
                          });
                       },
                     ),
                     title: Text(p.title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                     subtitle: Text(p.locationStr, style: TextStyle(color: textColor.withOpacity(0.6))),
                     trailing: _buildStatusChip(status),
                   );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg = Colors.grey;
    if (status.contains('Match found') || status.contains('Submitted')) bg = Colors.green;
    else if (status.contains('Searching')) bg = Colors.blue;
    else if (status.contains('Error') || status.contains('No match')) bg = Colors.red;
    else if (status.contains('Needs')) bg = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: bg)),
      child: Text(status, style: TextStyle(color: bg, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildReviewScreen(Color textColor, Color cardColor, Color borderColor) {
    final toReview = _properties.where((p) => _selectedPropIds.contains(p.id!) && _matchedPlaces.containsKey(p.id!) && _matchedPlaces[p.id!]!['photos'] != null).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(icon: Icon(CupertinoIcons.back, color: textColor), onPressed: () => setState(() => _currentStep = 0)),
              Text('Step 2 & 3: Review & Process', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(
                 icon: _isProcessing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(CupertinoIcons.wand_stars),
                 label: const Text('Process & Watermark Kept Photos'),
                 onPressed: _isProcessing ? null : _processKeptPhotos,
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                 icon: _isUploading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(CupertinoIcons.cloud_upload),
                 label: const Text('Submit to Pipeline'),
                 onPressed: _isUploading ? null : _uploadProcessedPhotos,
                 style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              )
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: toReview.length,
              itemBuilder: (ctx, i) {
                final p = toReview[i];
                final kept = _keptPhotos[p.id!] ?? [];
                final allPhotos = _matchedPlaces[p.id!]!['photos'] as List<dynamic>;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${kept.length} kept / ${allPhotos.length} total', style: TextStyle(color: textColor.withOpacity(0.6))),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 220,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: allPhotos.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (ctx, j) {
                             final ph = allPhotos[j];
                             final pName = ph['name'];
                             final isKept = kept.contains(ph);
                             final bytes = _photoBytesCache[p.id!]?[pName];
                             final processed = _processedPhotos[pName];

                             return Container(
                               width: 200,
                               decoration: BoxDecoration(
                                 border: Border.all(color: isKept ? Colors.green : Colors.transparent, width: 2),
                                 borderRadius: BorderRadius.circular(8),
                               ),
                               child: Stack(
                                 fit: StackFit.expand,
                                 children: [
                                   if (bytes == null)
                                      const Center(child: CircularProgressIndicator())
                                   else
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.memory(processed?.processedBytes ?? bytes, fit: BoxFit.cover),
                                      ),
                                      
                                   Positioned(
                                     bottom: 0, left: 0, right: 0,
                                     child: Container(
                                       color: Colors.black54,
                                       padding: const EdgeInsets.all(4),
                                       child: Column(
                                         children: [
                                           if (processed != null) Text('${processed.finalSizeKb} KB', style: const TextStyle(color: Colors.yellow, fontSize: 12, fontWeight: FontWeight.bold)),
                                           Row(
                                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                             children: [
                                                InkWell(
                                                  onTap: () {
                                                     setState(() {
                                                        if (isKept) _keptPhotos[p.id!]!.remove(ph);
                                                        else _keptPhotos[p.id!]!.add(ph);
                                                     });
                                                  },
                                                  child: Icon(isKept ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.delete_solid, color: isKept ? Colors.green : Colors.red),
                                                )
                                             ],
                                           ),
                                         ],
                                       )
                                     ),
                                   )
                                 ],
                               ),
                             );
                          },
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDiagnosticsPanel(Color cardColor, Color borderColor, Color textColor) {
    return Container(
      width: 350,
      decoration: BoxDecoration(border: Border(left: BorderSide(color: borderColor))),
      child: Column(
        children: [
           Container(
             padding: const EdgeInsets.all(16),
             color: cardColor,
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text('Diagnostics', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                 IconButton(icon: Icon(CupertinoIcons.clear, color: textColor), onPressed: () => setState(() => _showDiagnostics = false))
               ],
             ),
           ),
           Padding(
             padding: const EdgeInsets.all(16),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: [
                  _buildDiagStat('Calls', _apiCallsCount.toString(), Colors.blue),
                  _buildDiagStat('429s', _rateLimitsCount.toString(), Colors.red),
                  _buildDiagStat('Key Swaps', _keySwitchesCount.toString(), Colors.orange),
               ],
             ),
           ),
           Expanded(
             child: ListView.builder(
               itemCount: _activityLog.length,
               itemBuilder: (ctx, i) {
                  final log = _activityLog[i];
                  final isErr = log['status'] != 200;
                  return ListTile(
                    dense: true,
                    title: Text('${log['endpoint']} - HTTP ${log['status']}', style: TextStyle(color: isErr ? Colors.red : textColor, fontSize: 12, fontWeight: FontWeight.bold)),
                    subtitle: Text('Key: ${log['key']}\n${log['error'] ?? 'Success'}', style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 11)),
                  );
               },
             ),
           )
        ],
      ),
    );
  }
  
  Widget _buildDiagStat(String label, String val, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

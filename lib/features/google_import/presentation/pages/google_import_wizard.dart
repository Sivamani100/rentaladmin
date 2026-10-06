import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:rental_admin/core/services/google_places_service.dart';
import 'package:rental_admin/app/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rental_admin/core/widgets/app_snackbar.dart';

class GoogleImportWizard extends StatefulWidget {
  final bool isDark;
  
  const GoogleImportWizard({Key? key, this.isDark = true}) : super(key: key);

  @override
  State<GoogleImportWizard> createState() => _GoogleImportWizardState();
}

class _GoogleImportWizardState extends State<GoogleImportWizard> {
  final _supabase = Supabase.instance.client;
  int _currentStep = 0; // 0: Search, 1: Select, 2: Review & Submit
  
  // Screen 1 State
  final _cityController = TextEditingController();
  bool _isSearching = false;
  LatLng? _mapCenter;
  List<GooglePlaceModel> _foundPlaces = [];
  
  // Screen 2 State
  Set<String> _selectedPlaceIds = {};
  Set<String> _duplicatePlaceIds = {};
  
  // Screen 3 State
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = widget.isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = widget.isDark ? Colors.white12 : Colors.black12;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ]
        ),
        child: Column(
          children: [
            _buildHeader(cardColor, borderColor),
            Expanded(
              child: _buildCurrentScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color cardColor, Color borderColor) {
    final textColor = widget.isDark ? Colors.white : const Color(0xFF0F172A);
    final iconColor = widget.isDark ? Colors.white70 : Colors.black54;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(CupertinoIcons.map_pin_ellipse, color: AppTheme.primaryYellow, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Google Maps Deep Import',
                    style: TextStyle(fontFamily: 'ProximaNova', fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Search entire cities and auto-import properties into Supabase',
                    style: TextStyle(fontFamily: 'ProximaNova', fontSize: 13, color: iconColor),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentStep) {
      case 0: return _buildSearchScreen();
      case 1: return _buildSelectionScreen();
      case 2: return _buildReviewScreen();
      default: return const SizedBox.shrink();
    }
  }

  // ==========================================
  // SCREEN 1: Search & Map
  // ==========================================
  Widget _buildSearchScreen() {
    final textColor = widget.isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedTextColor = widget.isDark ? Colors.white70 : const Color(0xFF64748B);
    final inputBgColor = widget.isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9);
    final dropdownBgColor = widget.isDark ? const Color(0xFF2A303F) : Colors.white;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Step 1: Enter City Name for 50km Deep Search', style: TextStyle(color: mutedTextColor, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    if (textEditingValue.text.trim().isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return await GooglePlacesService.getCitySuggestions(textEditingValue.text);
                  },
                  onSelected: (String selection) {
                    _cityController.text = selection;
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    controller.addListener(() {
                      _cityController.text = controller.text;
                    });
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'e.g., Bangalore, India',
                        hintStyle: TextStyle(color: mutedTextColor.withOpacity(0.5)),
                        filled: true,
                        fillColor: inputBgColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                      onSubmitted: (_) {
                        onFieldSubmitted();
                        _performDeepSearch();
                      },
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 8.0,
                        color: dropdownBgColor,
                        borderRadius: BorderRadius.circular(8),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 250, maxWidth: 600),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final option = options.elementAt(index);
                              return InkWell(
                                onTap: () => onSelected(option),
                                child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: widget.isDark ? Colors.white10 : Colors.black12)),
                                  ),
                                  child: Text(option, style: TextStyle(color: textColor)),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _isSearching ? null : _performDeepSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryYellow,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: _isSearching ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) : const Icon(CupertinoIcons.search),
                label: Text(_isSearching ? 'Searching Deep...' : 'Deep Search (50km)'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _mapCenter == null
                  ? Container(
                      color: inputBgColor,
                      alignment: Alignment.center,
                      child: Text('Enter a city to view the map and start searching.', style: TextStyle(color: mutedTextColor)),
                    )
                  : FlutterMap(
                      options: MapOptions(
                        initialCenter: _mapCenter!,
                        initialZoom: 10,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        ),
                        MarkerLayer(
                          markers: _foundPlaces.map((p) => Marker(
                            point: LatLng(p.lat, p.lng),
                            child: const Icon(CupertinoIcons.location_solid, color: Colors.red, size: 30),
                          )).toList(),
                        )
                      ],
                    ),
            ),
          ),
          if (_foundPlaces.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Found ${_foundPlaces.length} properties in radius.', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Select all by default (excluding duplicates)
                      _selectedPlaceIds = _foundPlaces
                          .where((e) => !_duplicatePlaceIds.contains(e.id))
                          .map((e) => e.id)
                          .toSet();
                      _currentStep = 1;
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryYellow, foregroundColor: Colors.black),
                  child: const Text('Next: Review Data'),
                )
              ],
            )
          ]
        ],
      ),
    );
  }

  Future<void> _performDeepSearch() async {
    if (_cityController.text.trim().isEmpty) return;
    setState(() { _isSearching = true; _foundPlaces.clear(); });
    
    try {
      final coords = await GooglePlacesService.getCoordinatesForCity(_cityController.text.trim());
      if (coords != null) {
        setState(() => _mapCenter = LatLng(coords['lat']!, coords['lng']!));
        final places = await GooglePlacesService.deepSearchProperties(coords['lat']!, coords['lng']!);
        
        // CHECK FOR DUPLICATES IN SUPABASE
        final existingData = await _supabase.from('properties').select('title, latitude, longitude, owner_phone');
        _duplicatePlaceIds.clear();
        for (var p in places) {
          for (var dbProp in existingData) {
            bool nameMatch = dbProp['title'] == p.title;
            bool phoneMatch = p.phoneNumber != null && dbProp['owner_phone'] == p.phoneNumber && p.phoneNumber != 'N/A';
            bool latMatch = (dbProp['latitude'] as double?)?.toStringAsFixed(4) == p.lat.toStringAsFixed(4);
            bool lngMatch = (dbProp['longitude'] as double?)?.toStringAsFixed(4) == p.lng.toStringAsFixed(4);

            if ((latMatch && lngMatch) || phoneMatch || nameMatch) {
              _duplicatePlaceIds.add(p.id);
              break;
            }
          }
        }

        setState(() {
          _foundPlaces = places;
        });
      } else {
        if (mounted) AppSnackbar.error(context, 'Could not find coordinates for this city.');
      }
    } catch (e) {
      if (e.toString().contains('GOOGLE_QUOTA_EXCEEDED')) {
        if (mounted) AppSnackbar.error(context, 'Google API Quota Exceeded (100 limit reached). Please upgrade your Google Cloud billing or wait 24hrs.');
      } else {
        if (mounted) AppSnackbar.error(context, 'Error searching: $e');
      }
    }
    
    if (mounted) setState(() => _isSearching = false);
  }

  // ==========================================
  // SCREEN 2: Selection & Edit
  // ==========================================
  Widget _buildSelectionScreen() {
    final textColor = widget.isDark ? Colors.white : const Color(0xFF0F172A);
    final borderColor = widget.isDark ? Colors.white12 : Colors.black12;
    final headerBgColor = widget.isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              IconButton(icon: Icon(CupertinoIcons.back, color: textColor), onPressed: () => setState(() => _currentStep = 0)),
              Text('Step 2: Select Properties to Import', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: borderColor,
                ),
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(headerBgColor),
                  dataRowColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return AppTheme.primaryYellow.withOpacity(0.1);
                    }
                    return Colors.transparent;
                  }),
                  columns: [
                    DataColumn(label: Text('Property Name', style: TextStyle(color: textColor, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Address', style: TextStyle(color: textColor, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Phone', style: TextStyle(color: textColor, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Photos', style: TextStyle(color: textColor, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Coordinates', style: TextStyle(color: textColor, fontWeight: FontWeight.bold))),
                  ],
                  rows: _foundPlaces.map((place) {
                    final isDuplicate = _duplicatePlaceIds.contains(place.id);
                    final isSelected = _selectedPlaceIds.contains(place.id) && !isDuplicate;
                    return DataRow(
                      selected: isSelected,
                      onSelectChanged: isDuplicate ? null : (val) {
                        setState(() {
                          if (val == true) _selectedPlaceIds.add(place.id);
                          else _selectedPlaceIds.remove(place.id);
                        });
                      },
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              if (isDuplicate) 
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.red)),
                                  child: const Text('Duplicate', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              SizedBox(
                                width: isDuplicate ? 140 : 200,
                                child: Text(place.title, style: TextStyle(color: textColor, decoration: isDuplicate ? TextDecoration.lineThrough : null), overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          )
                        ),
                        DataCell(
                          SizedBox(
                            width: 250,
                            child: Text(place.address, style: TextStyle(color: textColor.withOpacity(0.7)), overflow: TextOverflow.ellipsis),
                          )
                        ),
                        DataCell(Text(place.phoneNumber ?? 'N/A', style: TextStyle(color: textColor.withOpacity(0.7)))),
                        DataCell(Text('${place.imageUrls.length} photos', style: TextStyle(color: textColor.withOpacity(0.7)))),
                        DataCell(Text('${place.lat.toStringAsFixed(4)}, ${place.lng.toStringAsFixed(4)}', style: TextStyle(color: textColor.withOpacity(0.7)))),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: borderColor))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_selectedPlaceIds.length} Selected', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: _selectedPlaceIds.isEmpty ? null : () => setState(() => _currentStep = 2),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryYellow, foregroundColor: Colors.black),
                child: const Text('Next: Final Review'),
              )
            ],
          ),
        )
      ],
    );
  }

  // ==========================================
  // SCREEN 3: Review & Submit
  // ==========================================
  Widget _buildReviewScreen() {
    final selectedPlaces = _foundPlaces.where((p) => _selectedPlaceIds.contains(p.id)).toList();
    final textColor = widget.isDark ? Colors.white : const Color(0xFF0F172A);
    final cardBgColor = widget.isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9);
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(icon: Icon(CupertinoIcons.back, color: textColor), onPressed: () => setState(() => _currentStep = 1)),
              Text('Step 3: Send to Live Database (Pending)', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cardBgColor, borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Database Import Settings', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('• These properties will be uploaded to Supabase immediately.', style: TextStyle(color: textColor.withOpacity(0.7))),
                Text('• They will be marked as Status: "pending" so live users won\'t see them yet.', style: TextStyle(color: textColor.withOpacity(0.7))),
                Text('• Missing data (Price, Deposit) will be set to defaults like "To be updated".', style: TextStyle(color: textColor.withOpacity(0.7))),
                Text('• You can edit them later in the admin panel and Approve them.', style: TextStyle(color: textColor.withOpacity(0.7))),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: _isSubmitting 
              ? Column(
                  children: [
                    const CircularProgressIndicator(color: AppTheme.primaryYellow),
                    const SizedBox(height: 16),
                    Text(_submissionStatus, style: TextStyle(color: textColor.withOpacity(0.7))),
                  ],
                )
              : ElevatedButton.icon(
                  onPressed: () => _submitToSupabase(selectedPlaces),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  ),
                  icon: const Icon(CupertinoIcons.cloud_upload),
                  label: Text('Push ${selectedPlaces.length} Properties to Supabase'),
                ),
          )
        ],
      ),
    );
  }

  String _submissionStatus = '';

  Future<void> _submitToSupabase(List<GooglePlaceModel> places) async {
    setState(() {
      _isSubmitting = true;
      _submissionStatus = 'Initializing import...';
    });
    
    try {
      final List<Map<String, dynamic>> rowsToInsert = [];
      
      int totalPhotos = places.fold(0, (sum, p) => sum + p.imageUrls.length);
      int processedPhotos = 0;

      for (int i = 0; i < places.length; i++) {
        final p = places[i];
        
        setState(() {
          _submissionStatus = 'Fetching phone numbers and migrating photos for property ${i+1}/${places.length}...\n($processedPhotos/$totalPhotos photos uploaded)';
        });
        
        // Fetch phone number individually to save API quota!
        final phoneNumber = await GooglePlacesService.getPlacePhoneNumber(p.id) ?? 'N/A';

        List<String> supabaseUrls = [];
        
        // Concurrently download and upload photos for this specific property
        final uploadTasks = p.imageUrls.map((googleUrl) async {
          try {
             // Fetch directly (requires Chrome web security disabled for local testing)
             final res = await http.get(Uri.parse(googleUrl));
             if (res.statusCode == 200) {
               final fileName = 'google_import/${DateTime.now().millisecondsSinceEpoch}_${p.id}_${supabaseUrls.length}.jpg';
               await _supabase.storage.from('property_images').uploadBinary(
                 fileName, 
                 res.bodyBytes,
                 fileOptions: const FileOptions(contentType: 'image/jpeg')
               );
               final publicUrl = _supabase.storage.from('property_images').getPublicUrl(fileName);
               return publicUrl;
             }
          } catch(e) {
             print('Photo error: $e');
          }
          return null;
        }).toList();

        final results = await Future.wait(uploadTasks);
        for (var url in results) {
          if (url != null) supabaseUrls.add(url);
          processedPhotos++;
        }

        String propertyType = 'PG / Hostel';
        final t = p.title.toLowerCase();
        if (t.contains('hotel') || t.contains('lodge')) propertyType = 'Hotel / Lodge';
        if (t.contains('room')) propertyType = 'Room';
        if (t.contains('dorm')) propertyType = 'Dormitory';

        rowsToInsert.add({
          'title': p.title,
          'price': 'To be updated',
          'location_str': p.address,
          'latitude': p.lat,
          'longitude': p.lng,
          'type': 'PG', 
          'bhk_type': 'N/A',
          'furnishing_status': 'Unfurnished',
          'tenant_preference': 'Any',
          'beds': '0',
          'baths': '0',
          'area': '0',
          'owner_phone': phoneNumber,
          'owner_whatsapp': phoneNumber,
          'is_available': true,
          'status': 'pending',
          'image_urls': supabaseUrls,
          'tags': [],
          'features': [],
          'description': 'Best $propertyType located at ${p.address}, situated near prime landmarks with easy access to all essential amenities. ${p.title} is a spacious and well-maintained property offering a comfortable living experience.',
          'security_deposit': '0',
          'maintenance_charges': '0',
          'parking_info': 'N/A',
          'suggested_photos': [],
        });
      }

      setState(() => _submissionStatus = 'Saving properties to database...');
      await _supabase.from('properties').insert(rowsToInsert);
      
      if (mounted) {
        AppSnackbar.success(context, 'Successfully pushed ${places.length} properties to Supabase! Check the Pending tab.');
        setState(() {
          _currentStep = 0;
          _foundPlaces = [];
          _selectedPlaceIds = {};
          _isSubmitting = false;
        });
      }
    } catch (e) {
      if (mounted) AppSnackbar.error(context, 'Error inserting to Supabase: $e');
    }
    
    if (mounted) setState(() => _isSubmitting = false);
  }
}

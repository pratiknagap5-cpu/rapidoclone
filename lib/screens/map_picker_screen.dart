import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';
import '../providers/app_providers.dart';

class MapPickerScreen extends ConsumerStatefulWidget {
  final String type; // 'pickup' or 'drop'
  
  const MapPickerScreen({super.key, required this.type});

  @override
  ConsumerState<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends ConsumerState<MapPickerScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  
  LatLng _center = const LatLng(19.0760, 72.8777); // Default Mumbai
  String _currentAddress = 'Loading...';
  bool _isMoving = false;
  List<LocationModel> _searchResults = [];
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  void _initLocation() async {
    // If we already have a location set for this type, use it
    LocationModel? existingLoc = widget.type == 'pickup' 
        ? ref.read(pickupLocationProvider) 
        : ref.read(dropLocationProvider);

    if (existingLoc != null) {
      setState(() {
        _center = LatLng(existingLoc.latitude, existingLoc.longitude);
        _currentAddress = existingLoc.address;
      });
      _mapController.move(_center, 15.0);
    } else {
      // Get current GPS
      final curr = ref.read(currentLocationProvider);
      if (curr != null) {
         setState(() {
          _center = LatLng(curr.latitude, curr.longitude);
          _currentAddress = curr.address;
        });
        _mapController.move(_center, 15.0);
      }
    }
  }

  void _onMapPositionChanged(MapPosition position, bool hasGesture) {
    if (position.center != null) {
      if (!_isMoving) {
        setState(() => _isMoving = true);
      }
    }
  }

  Future<void> _onMapIdle() async {
    setState(() => _isMoving = false);
    final center = _mapController.camera.center;
    
    setState(() => _currentAddress = 'Fetching address...');
    
    final address = await LocationService.getAddressFromCoordinates(
      center.latitude, center.longitude,
    );
    
    if (mounted) {
      setState(() {
        _center = center;
        _currentAddress = address;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.length < 3) {
        setState(() => _searchResults = []);
        return;
      }
      
      setState(() => _isSearching = true);
      final results = await LocationService.searchPlaces(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    });
  }

  void _confirmLocation() {
    final loc = LocationModel(
      latitude: _center.latitude,
      longitude: _center.longitude,
      address: _currentAddress,
    );

    if (widget.type == 'pickup') {
      ref.read(pickupLocationProvider.notifier).state = loc;
    } else {
      ref.read(dropLocationProvider.notifier).state = loc;
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == 'pickup' ? 'Select Pickup' : 'Select Drop';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 15.0,
              onPositionChanged: _onMapPositionChanged,
              onMapEvent: (event) {
                if (event.source == MapEventSource.dragEnd || 
                    event.source == MapEventSource.mapController) {
                  _onMapIdle();
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.rapidoapp',
              ),
            ],
          ),

          // Center Marker
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30), // adjust for pin visual center
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.translationValues(0, _isMoving ? -10 : 0, 0),
                child: Icon(
                  Icons.location_on,
                  color: widget.type == 'pickup' ? AppTheme.accentGreen : AppTheme.accentRed,
                  size: 48,
                ),
              ),
            ),
          ),

          // Search Box Overlay
          Positioned(
            top: 16, left: 16, right: 16,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search for building, area...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.textHint),
                      suffixIcon: _isSearching 
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchResults = []);
                                  },
                                )
                              : null,
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                  ),
                ),
                
                // Search Results
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      separatorBuilder: (c, i) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final place = _searchResults[index];
                        return ListTile(
                          leading: const Icon(Icons.place, color: AppTheme.textHint),
                          title: Text(
                            place.address,
                            style: GoogleFonts.inter(fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            _mapController.move(LatLng(place.latitude, place.longitude), 16.0);
                            setState(() {
                              _currentAddress = place.address;
                              _searchResults = [];
                              _searchController.clear();
                              FocusScope.of(context).unfocus();
                            });
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Bottom Confirm Action
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Location',
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textHint),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentAddress,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isMoving ? null : _confirmLocation,
                        child: const Text('Confirm Location'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // My Location FAB
          Positioned(
            bottom: 180, right: 16,
            child: FloatingActionButton(
              heroTag: 'myLocBtn',
              backgroundColor: Colors.white,
              onPressed: () async {
                final curr = ref.read(currentLocationProvider);
                if (curr != null) {
                  _mapController.move(LatLng(curr.latitude, curr.longitude), 15.0);
                }
              },
              child: const Icon(Icons.my_location, color: AppTheme.accentDark),
            ),
          ),
        ],
      ),
    );
  }
}

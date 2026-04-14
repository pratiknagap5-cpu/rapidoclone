import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/app_theme.dart';
import '../../models/ride_model.dart';
import '../../models/location_model.dart';
import '../../providers/app_providers.dart';
import '../../services/fare_service.dart';
import '../../services/location_service.dart';
import '../map_picker_screen.dart';
import '../ride_tracking_screen.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final MapController _mapController = MapController();

  void _openMapPicker(String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(type: type),
      ),
    );
  }

  void _bookRide() async {
    final pickup = ref.read(pickupLocationProvider);
    final drop = ref.read(dropLocationProvider);
    final rideType = ref.read(selectedRideTypeProvider);
    
    if (pickup == null || drop == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both locations')),
      );
      return;
    }

    // Show loading flow
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildBookingDialog(),
    );

    // Calculate details
    final distance = LocationService.calculateDistance(
      pickup.latitude, pickup.longitude,
      drop.latitude, drop.longitude,
    );
    final fare = FareService.calculateFare(distance, rideType);
    final duration = FareService.estimateTime(distance, rideType);

    // Create ride
    final rideId = const Uuid().v4();
    final newRide = RideModel(
      id: rideId,
      rideTypeIndex: rideType.index,
      rideStatusIndex: RideStatus.searching.index,
      pickupLat: pickup.latitude,
      pickupLng: pickup.longitude,
      pickupAddress: pickup.address,
      dropLat: drop.latitude,
      dropLng: drop.longitude,
      dropAddress: drop.address,
      distance: distance,
      duration: duration,
      fare: fare,
      createdAt: DateTime.now(),
    );

    ref.read(currentRideProvider.notifier).state = newRide;

    await Future.delayed(const Duration(seconds: 3));

    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context); // close dialog
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RideTrackingScreen(),
        ),
      );
    }
  }

  Widget _buildBookingDialog() {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 60, height: 60,
              child: const CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryYellow),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Finding Captains Nearby...',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.accentDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'We are searching for the best driver for you.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pickupLocation = ref.watch(pickupLocationProvider);
    final dropLocation = ref.watch(dropLocationProvider);
    final selectedRideType = ref.watch(selectedRideTypeProvider);
    final currentLocation = ref.watch(currentLocationProvider);
    
    // Auto-center map if locations exist
    if (pickupLocation != null && _mapController.camera.center.latitude == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
         _mapController.move(LatLng(pickupLocation.latitude, pickupLocation.longitude), 14.0);
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Map Preview Background
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.45,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: currentLocation != null 
                      ? LatLng(currentLocation.latitude, currentLocation.longitude)
                      : const LatLng(19.0760, 72.8777),
                  initialZoom: 14.0,
                  interactionOptions: const InteractionOptions(
                    enableMultiFingerGestureRace: false,
                    flags: ~InteractiveFlag.all, // Disable all gestures for preview
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.rapidoapp',
                  ),
                  MarkerLayer(
                    markers: [
                      if (pickupLocation != null)
                        Marker(
                          point: LatLng(pickupLocation.latitude, pickupLocation.longitude),
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_on, color: AppTheme.accentGreen, size: 36),
                        ),
                      if (dropLocation != null)
                        Marker(
                          point: LatLng(dropLocation.latitude, dropLocation.longitude),
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.place, color: AppTheme.accentRed, size: 36),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Top Gradient Overlay for Header
            Positioned(
              top: 0, left: 0, right: 0,
              height: 120,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Header Content
            Positioned(
              top: 16, left: 20, right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Row(
                      children: [
                         const Icon(Icons.two_wheeler, color: AppTheme.primaryYellow, size: 20),
                         const SizedBox(width: 8),
                         Text(
                           'Rapido',
                           style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16),
                         ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: const Icon(Icons.notifications_outlined, color: AppTheme.accentDark),
                  ),
                ],
              ),
            ),

            // Bottom Sheets Area
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7, // Prevent it from taking over the whole screen
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.divider,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // Location Inputs
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.divider),
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          color: AppTheme.surface,
                        ),
                        child: Column(
                          children: [
                            _buildLocationRow(
                              icon: Icons.circle,
                              color: AppTheme.accentGreen,
                              hint: 'Pickup Location',
                              location: pickupLocation,
                              onTap: () => _openMapPicker('pickup'),
                            ),
                            const Divider(height: 1, indent: 48, color: AppTheme.divider),
                            _buildLocationRow(
                              icon: Icons.square,
                              color: AppTheme.accentRed,
                              hint: 'Drop Location',
                              location: dropLocation,
                              onTap: () => _openMapPicker('drop'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
  
                      // Ride Types
                      if (dropLocation != null) ...[
                        Text(
                          'Available Rides',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accentDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 90,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildRideTypeCard(RideType.bike, 'Bike', Icons.two_wheeler, selectedRideType),
                              const SizedBox(width: 12),
                              _buildRideTypeCard(RideType.auto, 'Auto', Icons.electric_rickshaw, selectedRideType),
                              const SizedBox(width: 12),
                              _buildRideTypeCard(RideType.cab, 'Cab', Icons.local_taxi, selectedRideType),
                              const SizedBox(width: 12),
                              _buildRideTypeCard(RideType.premiumCab, 'Premium', Icons.directions_car, selectedRideType),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
  
                        // Fare Estimate & Book
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estimated Fare',
                                  style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                                ),
                                Text(
                                  '₹${FareService.calculateFare(LocationService.calculateDistance(pickupLocation!.latitude, pickupLocation.longitude, dropLocation.latitude, dropLocation.longitude), selectedRideType).toStringAsFixed(0)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.accentDark,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: _bookRide,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              ),
                              child: const Text('Book Now'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color color,
    required String hint,
    required LocationModel? location,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location?.address ?? hint,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: location != null ? FontWeight.w600 : FontWeight.w400,
                      color: location != null ? AppTheme.accentDark : AppTheme.textHint,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideTypeCard(RideType type, String name, IconData icon, RideType selectedType) {
    final isSelected = type == selectedType;
    return GestureDetector(
      onTap: () => ref.read(selectedRideTypeProvider.notifier).state = type,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryYellow.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isSelected ? AppTheme.primaryYellow : AppTheme.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppTheme.darkYellow : AppTheme.textSecondary,
            ),
            const Spacer(),
            Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppTheme.accentDark : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

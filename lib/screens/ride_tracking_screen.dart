import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/ride_model.dart';
import '../services/routing_service.dart';
import '../services/database_service.dart';
import '../providers/app_providers.dart';
import 'ride_summary_screen.dart';

class RideTrackingScreen extends ConsumerStatefulWidget {
  const RideTrackingScreen({super.key});

  @override
  ConsumerState<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends ConsumerState<RideTrackingScreen> {
  final MapController _mapController = MapController();
  List<LatLng> _routePoints = [];
  Timer? _simulationTimer;
  LatLng? _driverPos;
  int _currentPathIndex = 0;
  bool _isLoadingRoute = true;

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    final ride = ref.read(currentRideProvider);
    if (ride == null) return;

    final start = LatLng(ride.pickupLat, ride.pickupLng);
    final end = LatLng(ride.dropLat, ride.dropLng);

    final points = await RoutingService.getRoute(start, end);
    if (mounted) {
      setState(() {
        _routePoints = points;
        if (points.isNotEmpty) {
          _driverPos = points.first;
        } else {
           _driverPos = start;
        }
        _isLoadingRoute = false;
      });

      // Fit bounds
      if (points.isNotEmpty) {
        final bounds = LatLngBounds.fromPoints(points);
        Future.delayed(const Duration(milliseconds: 500), () {
           _mapController.fitCamera(
             CameraFit.bounds(
               bounds: bounds,
               padding: const EdgeInsets.all(50.0),
             ),
           );
        });
      }

      _startSimulation();
    }
  }

  void _startSimulation() {
    // Determine speed based on route length
    if (_routePoints.isEmpty) return;
    
    // Smooth, moderately fast simulation for demo
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_currentPathIndex < _routePoints.length - 1) {
        setState(() {
          _currentPathIndex++;
          _driverPos = _routePoints[_currentPathIndex];
        });

        // Update ride status based on progress
        final ride = ref.read(currentRideProvider);
        if (ride != null) {
          double progress = _currentPathIndex / _routePoints.length;
          RideStatus newStatus = ride.status;
          
          if (progress < 0.1 && ride.status == RideStatus.searching) {
            newStatus = RideStatus.accepted;
          } else if (progress >= 0.1 && progress <= 0.2 && ride.status == RideStatus.accepted) {
            newStatus = RideStatus.arrived;
          } else if (progress > 0.2 && ride.status != RideStatus.started && ride.status != RideStatus.completed) {
            newStatus = RideStatus.started;
          }

          if (newStatus != ride.status) {
            ride.status = newStatus;
            
            // Save to DB when started
            if (newStatus == RideStatus.started) {
              DatabaseService.saveRide(ride);
            }
            
            // Force redraw Provider
            ref.read(currentRideProvider.notifier).state = RideModel(
               id: ride.id,
               rideTypeIndex: ride.rideTypeIndex,
               rideStatusIndex: ride.rideStatusIndex,
               pickupLat: ride.pickupLat, pickupLng: ride.pickupLng, pickupAddress: ride.pickupAddress,
               dropLat: ride.dropLat, dropLng: ride.dropLng, dropAddress: ride.dropAddress,
               distance: ride.distance, duration: ride.duration, fare: ride.fare,
               createdAt: ride.createdAt,
            );
          }
        }
      } else {
        // Reached destination
        timer.cancel();
        _completeRide();
      }
    });
  }

  void _completeRide() async {
    final ride = ref.read(currentRideProvider);
    if (ride != null) {
      ride.status = RideStatus.completed;
      ride.completedAt = DateTime.now();
      await DatabaseService.saveRide(ride);
      
      if (mounted) {
         Navigator.pushReplacement(
           context,
           MaterialPageRoute(builder: (context) => const RideSummaryScreen()),
         );
      }
    }
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ride = ref.watch(currentRideProvider);
    if (ride == null) return const Scaffold();

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(ride.pickupLat, ride.pickupLng),
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.rapidoapp',
              ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: AppTheme.accentBlue,
                      strokeWidth: 4.0,
                    ),
                    // Traversed part
                    Polyline(
                      points: _routePoints.sublist(0, _currentPathIndex + 1),
                      color: AppTheme.accentDark,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(ride.pickupLat, ride.pickupLng),
                    width: 30, height: 30,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppTheme.accentGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(child: Icon(Icons.circle, color: Colors.white, size: 12)),
                    ),
                  ),
                  Marker(
                    point: LatLng(ride.dropLat, ride.dropLng),
                    width: 30, height: 30,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppTheme.accentRed,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(child: Icon(Icons.square, color: Colors.white, size: 12)),
                    ),
                  ),
                  if (_driverPos != null)
                    Marker(
                      point: _driverPos!,
                      width: 48, height: 48,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: const Icon(Icons.directions_car, color: AppTheme.accentDark),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Top Back button
          Positioned(
            top: 40, left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.accentDark),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Bottom Sheet Status
          Positioned(
            bottom: 24, left: 16, right: 16,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                boxShadow: AppTheme.elevatedShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryYellow.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: AppTheme.darkYellow),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Captain Rajesh', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
                            Row(
                              children: [
                                const Icon(Icons.star, color: AppTheme.primaryYellow, size: 14),
                                Text(' 4.8', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surface,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('MH 02 AB 1234', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('OTP', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textHint)),
                          Text('4125', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 2)),
                        ],
                      )
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ride.statusName,
                        style: GoogleFonts.inter(
                          fontSize: 16, 
                          fontWeight: FontWeight.w600,
                          color: ride.status == RideStatus.started ? AppTheme.accentGreen : AppTheme.accentDark,
                        ),
                      ),
                      if (ride.status == RideStatus.started)
                        Text(
                          'Enroute to destination',
                          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

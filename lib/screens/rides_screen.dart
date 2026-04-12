import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../models/ride_model.dart';
import '../services/database_service.dart';

class RidesScreen extends ConsumerStatefulWidget {
  const RidesScreen({super.key});

  @override
  ConsumerState<RidesScreen> createState() => _RidesScreenState();
}

class _RidesScreenState extends ConsumerState<RidesScreen> {
  
  @override
  void initState() {
    super.initState();
    // Ensure we load latest
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userRidesProvider.notifier).state = DatabaseService.getAllRides();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rides = ref.watch(userRidesProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('My Rides'),
      ),
      body: rides.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppTheme.cardShadow),
                    child: const Icon(Icons.history, size: 64, color: AppTheme.textHint),
                  ),
                  const SizedBox(height: 24),
                  Text('No rides yet', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Your completed rides will appear here', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                 ref.read(userRidesProvider.notifier).state = DatabaseService.getAllRides();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: rides.length,
                itemBuilder: (context, index) {
                  final ride = rides[index];
                  return _buildRideCard(ride);
                },
              ),
            ),
    );
  }

  Widget _buildRideCard(RideModel ride) {
    final isCompleted = ride.status == RideStatus.completed;
    final formatter = DateFormat('MMM dd, yyyy • hh:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(8)),
                      child: Icon(
                        ride.rideType == RideType.bike ? Icons.two_wheeler : Icons.local_taxi,
                        color: AppTheme.accentDark, size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${ride.rideTypeName} Ride', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(formatter.format(ride.createdAt), style: GoogleFonts.inter(color: AppTheme.textHint, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                Text(
                  '₹${ride.fare.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.accentDark),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.divider),
          
          // Locations
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.circle, size: 12, color: AppTheme.accentGreen),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(ride.pickupAddress, 
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(left: 5, top: 4, bottom: 4),
                  height: 20, width: 2,
                  color: AppTheme.divider,
                ),
                Row(
                  children: [
                    const Icon(Icons.square, size: 12, color: AppTheme.accentRed),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(ride.dropAddress, 
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Footer Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isCompleted ? AppTheme.accentGreen.withOpacity(0.05) : AppTheme.accentRed.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppTheme.radiusLg)),
            ),
            child: Row(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: isCompleted ? AppTheme.accentGreen : AppTheme.accentRed,
                ),
                const SizedBox(width: 8),
                Text(
                  ride.statusName,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? AppTheme.accentGreen : AppTheme.accentRed,
                  ),
                ),
                const Spacer(),
                if (ride.paymentMethod != null)
                  Text(
                    'Paid via ${ride.paymentMethod!.split('.').last.toUpperCase()}',
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

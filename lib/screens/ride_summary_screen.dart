import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import 'payment_screen.dart';

class RideSummaryScreen extends ConsumerWidget {
  const RideSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ride = ref.watch(currentRideProvider);
    if (ride == null) return const Scaffold();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),
                  // Success Icon
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_circle_rounded, color: AppTheme.accentGreen, size: 80),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ride Completed!',
                    style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.accentDark),
                  ),
                  Text(
                    'Hope you had a great journey',
                    style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 48),
  
                  // Summary Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      boxShadow: AppTheme.elevatedShadow,
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow('Distance', '${ride.distance.toStringAsFixed(1)} KM', Icons.route_outlined),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
                        _buildSummaryRow('Time', '${ride.duration} min', Icons.timer_outlined),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
                        _buildSummaryRow('Total Fare', '₹${ride.fare.toStringAsFixed(0)}', Icons.payments_outlined, isTotal: true),
                      ],
                    ),
                  ),
  
                  const SizedBox(height: 48), // Replaced Spacer with fixed size for scrollability
  
                  // Proceed to Payment
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const PaymentScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentDark,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Proceed to Payment', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon, {bool isTotal = false}) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textHint, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isTotal ? AppTheme.accentDark : AppTheme.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 24 : 16,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: AppTheme.accentDark,
          ),
        ),
      ],
    );
  }
}

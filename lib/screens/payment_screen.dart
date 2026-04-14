import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_theme.dart';
import '../models/payment_model.dart';
import '../services/database_service.dart';
import '../providers/app_providers.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  PaymentMethod? _selectedMethod;
  bool _isProcessing = false;

  void _processPayment() async {
    if (_selectedMethod == null) return;
    final ride = ref.read(currentRideProvider);
    if (ride == null) return;

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));

    // Save payment
    final payment = PaymentModel(
      id: const Uuid().v4(),
      rideId: ride.id,
      methodIndex: _selectedMethod!.index,
      amount: ride.fare,
      timestamp: DateTime.now(),
    );
    await DatabaseService.savePayment(payment);

    // Update ride with payment method
    await DatabaseService.updateRidePayment(ride.id, _selectedMethod.toString());

    // Refresh ride history provider
    ref.read(userRidesProvider.notifier).state = DatabaseService.getAllRides();

    if (mounted) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppTheme.accentGreen, size: 64),
            const SizedBox(height: 16),
            Text('Payment Successful', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Thank you for riding with Rapido', 
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: AppTheme.textSecondary)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(currentRideProvider.notifier).state = null;
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ride = ref.watch(currentRideProvider);
    if (ride == null) return const Scaffold();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        automaticallyImplyLeading: false, // Force them to pay/select
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.primaryYellow.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    Text('Amount to Pay', style: GoogleFonts.inter(color: AppTheme.accentDark)),
                    const SizedBox(height: 8),
                    Text('₹${ride.fare.toStringAsFixed(0)}', 
                      style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.accentDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text('Select Payment Method', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
  
              _buildPaymentOption(PaymentMethod.upi, 'UPI', 'Pay via GPay, PhonePe, Paytm', '📱'),
              const SizedBox(height: 12),
              _buildPaymentOption(PaymentMethod.card, 'Credit/Debit Card', 'Visa, Mastercard, RuPay', '💳'),
              const SizedBox(height: 12),
              _buildPaymentOption(PaymentMethod.cash, 'Cash', 'Pay captain directly', '💵'),
  
              const SizedBox(height: 48), // Padding instead of Spacer
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedMethod == null || _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentDark, foregroundColor: Colors.white),
                  child: _isProcessing 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text('Confirm Payment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(PaymentMethod method, String title, String subtitle, String iconUrl) {
    final isSelected = _selectedMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: isSelected ? AppTheme.accentDark : AppTheme.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppTheme.cardShadow : [],
        ),
        child: Row(
          children: [
            Text(iconUrl, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
                  Text(subtitle, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppTheme.accentDark : AppTheme.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

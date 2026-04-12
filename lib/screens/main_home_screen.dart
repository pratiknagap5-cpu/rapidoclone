import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/location_model.dart';
import '../models/user_model.dart';
import '../services/location_service.dart';
import '../services/database_service.dart';
import '../providers/app_providers.dart';
import 'home/home_screen.dart';
import 'rides_screen.dart';
import 'wallet_screen.dart';
import 'profile_screen.dart';

class MainHomeScreen extends ConsumerStatefulWidget {
  const MainHomeScreen({super.key});

  @override
  ConsumerState<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends ConsumerState<MainHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    RidesScreen(),
    WalletScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Load user profile from Hive
    final user = DatabaseService.getUserProfile();
    if (user != null) {
      ref.read(currentUserProvider.notifier).state = user;
    }

    // Load wallet balance
    final balance = DatabaseService.getWalletBalance();
    ref.read(walletBalanceProvider.notifier).state = balance;

    // Load ride history
    final rides = DatabaseService.getAllRides();
    ref.read(userRidesProvider.notifier).state = rides;

    // Get current location
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    ref.read(isLocationLoadingProvider.notifier).state = true;

    final location = await LocationService.getCurrentLocation();

    if (location != null && mounted) {
      ref.read(currentLocationProvider.notifier).state = location;
      ref.read(pickupLocationProvider.notifier).state = location;
    } else if (mounted) {
      // Fallback location (Mumbai)
      final fallback = LocationModel(
        latitude: 19.0760,
        longitude: 72.8777,
        address: 'Mumbai, Maharashtra',
      );
      ref.read(currentLocationProvider.notifier).state = fallback;
      ref.read(pickupLocationProvider.notifier).state = fallback;
    }

    ref.read(isLocationLoadingProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
                _buildNavItem(1, Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Rides'),
                _buildNavItem(2, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, 'Wallet'),
                _buildNavItem(3, Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 20 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryYellow.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 24,
              color: isActive ? AppTheme.accentDark : AppTheme.textHint,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentDark,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

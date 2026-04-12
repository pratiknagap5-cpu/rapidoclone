import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryYellow.withOpacity(0.2),
                      border: Border.all(color: AppTheme.primaryYellow, width: 2),
                    ),
                    child: const Icon(Icons.person, size: 50, color: AppTheme.darkYellow),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: AppTheme.accentDark, shape: BoxShape.circle),
                      child: const Icon(Icons.edit, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(user?.name ?? 'User Name', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(user?.phoneNumber ?? '+91 XXXXX XXXXX', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  children: [
                    _buildMenuItem(Icons.favorite_border, 'Saved Places'),
                    const Divider(height: 1),
                    _buildMenuItem(Icons.star_border, 'Rating & Reviews'),
                    const Divider(height: 1),
                    _buildMenuItem(Icons.help_outline, 'Help & Support'),
                    const Divider(height: 1),
                    _buildMenuItem(Icons.info_outline, 'About Us'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    // Would handle logout here
                  },
                  icon: const Icon(Icons.logout, color: AppTheme.accentRed),
                  label: Text('Log Out', style: GoogleFonts.inter(color: AppTheme.accentRed, fontWeight: FontWeight.w600)),
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.accentRed.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: AppTheme.accentDark),
      title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textHint),
      onTap: () {},
    );
  }
}

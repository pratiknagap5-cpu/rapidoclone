import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../providers/app_providers.dart';
import 'main_home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _showOtp = false;
  String _generatedOtp = '';
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      _showSnack('Please enter your name');
      return;
    }
    if (phone.isEmpty || phone.length != 10) {
      _showSnack('Please enter a valid 10-digit phone number');
      return;
    }

    setState(() => _isLoading = true);

    // Generate demo OTP
    _generatedOtp = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000))
        .toString()
        .substring(0, 6);

    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _showOtp = true;
        _isLoading = false;
      });
      _animController.reset();
      _animController.forward();

      _showSnack('Demo OTP: $_generatedOtp', isSuccess: true, duration: 8);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _showSnack('Enter 6-digit OTP');
      return;
    }
    if (otp != _generatedOtp) {
      _showSnack('Invalid OTP. Check the demo OTP shown above.');
      return;
    }

    setState(() => _isLoading = true);

    final user = UserModel(
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      email: '${_nameController.text.trim().toLowerCase().replaceAll(' ', '')}@email.com',
    );

    // Save to Hive and SharedPreferences
    await DatabaseService.saveUserProfile(user);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_phone', user.phoneNumber);

    ref.read(currentUserProvider.notifier).state = user;

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => const MainHomeScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  void _showSnack(String msg, {bool isSuccess = false, int duration = 3}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isSuccess ? AppTheme.accentGreen : AppTheme.accentRed,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: Duration(seconds: duration),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: _showOtp ? _buildOtpView() : _buildLoginView(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: AppTheme.elevatedShadow,
          ),
          child: const Icon(Icons.two_wheeler, size: 56, color: AppTheme.accentDark),
        ),
        const SizedBox(height: 32),
        Text(
          'Welcome to Rapido',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your details to get started',
          style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 40),

        // Name field
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            boxShadow: AppTheme.cardShadow,
          ),
          child: TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Full Name',
              prefixIcon: const Icon(Icons.person_outline, color: AppTheme.textHint),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Phone field
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            boxShadow: AppTheme.cardShadow,
          ),
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            decoration: InputDecoration(
              hintText: 'Phone Number',
              counterText: '',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Text('+91', style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                )),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 60),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Send OTP button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sendOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.sms_outlined, size: 20),
                      const SizedBox(width: 10),
                      Text('Send OTP', style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      )),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: AppTheme.elevatedShadow,
          ),
          child: const Icon(Icons.lock_outline, size: 56, color: AppTheme.accentDark),
        ),
        const SizedBox(height: 32),
        Text(
          'Verify OTP',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the 6-digit code sent to\n+91 ${_phoneController.text}',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 40),

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            boxShadow: AppTheme.cardShadow,
          ),
          child: TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: 12,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '• • • • • •',
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : Text('Verify & Continue', style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            setState(() {
              _showOtp = false;
              _otpController.clear();
            });
            _animController.reset();
            _animController.forward();
          },
          child: Text('← Change Number', style: GoogleFonts.inter(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          )),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/google_button.dart';
import '../widgets/premium_text_field.dart';
import '../widgets/segmented_tab_bar.dart';
import '../services/supabase_service.dart';
import '../services/biometric_service.dart';
import 'email_input_screen.dart';
import 'home_screen.dart';
import 'create_password_screen.dart';
import 'forgot_password_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _selectedTab = 0; // 0 for Email, 1 for Phone
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  String? _emailOrPhoneError;
  String? _passwordError;
  String _selectedCountryCode = '+964 🇮🇶';

  final List<String> _countryCodes = [
    '+964 🇮🇶',
    '+966 🇸🇦',
    '+971 🇦🇪',
    '+20 🇪🇬',
    '+962 🇯🇴',
    '+961 🇱🇧',
    '+965 🇰🇼',
    '+974 🇶🇦',
  ];

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    setState(() {
      _emailOrPhoneError = null;
      _passwordError = null;
    });

    bool isValid = true;
    final text = _emailOrPhoneController.text.trim();
    final password = _passwordController.text;

    if (text.isEmpty) {
      setState(() {
        _emailOrPhoneError = _selectedTab == 0
            ? 'يرجى إدخال البريد الإلكتروني'
            : 'يرجى إدخال رقم الهاتف';
      });
      isValid = false;
    } else if (_selectedTab == 0 && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(text)) {
      setState(() {
        _emailOrPhoneError = 'البريد الإلكتروني غير صحيح';
      });
      isValid = false;
    }

    if (password.isEmpty) {
      setState(() {
        _passwordError = 'يرجى إدخال كلمة المرور';
      });
      isValid = false;
    } else if (password.length < 6) {
      setState(() {
        _passwordError = 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
      });
      isValid = false;
    }

    return isValid;
  }

  void _handleLogin() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      await SupabaseService.signInWithEmailAndPassword(
        _emailOrPhoneController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'البريد الإلكتروني أو كلمة المرور غير صحيحة',
                  style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final response = await SupabaseService.signInWithGoogle();
      if (!mounted) return;
      if (response == null) {
        setState(() => _isLoading = false);
        return;
      }
      // Check if user has a profile already
      final profile = await SupabaseService.getProfile();
      if (!mounted) return;
      if (profile != null &&
          profile['full_name'] != null &&
          profile['username'] != null) {
        // Existing user with profile -> go to Home
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        // New Google user -> setup password then profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const CreatePasswordScreen(isFromGoogle: true),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            'حدث خطأ أثناء الدخول بـ Google',
            style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  void _handleBiometricLogin() async {

    final available = await BiometricService.isBiometricAvailable();
    if (!available) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceDark,
          content: Text(
            'البصمة غير مدعومة أو غير مفعلة على هذا الجهاز',
            style: GoogleFonts.cairo(color: AppColors.textPrimary),
          ),
        ),
      );
      return;
    }

    final authenticated = await BiometricService.authenticate();
    if (authenticated) {
      if (SupabaseService.isLoggedIn) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surfaceDark,
            content: Text(
              'تم التحقق بالبصمة بنجاح! يرجى الدخول بكلمة المرور لتأكيد الحساب.',
              style: GoogleFonts.cairo(color: AppColors.textPrimary),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Top Utility Bar: Close & Language Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.cardBorder, width: 1),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textPrimary,
                          size: 22,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.language_rounded, color: AppColors.textSecondary, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'العربية',
                            style: GoogleFonts.cairo(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 2. Branding Header & Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppColors.primaryGlow,
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'تسجيل الدخول',
                        style: GoogleFonts.cairo(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'مرحباً بك مجدداً، أدخل بياناتك للمتابعة',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Segmented Tab Switcher (Email vs Phone)
                SegmentedTabBar(
                  selectedIndex: _selectedTab,
                  tabs: const ['البريد الإلكتروني', 'رقم الهاتف'],
                  onTabChanged: (index) {
                    setState(() {
                      _selectedTab = index;
                      _emailOrPhoneError = null;
                      _emailOrPhoneController.clear();
                    });
                  },
                ),

                const SizedBox(height: 24),

                // 4. Form Credentials Inputs
                if (_selectedTab == 1) ...[
                  // Phone Input Row with Country Code Selector
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppColors.cardFill,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder, width: 1),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCountryCode,
                            dropdownColor: AppColors.surfaceDark,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 20),
                            items: _countryCodes.map((code) {
                              return DropdownMenuItem<String>(
                                value: code,
                                child: Text(
                                  code,
                                  style: GoogleFonts.cairo(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedCountryCode = val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: PremiumTextField(
                          controller: _emailOrPhoneController,
                          hintText: '7XX XXX XXXX',
                          labelText: 'رقم الهاتف',
                          errorText: _emailOrPhoneError,
                          leadingIcon: Icons.phone_android_rounded,
                          keyboardType: TextInputType.phone,
                          onChanged: (_) {
                            if (_emailOrPhoneError != null) {
                              setState(() => _emailOrPhoneError = null);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Email Input Field
                  PremiumTextField(
                    controller: _emailOrPhoneController,
                    hintText: 'name@example.com',
                    labelText: 'البريد الإلكتروني',
                    errorText: _emailOrPhoneError,
                    leadingIcon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) {
                      if (_emailOrPhoneError != null) {
                        setState(() => _emailOrPhoneError = null);
                      }
                    },
                  ),
                ],

                const SizedBox(height: 16),

                // Password Field
                PremiumTextField(
                  controller: _passwordController,
                  hintText: '••••••••',
                  labelText: 'كلمة المرور',
                  errorText: _passwordError,
                  leadingIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  onSubmitted: (_) => _handleLogin(),
                  onChanged: (_) {
                    if (_passwordError != null) {
                      setState(() => _passwordError = null);
                    }
                  },
                ),

                const SizedBox(height: 6),

                // Forgot Password Action Link
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'هل نسيت كلمة المرور؟',
                      style: GoogleFonts.cairo(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 5. Primary CTA "دخول" Button & Biometrics Button
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: AppColors.primaryGlow,
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'تسجيل الدخول',
                                      style: GoogleFonts.cairo(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Biometric Auth Button
                    InkWell(
                      onTap: _handleBiometricLogin,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: const Icon(
                          Icons.fingerprint_rounded,
                          color: AppColors.primaryOrange,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),


                // 6. Social Authentication Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.cardBorder, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'أو الدخول عبر',
                        style: GoogleFonts.cairo(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.cardBorder, thickness: 1)),
                  ],
                ),

                const SizedBox(height: 12),

                // 7. Google Sign-In Button
                GoogleSignInButton(
                  onPressed: _handleGoogleLogin,
                  isLoading: false,
                ),

                const SizedBox(height: 16),

                // 8. Footer Callout: Create New Account
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EmailInputScreen(isSignUp: true),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            const TextSpan(text: 'لا تمتلك حساباً؟ '),
                            TextSpan(
                              text: 'أنشئ حساب جديد',
                              style: GoogleFonts.cairo(
                                color: AppColors.primaryOrange,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

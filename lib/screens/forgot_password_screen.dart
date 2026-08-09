import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/otp_input_field.dart';
import '../services/supabase_service.dart';
import 'home_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 1; // 1: Email Input, 2: OTP Verification, 3: New Password Input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  // OTP Timer State
  Timer? _timer;
  int _timerSeconds = 60;
  bool _canResend = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _timerSeconds = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  // Step 1: Send Reset OTP Email
  void _handleSendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _errorMessage = 'يرجى إدخال بريد إلكتروني صحيح');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await SupabaseService.resetPasswordForEmail(email);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _step = 2;
      });
      _startTimer();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'تعذر إرسال الرمز، يرجى التأكد من البريد الإلكتروني';
      });
    }
  }

  // Step 2: Verify Reset OTP Code
  void _handleVerifyOtp(String code) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await SupabaseService.verifyResetOtp(_emailController.text.trim(), code);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _step = 3;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'كود التحقق غير صحيح أو انتهت صلاحيته';
      });
    }
  }

  // Resend Reset Code
  void _handleResendCode() async {
    if (!_canResend) return;
    try {
      await SupabaseService.resetPasswordForEmail(_emailController.text.trim());
      _startTimer();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceDark,
          content: Text(
            'تمت إعادة إرسال رمز استعادة كلمة المرور',
            style: GoogleFonts.cairo(color: AppColors.textPrimary),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('حدث خطأ أثناء الإرسال', style: GoogleFonts.cairo(color: Colors.white)),
        ),
      );
    }
  }

  // Step 3: Update Password
  void _handleSaveNewPassword() async {
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (password.length < 8) {
      setState(() => _errorMessage = 'كلمة المرور يجب أن تكون 8 أحرف على الأقل');
      return;
    }
    if (password != confirm) {
      setState(() => _errorMessage = 'كلمتا المرور غير متطابقتين');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await SupabaseService.updatePassword(password);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'تم تغيير كلمة المرور بنجاح!',
            style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ أثناء تحديث كلمة المرور';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Back Button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceDark,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textPrimary,
                      size: 28,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Title and Subtitle based on step
              if (_step == 1) ...[
                Text(
                  'استعادة كلمة المرور',
                  style: GoogleFonts.cairo(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'أدخل بريدك الإلكتروني المسجل وسنرسل لك رمزاً لإعادة ضبط كلمة المرور.',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                CustomTextField(
                  hintText: 'example@domain.com',
                  helperText: _errorMessage,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'إرسال رمز التحقق',
                  isLoading: _isLoading,
                  onPressed: _handleSendCode,
                ),
              ] else if (_step == 2) ...[
                Text(
                  'إدخال رمز التحقق',
                  style: GoogleFonts.cairo(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'أدخل رمز التحقق الذي أرسلناه إلى ${_emailController.text}',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                OtpInputField(
                  onCompleted: _handleVerifyOtp,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.cairo(color: Colors.redAccent, fontSize: 13),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: _canResend ? _handleResendCode : null,
                    child: Text(
                      _canResend
                          ? 'إعادة إرسال الرمز'
                          : 'إعادة الإرسال بعد $_timerSeconds ثانية',
                      style: GoogleFonts.cairo(
                        color: _canResend ? AppColors.primaryOrange : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ] else if (_step == 3) ...[
                Text(
                  'تعيين كلمة مرور جديدة',
                  style: GoogleFonts.cairo(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'أدخل كلمة المرور الجديدة لحسابك واستخدمها للدخول مستقبلاً.',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                CustomTextField(
                  hintText: '••••••••',
                  helperText: 'كلمة المرور الجديدة',
                  isPassword: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  hintText: '••••••••',
                  helperText: _errorMessage ?? 'تأكيد كلمة المرور',
                  isPassword: true,
                  controller: _confirmPasswordController,
                ),
                const SizedBox(height: 28),
                CustomButton(
                  text: 'حفظ كلمة المرور الجديدة',
                  isLoading: _isLoading,
                  onPressed: _handleSaveNewPassword,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

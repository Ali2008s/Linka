import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/otp_input_field.dart';
import '../services/supabase_service.dart';
import '../utils/ios_helpers.dart';
import 'create_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  bool _isVerifying = false;
  Timer? _timer;
  int _timerSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
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

  void _onOtpCompleted(String code) async {
    setState(() {
      _isVerifying = true;
    });

    try {
      await SupabaseService.verifyEmailOtp(widget.email, code);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        adaptivePageRoute(
          builder: (_) => CreatePasswordScreen(email: widget.email),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isVerifying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            'كود التحقق غير صحيح، حاول مرة أخرى',
            style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
  }

  void _openEmailApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceDark,
        content: Text(
          'جاري فتح تطبيق البريد الإلكتروني...',
          style: GoogleFonts.cairo(color: AppColors.textPrimary),
        ),
      ),
    );
  }

  void _resendEmail() async {
    if (!_canResend) return;
    try {
      await SupabaseService.signUpWithEmail(widget.email);
      _startTimer();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            'تمت إعادة إرسال رمز التحقق إلى ${widget.email}',
            style: GoogleFonts.cairo(color: AppColors.textPrimary),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('حدث خطأ أثناء الإرسال',
              style: GoogleFonts.cairo(color: Colors.white)),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final displayEmail = widget.email.isNotEmpty ? widget.email : 'sjsj@gmail.com';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
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

                // Main Title: "تحقّق من صندوق الوارد"
                Text(
                  'تحقّق من صندوق الوارد',
                  style: GoogleFonts.cairo(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle paragraph
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      const TextSpan(text: 'لقد أرسلنا للتو '),
                      TextSpan(
                        text: 'Email ',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(text: 'إلى $displayEmail. انقر الرابط بالداخل أو أدخل الرمز أدناه'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Warning / Resend prompt
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        const TextSpan(text: 'لم يصلك '),
                        TextSpan(
                          text: 'Email',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const TextSpan(text: '؟ تحقّق من مجلد الرسائل غير المرغوب فيها أو '),
                        TextSpan(
                          text: 'جرّب عنواناً آخر.',
                          style: GoogleFonts.cairo(
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // 6-digit OTP Code Input
                OtpInputField(
                  length: 6,
                  onCompleted: _onOtpCompleted,
                  onChanged: (_) {},
                ),

                const SizedBox(height: 48),

                // Primary Button: افتح App البريد الإلكتروني
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'افتح ',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: 'App ',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: 'البريد الإلكتروني',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                CustomButton(
                  text: 'افتح App البريد الإلكتروني',
                  type: CustomButtonType.primary,
                  isLoading: _isVerifying,
                  onPressed: _openEmailApp,
                ),

                const SizedBox(height: 12),

                // Secondary Button: إعادة إرسال Email
                CustomButton(
                  text: _canResend
                      ? 'إعادة إرسال Email'
                      : 'إعادة الإرسال بعد $_timerSeconds ثانية',
                  type: CustomButtonType.secondary,
                  onPressed: _canResend ? _resendEmail : null,
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

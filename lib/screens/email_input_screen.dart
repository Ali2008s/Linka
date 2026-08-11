import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/supabase_service.dart';
import '../utils/ios_helpers.dart';
import 'otp_verification_screen.dart';
import 'password_screen.dart';

class EmailInputScreen extends StatefulWidget {
  final bool isSignUp;

  const EmailInputScreen({
    super.key,
    this.isSignUp = true,
  });

  @override
  State<EmailInputScreen> createState() => _EmailInputScreenState();
}

class _EmailInputScreenState extends State<EmailInputScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isValidEmail = false;
  bool _isSending = false;
  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmail);
    _emailController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final text = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final valid = emailRegex.hasMatch(text);
    if (valid != _isValidEmail) {
      setState(() {
        _isValidEmail = valid;
      });
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'شروط الخدمة وسياسة الخصوصية',
          style: GoogleFonts.cairo(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Text(
            'أهلاً بك في التطبيق.\n\n'
            '1. التزامك بجميع القوانين المعمول بها عند استخدام التطبيق.\n'
            '2. الحفاظ على سرية معلومات حسابك وكلمة المرور.\n'
            '3. عدم استخدام التطبيق في أي أنشطة غير مشروعة أو ضارة.\n'
            '4. نحن نحترم خصوصيتك ونقوم بحماية بياناتك الشخصية وفقاً لأعلى معايير الأمان.',
            style: GoogleFonts.cairo(color: AppColors.textSecondary, height: 1.6, fontSize: 13),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'موافق',
              style: GoogleFonts.cairo(color: AppColors.primaryOrange, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToOtp() async {
    if (!_isValidEmail || !_acceptedTerms || _isSending) return;
    setState(() => _isSending = true);
    final email = _emailController.text.trim();
    try {
      if (widget.isSignUp) {
        final emailExists = await SupabaseService.doesEmailExist(email);
        if (emailExists) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Text(
                'هذا البريد الإلكتروني مسجل بالفعل. يرجى تسجيل الدخول بدلاً من ذلك.',
                style: GoogleFonts.cairo(color: Colors.white, fontSize: 13),
              ),
            ),
          );
          setState(() => _isSending = false);
          return;
        }
      }

      await SupabaseService.signUpWithEmail(email);
      if (!mounted) return;
      Navigator.push(
        context,
        adaptivePageRoute(
          builder: (context) => OtpVerificationScreen(
            email: email,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final errStr = e.toString();
      String userMessage = 'حدث خطأ أثناء إرسال كود التحقق';

      if (errStr.contains('Error sending confirmation email') || errStr.contains('500')) {
        userMessage = 'تعذر إرسال الإيميل من سيرفر Supabase (خطأ 500).\nيرجى إعداد مزود SMTP في Supabase Dashboard أو استخدام حساب آخر.';
      } else {
        userMessage = 'خطأ في إرسال كود التحقق: $errStr';
      }

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            userMessage,
            style: GoogleFonts.cairo(color: Colors.white, fontSize: 13),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _proceedToPassword() {
    Navigator.push(
      context,
      adaptivePageRoute(
        builder: (context) => PasswordScreen(
          email: _emailController.text.trim(),
        ),
      ),
    );
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
              // Circular Top Back Button
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

              const SizedBox(height: 32),

              // Title: "ما عنوان Email الخاص بك؟"
              RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'ما عنوان ',
                      style: GoogleFonts.cairo(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    TextSpan(
                      text: 'Email ',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextSpan(
                      text: 'الخاص بك؟',
                      style: GoogleFonts.cairo(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Email Input Field
              CustomTextField(
                controller: _emailController,
                hintText: 'الخاص بك Email',
                helperText: 'سنرسل إليك Email للتأكيد',
                keyboardType: TextInputType.emailAddress,
                autoFocus: true,
                onSubmitted: (_) => _proceedToOtp(),
              ),

              const SizedBox(height: 20),

              // Checkbox for Terms of Service & Privacy Policy
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Theme(
                    data: ThemeData(unselectedWidgetColor: AppColors.textSecondary),
                    child: Checkbox(
                      value: _acceptedTerms,
                      activeColor: AppColors.primaryOrange,
                      checkColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (val) {
                        setState(() {
                          _acceptedTerms = val ?? false;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _showTermsDialog,
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textSecondary),
                          children: [
                            const TextSpan(text: 'أوافق على '),
                            TextSpan(
                              text: 'شروط الخدمة وسياسة الخصوصية',
                              style: GoogleFonts.cairo(
                                color: AppColors.primaryOrange,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Button 1: متابعة
              CustomButton(
                text: 'متابعة',
                type: CustomButtonType.primary,
                isLoading: _isSending,
                onPressed: _isValidEmail && _acceptedTerms && !_isSending ? _proceedToOtp : null,
              ),


              const SizedBox(height: 12),

              // Button 2: تسجيل الدخول باستخدام كلمة المرور
              CustomButton(
                text: 'تسجيل الدخول باستخدام كلمة المرور',
                type: CustomButtonType.secondary,
                onPressed: _proceedToPassword,
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

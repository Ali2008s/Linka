import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class PasswordScreen extends StatefulWidget {
  final String email;

  const PasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_passwordController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceDark,
        content: Text(
          'تم تسجيل الدخول بنجاح!',
          style: GoogleFonts.cairo(color: AppColors.textPrimary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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

              const SizedBox(height: 32),

              // Header
              Text(
                'أدخل كلمة المرور',
                style: GoogleFonts.cairo(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                widget.email.isNotEmpty ? 'تسجيل الدخول بالحساب: ${widget.email}' : 'أدخل كلمة المرور للمتابعة',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 32),

              // Password Input Field
              CustomTextField(
                controller: _passwordController,
                hintText: 'كلمة المرور',
                isPassword: true,
                autoFocus: true,
                onSubmitted: (_) => _handleLogin(),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 16),

              // Forgot Password link
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'نسيت كلمة المرور؟',
                    style: GoogleFonts.cairo(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Primary Login Button
              CustomButton(
                text: 'تسجيل الدخول',
                type: CustomButtonType.primary,
                isLoading: _isLoading,
                onPressed: _passwordController.text.isNotEmpty ? _handleLogin : null,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

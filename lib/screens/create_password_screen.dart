import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/supabase_service.dart';
import '../services/biometric_service.dart';
import 'profile_setup_screen.dart';

class CreatePasswordScreen extends StatefulWidget {
  final bool isFromGoogle;
  final String? email; // البريد الإلكتروني المستخدم للتسجيل
  const CreatePasswordScreen({super.key, this.isFromGoogle = false, this.email});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final p = _passwordController.text;
    return p.length >= 8 &&
        RegExp(r'[0-9]').hasMatch(p) &&
        _confirmController.text == p;
  }

  void _handleNext() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.length < 8) {
      setState(() => _errorText = 'كلمة المرور يجب أن تكون 8 أحرف على الأقل');
      return;
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      setState(() => _errorText = 'يجب أن تحتوي على رقم واحد على الأقل');
      return;
    }
    if (password != confirm) {
      setState(() => _errorText = 'كلمتا المرور غير متطابقتين');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      await SupabaseService.updatePassword(password);
      if (!mounted) return;

      // عرض نافذة تفعيل البصمة إذا كان الإيميل متوفراً
      final userEmail = widget.email ?? SupabaseService.currentUser?.email ?? '';
      if (userEmail.isNotEmpty) {
        await BiometricService.promptEnableBiometric(
          context,
          email: userEmail,
          password: password,
        );
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileSetupScreen(
            email: userEmail,
            password: password,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = 'حدث خطأ: ${e.toString()}';
      });
    }
  }

  Widget _buildStrengthIndicator() {
    final p = _passwordController.text;
    int strength = 0;
    if (p.length >= 8) strength++;
    if (RegExp(r'[0-9]').hasMatch(p)) strength++;
    if (RegExp(r'[!@#\$%^&*]').hasMatch(p)) strength++;
    if (p.length >= 12) strength++;

    final colors = [Colors.red, Colors.orange, Colors.yellow, Colors.greenAccent];
    final labels = ['ضعيفة', 'مقبولة', 'جيدة', 'قوية'];

    return p.isEmpty
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: List.generate(4, (i) {
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: i < strength
                            ? colors[strength - 1]
                            : AppColors.cardBorder,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 4),
              if (strength > 0)
                Text(
                  'قوة كلمة المرور: ${labels[strength - 1]}',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: colors[strength - 1],
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
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
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.primaryGlow,
                ),
                child: const Icon(Icons.lock_outline_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(height: 20),
              Text(
                'أنشئ كلمة مرور',
                style: GoogleFonts.cairo(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isFromGoogle
                    ? 'ستُستخدم هذه الكلمة للدخول بالإيميل أيضاً'
                    : 'اختر كلمة مرور قوية لحساب آمن',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: _passwordController,
                hintText: 'كلمة المرور (8 أحرف على الأقل)',
                isPassword: true,
                autoFocus: true,
                onChanged: (_) => setState(() {}),
              ),
              _buildStrengthIndicator(),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmController,
                hintText: 'تأكيد كلمة المرور',
                isPassword: true,
                onChanged: (_) => setState(() => _errorText = null),
                onSubmitted: (_) => _isValid ? _handleNext() : null,
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorText!,
                  style: GoogleFonts.cairo(
                    color: Colors.redAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 40),
              CustomButton(
                text: 'التالي',
                type: CustomButtonType.primary,
                isLoading: _isLoading,
                onPressed: _isValid ? _handleNext : null,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

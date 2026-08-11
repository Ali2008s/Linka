import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/illustration_grid.dart';
import '../utils/ios_helpers.dart';
import 'email_input_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            final isSmall = availableHeight < 600;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: availableHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          SizedBox(height: isSmall ? 8 : 20),
                          const SubstackLogoHeader(),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: isSmall ? 8 : 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: isSmall ? 180 : 250,
                          child: const IllustrationGrid(),
                        ),
                      ),
                      Column(
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'مرحبًا بك في ',
                                  style: GoogleFonts.cairo(
                                    fontSize: isSmall ? 22 : 28,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Substack',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: isSmall ? 26 : 32,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'البيت الذي يحتضن الثقافة الرفيعة',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: isSmall ? 13 : 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: isSmall ? 20 : 32),
                          CustomButton(
                            text: 'إنشاء حساب مجانًا',
                            type: CustomButtonType.primary,
                            onPressed: () {
                              Navigator.push(
                                context,
                                adaptivePageRoute(
                                  builder: (context) => const EmailInputScreen(isSignUp: true),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          CustomButton(
                            text: 'تسجيل الدخول',
                            type: CustomButtonType.secondary,
                            onPressed: () {
                              Navigator.push(
                                context,
                                adaptivePageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: isSmall ? 12 : 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  height: 1.5,
                                  color: AppColors.textSecondary,
                                ),
                                children: [
                                  const TextSpan(text: 'بإنشاء حساب، فإنك توافق على '),
                                  TextSpan(
                                    text: 'شروط الاستخدام',
                                    style: GoogleFonts.cairo(
                                      color: AppColors.primaryOrange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(text: ' الخاصة بـ '),
                                  TextSpan(
                                    text: 'Substack ',
                                    style: GoogleFonts.cairo(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'وسياسة الخصوصية',
                                    style: GoogleFonts.cairo(
                                      color: AppColors.primaryOrange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

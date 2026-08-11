import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/ios_helpers.dart';

enum CustomButtonType { primary, secondary }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonType type;
  final bool isLoading;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = CustomButtonType.primary,
    this.isLoading = false,
    this.height = 54.0,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    Color backgroundColor;
    Color textColor;
    BorderSide borderSide;

    if (type == CustomButtonType.primary) {
      backgroundColor = isEnabled ? AppColors.primaryOrange : AppColors.buttonDisabled;
      textColor = isEnabled ? AppColors.textPrimary : AppColors.textDisabled;
      borderSide = BorderSide.none;
    } else {
      backgroundColor = AppColors.buttonDark;
      textColor = AppColors.textPrimary;
      borderSide = const BorderSide(color: AppColors.buttonDarkBorder, width: 1.0);
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
                hapticLight();
                onPressed?.call();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: type == CustomButtonType.primary ? AppColors.buttonDisabled : AppColors.buttonDark.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: borderSide,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? adaptiveProgressIndicator(
                color: type == CustomButtonType.primary ? Colors.white : AppColors.primaryOrange,
                size: 22,
              )
            : Text(
                text,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isEnabled ? textColor : (type == CustomButtonType.primary ? AppColors.textDisabled : AppColors.textSecondary.withValues(alpha: 0.5)),
                ),
              ),
      ),
    );
  }
}


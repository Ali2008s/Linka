import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? helperText;
  final TextInputType keyboardType;
  final bool isPassword;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autoFocus;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.helperText,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.onChanged,
    this.onSubmitted,
    this.autoFocus = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.cardBorder,
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: widget.controller,
            autofocus: widget.autoFocus,
            keyboardType: widget.keyboardType,
            obscureText: widget.isPassword ? _obscureText : false,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            style: GoogleFonts.cairo(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: widget.hintText,
              hintStyle: GoogleFonts.cairo(
                color: AppColors.textMuted,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
        if (widget.helperText != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Text(
              widget.helperText!,
              style: GoogleFonts.cairo(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class PremiumTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final String? errorText;
  final IconData? leadingIcon;
  final TextInputType keyboardType;
  final bool isPassword;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autoFocus;
  final Iterable<String>? autofillHints;

  const PremiumTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.errorText,
    this.leadingIcon,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.onChanged,
    this.onSubmitted,
    this.autoFocus = false,
    this.autofillHints,
  });

  @override
  State<PremiumTextField> createState() => _PremiumTextFieldState();
}

class _PremiumTextFieldState extends State<PremiumTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Padding(
            padding: const EdgeInsets.only(right: 4.0, bottom: 4.0),
            child: Text(
              widget.labelText!,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _isFocused ? AppColors.primaryOrange : AppColors.textSecondary,
              ),
            ),
          ),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.cardFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError
                  ? Colors.redAccent
                  : (_isFocused ? AppColors.cardBorderFocused : AppColors.cardBorder),
              width: _isFocused || hasError ? 1.5 : 1.0,
            ),
            boxShadow: _isFocused ? AppColors.inputFocusGlow : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              if (widget.leadingIcon != null) ...[
                Icon(
                  widget.leadingIcon,
                  size: 18,
                  color: _isFocused ? AppColors.primaryOrange : AppColors.textMuted,
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  autofocus: widget.autoFocus,
                  keyboardType: widget.keyboardType,
                  keyboardAppearance: Brightness.dark,
                  autofillHints: widget.autofillHints ??
                      (widget.isPassword
                          ? [AutofillHints.password]
                          : (widget.keyboardType == TextInputType.emailAddress
                              ? [AutofillHints.email]
                              : null)),
                  obscureText: widget.isPassword ? _obscureText : false,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  style: GoogleFonts.cairo(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.hintText,
                    hintStyle: GoogleFonts.cairo(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              if (widget.isPassword) ...[
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: _obscureText ? AppColors.textMuted : AppColors.primaryOrange,
                    size: 18,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: Text(
              widget.errorText!,
              style: GoogleFonts.cairo(
                color: Colors.redAccent,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

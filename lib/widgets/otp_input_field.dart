import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class OtpInputField extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;

  const OtpInputField({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.onChanged,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<String> _otpValues;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    _otpValues = List.filled(widget.length, '');

    for (int i = 0; i < widget.length; i++) {
      _focusNodes[i].addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      value = value.characters.last;
      _controllers[index].text = value;
    }

    _otpValues[index] = value;
    final currentOtp = _otpValues.join();

    if (widget.onChanged != null) {
      widget.onChanged!(currentOtp);
    }

    if (value.isNotEmpty) {
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (currentOtp.length == widget.length) {
          widget.onCompleted(currentOtp);
        }
      }
    }
    setState(() {});
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      _otpValues[index - 1] = '';
      if (widget.onChanged != null) {
        widget.onChanged!(_otpValues.join());
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        final isFocused = _focusNodes[index].hasFocus;
        final hasValue = _otpValues[index].isNotEmpty;

        return KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: (event) => _onKeyEvent(index, event),
          child: Container(
            width: 48,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.cardFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFocused
                    ? AppColors.focusBlue
                    : (hasValue ? AppColors.cardBorder : AppColors.cardBorder),
                width: isFocused ? 2.0 : 1.0,
              ),
            ),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) => _onDigitChanged(index, value),
            ),
          ),
        );
      }),
    );
  }
}

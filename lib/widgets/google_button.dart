import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFF18181E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2C2C36),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withValues(alpha: 0.05),
          highlightColor: Colors.white.withValues(alpha: 0.02),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: isLoading
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const GoogleIcon(),
                      const SizedBox(width: 12),
                      Text(
                        'الدخول عبر Google',
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class GoogleIcon extends StatelessWidget {
  const GoogleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Blue
    paint.color = const Color(0xFF4285F4);
    final Path bluePath = Path()
      ..moveTo(width * 0.95, height * 0.5)
      ..cubicTo(width * 0.95, height * 0.46, width * 0.94, height * 0.42, width * 0.93, height * 0.38)
      ..lineTo(width * 0.5, height * 0.38)
      ..lineTo(width * 0.5, height * 0.6)
      ..lineTo(width * 0.76, height * 0.6)
      ..cubicTo(width * 0.74, height * 0.68, width * 0.69, height * 0.74, width * 0.61, height * 0.78)
      ..lineTo(width * 0.61, height * 0.93)
      ..lineTo(width * 0.77, height * 0.93)
      ..cubicTo(width * 0.87, height * 0.84, width * 0.95, height * 0.69, width * 0.95, height * 0.5);
    canvas.drawPath(bluePath, paint);

    // Green
    paint.color = const Color(0xFF34A853);
    final Path greenPath = Path()
      ..moveTo(width * 0.5, height * 0.96)
      ..cubicTo(width * 0.63, height * 0.96, width * 0.74, height * 0.92, width * 0.81, height * 0.85)
      ..lineTo(width * 0.66, height * 0.73)
      ..cubicTo(width * 0.61, height * 0.76, width * 0.56, height * 0.78, width * 0.5, height * 0.78)
      ..cubicTo(width * 0.38, height * 0.78, width * 0.28, height * 0.7, width * 0.24, height * 0.59)
      ..lineTo(width * 0.08, height * 0.71)
      ..cubicTo(width * 0.16, height * 0.86, width * 0.32, height * 0.96, width * 0.5, height * 0.96);
    canvas.drawPath(greenPath, paint);

    // Yellow
    paint.color = const Color(0xFFFBBC05);
    final Path yellowPath = Path()
      ..moveTo(width * 0.24, height * 0.59)
      ..cubicTo(width * 0.22, height * 0.54, width * 0.22, height * 0.46, width * 0.24, height * 0.41)
      ..lineTo(width * 0.08, height * 0.29)
      ..cubicTo(width * 0.03, height * 0.39, width * 0.03, height * 0.61, width * 0.08, height * 0.71)
      ..lineTo(width * 0.24, height * 0.59);
    canvas.drawPath(yellowPath, paint);

    // Red
    paint.color = const Color(0xFFEA4335);
    final Path redPath = Path()
      ..moveTo(width * 0.5, height * 0.22)
      ..cubicTo(width * 0.57, height * 0.22, width * 0.63, height * 0.24, width * 0.68, height * 0.29)
      ..lineTo(width * 0.82, height * 0.15)
      ..cubicTo(width * 0.74, height * 0.07, width * 0.63, height * 0.04, width * 0.5, height * 0.04)
      ..cubicTo(width * 0.32, height * 0.04, width * 0.16, height * 0.14, width * 0.08, height * 0.29)
      ..lineTo(width * 0.24, height * 0.41)
      ..cubicTo(width * 0.28, height * 0.3, width * 0.38, height * 0.22, width * 0.5, height * 0.22);
    canvas.drawPath(redPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

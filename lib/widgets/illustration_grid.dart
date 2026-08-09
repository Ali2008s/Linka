import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SubstackLogoHeader extends StatelessWidget {
  const SubstackLogoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Substack Bookmark Logo
        Container(
          width: 44,
          height: 48,
          decoration: const BoxDecoration(
            color: AppColors.primaryOrange,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          child: CustomPaint(
            painter: BookmarkPainter(),
          ),
        ),
      ],
    );
  }
}

class BookmarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.fill;

    final path = Path();
    // Top bar cut
    path.moveTo(0, size.height * 0.38);
    path.lineTo(size.width, size.height * 0.38);
    path.lineTo(size.width, size.height * 0.46);
    path.lineTo(0, size.height * 0.46);
    path.close();

    // Bottom bookmark ribbon cut
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, size.height * 0.78);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height * 0.54);
    path.lineTo(0, size.height * 0.54);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class IllustrationGrid extends StatelessWidget {
  const IllustrationGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 250,
      padding: const EdgeInsets.all(8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Row 1 (Top)
          Positioned(
            left: 20,
            top: 10,
            child: _buildItemContainer(
              icon: Icons.window_outlined,
              accentColor: const Color(0xFFE11D74),
              size: 42,
            ),
          ),
          Positioned(
            top: 0,
            child: _buildIsometricStairs(Colors.tealAccent.shade700),
          ),
          Positioned(
            right: 20,
            top: 10,
            child: _buildItemContainer(
              icon: Icons.edit_outlined,
              accentColor: Colors.amber,
              size: 40,
            ),
          ),

          // Row 2 (Middle Top)
          Positioned(
            left: 30,
            top: 75,
            child: _buildItemContainer(
              icon: Icons.markunread_mailbox_outlined,
              accentColor: Colors.indigoAccent,
              size: 38,
            ),
          ),
          Positioned(
            top: 65,
            child: Icon(
              Icons.visibility_outlined,
              color: Colors.amber.shade600,
              size: 48,
            ),
          ),
          Positioned(
            right: 30,
            top: 75,
            child: _buildItemContainer(
              icon: Icons.menu_book_rounded,
              accentColor: Colors.white,
              size: 40,
            ),
          ),

          // Row 3 (Middle Bottom)
          Positioned(
            left: 25,
            top: 140,
            child: _buildItemContainer(
              icon: Icons.account_balance_outlined,
              accentColor: Colors.teal,
              size: 44,
            ),
          ),
          Positioned(
            top: 130,
            child: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(
                Icons.flag_rounded,
                color: AppColors.primaryOrange,
                size: 44,
              ),
            ),
          ),
          Positioned(
            right: 25,
            top: 140,
            child: _buildItemContainer(
              icon: Icons.description_outlined,
              accentColor: Colors.purpleAccent,
              size: 40,
            ),
          ),

          // Row 4 (Bottom)
          Positioned(
            top: 195,
            left: 100,
            child: Icon(
              Icons.draw_rounded,
              color: Colors.amber.shade700,
              size: 40,
            ),
          ),
          Positioned(
            top: 190,
            right: 60,
            child: _buildIsometricStairs(AppColors.primaryOrange),
          ),
        ],
      ),
    );
  }

  Widget _buildItemContainer({
    required IconData icon,
    required Color accentColor,
    required double size,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Icon(
        icon,
        color: accentColor,
        size: size,
      ),
    );
  }

  Widget _buildIsometricStairs(Color color) {
    return SizedBox(
      width: 40,
      height: 40,
      child: CustomPaint(
        painter: StairsPainter(color: color),
      ),
    );
  }
}

class StairsPainter extends CustomPainter {
  final Color color;
  StairsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width * 0.3, size.height * 0.7);
    path.lineTo(size.width * 0.3, size.height * 0.5);
    path.lineTo(size.width * 0.6, size.height * 0.3);
    path.lineTo(size.width * 0.6, size.height * 0.1);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.3);
    path.lineTo(size.width * 0.7, size.height * 0.6);
    path.lineTo(size.width * 0.4, size.height * 0.9);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

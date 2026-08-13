import 'package:flutter/material.dart';

class DoubleTapHeartOverlay extends StatefulWidget {
  final Widget child;
  final VoidCallback onDoubleTap;

  const DoubleTapHeartOverlay({
    super.key,
    required this.child,
    required this.onDoubleTap,
  });

  @override
  State<DoubleTapHeartOverlay> createState() => _DoubleTapHeartOverlayState();
}

class _DoubleTapHeartOverlayState extends State<DoubleTapHeartOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;
  Offset _heartPosition = Offset.zero;
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 30),
    ]).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    _opacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showHeart = false);
      }
    });
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    setState(() {
      _heartPosition = details.localPosition;
      _showHeart = true;
    });
    _animController.forward(from: 0.0);
    widget.onDoubleTap();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _handleDoubleTapDown,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          widget.child,
          if (_showHeart)
            Positioned(
              left: _heartPosition.dx - 50,
              top: _heartPosition.dy - 50,
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnim.value,
                    child: Opacity(
                      opacity: _opacityAnim.value,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x80E11D74),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Color(0xFFE11D74),
                          size: 100,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

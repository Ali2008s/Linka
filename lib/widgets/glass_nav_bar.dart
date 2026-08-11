import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/ios_helpers.dart';

class GlassNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const GlassNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class GlassNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlassNavItem> items;

  const GlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<GlassNavBar> createState() => _GlassNavBarState();
}

class _GlassNavBarState extends State<GlassNavBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _fadeAnims;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.items.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );

    _fadeAnims = _controllers
        .map((c) => Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: c, curve: Curves.easeOut),
            ))
        .toList();

    _controllers[widget.currentIndex].value = 1.0;
  }

  @override
  void didUpdateWidget(GlassNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _controllers[oldWidget.currentIndex].reverse();
      _controllers[widget.currentIndex].forward();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        // ممتد لكامل العرض مع هامش سفلي فقط
        padding: const EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: 14,
          top: 6,
        ),
        child: SizedBox(
          height: 66,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(33),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(33),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.20),
                      Colors.white.withValues(alpha: 0.07),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(
                    width: 1.0,
                    color: Colors.white.withValues(alpha: 0.28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.30),
                      blurRadius: 24,
                      spreadRadius: 0,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: const Color(0xFFE11D74).withValues(alpha: 0.10),
                      blurRadius: 20,
                      spreadRadius: -4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // ── Glare top shine line ──
                    Positioned(
                      top: 0,
                      left: 50,
                      right: 50,
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.65),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Nav Items Row ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 7),
                      child: Row(
                        children: List.generate(
                          widget.items.length,
                          (index) => _buildItem(index),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int index) {
    final isSelected = index == widget.currentIndex;
    final item = widget.items[index];

    return Expanded(
      // عدد flex مختلف: العنصر النشط يأخذ مساحة أوسع قليلاً
      flex: isSelected ? 2 : 1,
      child: GestureDetector(
        onTap: () {
          hapticSelection();
          widget.onTap(index);
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: isSelected
                ? Colors.white.withValues(alpha: 0.95)
                : Colors.transparent,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.55),
                      blurRadius: 14,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                    BoxShadow(
                      color: const Color(0xFFE11D74).withValues(alpha: 0.20),
                      blurRadius: 16,
                      spreadRadius: -2,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Center(
              child: isSelected
                  ? _buildActiveItem(item, index)
                  : _buildInactiveItem(item, index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveItem(GlassNavItem item, int index) {
    return FadeTransition(
      opacity: _fadeAnims[index],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.activeIcon,
            size: 20,
            color: const Color(0xFFE11D74),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFE11D74),
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInactiveItem(GlassNavItem item, int index) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: 1.0,
      child: Icon(
        item.icon,
        size: 22,
        color: Colors.white.withValues(alpha: 0.55),
      ),
    );
  }
}

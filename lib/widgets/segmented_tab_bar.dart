import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SegmentedTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final List<String> tabs;

  const SegmentedTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.surfaceDark : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  border: isSelected
                      ? Border.all(
                          color: AppColors.cardBorderFocused.withValues(alpha: 0.6),
                          width: 1.0,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      index == 0 ? Icons.alternate_email_rounded : Icons.phone_iphone_rounded,
                      size: 15,
                      color: isSelected ? AppColors.primaryOrange : AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tabs[index],
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

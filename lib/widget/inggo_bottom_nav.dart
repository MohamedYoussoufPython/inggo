import 'package:flutter/material.dart';
import '../theme/inggo_theme.dart';

class InggoBottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String? badge;

  const InggoBottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.badge,
  });
}

class InggoBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<InggoBottomNavItem> items;
  final ValueChanged<int> onTap;

  const InggoBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: InggoSpacing.sm,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: InggoColors.surface,
        borderRadius: BorderRadius.circular(InggoSpacing.lg),
        border: Border.all(color: InggoColors.border1),
        boxShadow: InggoShadows.level3,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isActive = index == currentIndex;

          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              borderRadius: BorderRadius.circular(InggoSpacing.sm),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: InggoSpacing.sm,
                  vertical: 6,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          isActive ? (item.activeIcon ?? item.icon) : item.icon,
                          size: 22,
                          color:
                              isActive ? InggoColors.text1 : InggoColors.text3,
                        ),
                        if (item.badge != null)
                          Positioned(
                            right: -6,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: InggoColors.error,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.badge!,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? InggoColors.text1 : InggoColors.text3,
                        fontFamily: InggoTextStyles.fontFamily,
                      ),
                    ),
                    const SizedBox(height: 2),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 20,
                      height: 3,
                      decoration: BoxDecoration(
                        color:
                            isActive ? InggoColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
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

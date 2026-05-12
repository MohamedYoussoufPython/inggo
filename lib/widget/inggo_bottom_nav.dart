import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/constants.dart';
import '../l10n/app_localizations.dart';

class InggoBottomNav extends StatelessWidget {
  final int currentIndex;
  final bool isDriver;

  const InggoBottomNav({
    super.key,
    required this.currentIndex,
    this.isDriver = false,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final items = isDriver
        ? _driverItems(loc)
        : _clientItems(loc);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [AppShadows.bottomNav],
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final selected = idx == currentIndex;
              return _NavItem(
                icon: item['icon'] as IconData,
                label: item['label'] as String,
                isSelected: selected,
                onTap: () {
                  // Home tab uses go() to reset stack; other tabs use push()
                  // to preserve navigation state when switching back.
                  if (item['route'] as String == (isDriver ? '/driver/home' : '/client/home')) {
                    context.go(item['route'] as String);
                  } else {
                    if (!selected) {
                      context.push(item['route'] as String);
                    }
                  }
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _clientItems(AppLocalizations loc) => [
        {'icon': Icons.home, 'label': loc.home, 'route': '/client/home'},
        {'icon': Icons.history, 'label': loc.history, 'route': '/client/history'},
        {'icon': Icons.favorite, 'label': loc.favorites, 'route': '/client/favorites'},
        {'icon': Icons.person, 'label': loc.profile, 'route': '/client/profile'},
      ];

  List<Map<String, dynamic>> _driverItems(AppLocalizations loc) => [
        {'icon': Icons.home, 'label': loc.home, 'route': '/driver/home'},
        {'icon': Icons.account_balance_wallet, 'label': loc.earnings, 'route': '/driver/earnings'},
        {'icon': Icons.description, 'label': loc.documents, 'route': '/driver/documents'},
        {'icon': Icons.person, 'label': loc.profile, 'route': '/driver/profile'},
      ];
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isSelected ? AppColors.primary : AppColors.textHint,
                size: 24.w),
            SizedBox(height: 2.h),
            Text(
              label,
              style: (isSelected ? AppTextStyles.labelSmall : AppTextStyles.caption)
                  .copyWith(
                color: isSelected ? AppColors.primary : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

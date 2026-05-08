import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/constants.dart';

class InggoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBack;
  final Color? backgroundColor;

  const InggoAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBack = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: AppTextStyles.headline4),
      centerTitle: true,
      backgroundColor: backgroundColor ?? AppColors.surface,
      elevation: 0,
      leading: leading ??
          (showBack && Navigator.canPop(context)
              ? IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: AppColors.textPrimary, size: 24.w),
                  onPressed: () => Navigator.pop(context),
                )
              : null),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Container(height: 1.h, color: AppColors.divider),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 1.h);
}

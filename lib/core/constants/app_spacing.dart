import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSpacing {
  AppSpacing._();

  // ── Padding / Margin ──
  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 12.w;
  static double get lg => 16.w;
  static double get xl => 20.w;
  static double get xxl => 24.w;
  static double get xxxl => 32.w;

  // ── Specific ──
  static double get screenPadding => 16.w;
  static double get cardPadding => 16.w;
  static double get buttonHeight => 48.h;
  static double get buttonHeightLarge => 52.h;
  static double get buttonHeightSmall => 34.h;
  static double get buttonIconSize => 44.h;
  static double get inputHeight => 48.h;
  static double get bottomNavHeight => 60.h;
  static double get appBarHeight => 56.h;

  // ── Border Radius ──
  static double get radiusSm => 8.r;
  static double get radiusMd => 12.r;
  static double get radiusLg => 16.r;
  static double get radiusXl => 24.r;
  static double get radiusFull => 999.r;

  // ── Icon sizes ──
  static double get iconSm => 16.w;
  static double get iconMd => 24.w;
  static double get iconLg => 32.w;
  static double get iconXl => 48.w;
  static double get iconAvatar => 60.w;
}

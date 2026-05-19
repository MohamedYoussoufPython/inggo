import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary ──
  static const Color primary       = Color(0xFFFFC700); // #FFC700
  static const Color primaryLight  = Color(0xFFFFF8E1); // #FFF8E1
  static const Color primaryBorder = Color(0xFFFFE070); // #FFE070
  static const Color primaryDark   = Color(0xFFB38A00); // #B38A00

  // ── Text ──
  static const Color textPrimary   = Color(0xFF1A1A1A); // #1A1A1A
  static const Color textSecondary = Color(0xFF555555); // #555555
  static const Color textHint      = Color(0xFF999999); // #999999
  static const Color textWhite     = Color(0xFFFFFFFF);

  // ── Backgrounds ──
  static const Color background    = Color(0xFFFAFAFA); // #FAFAFA
  static const Color surface       = Color(0xFFFFFFFF);

  // ── Borders ──
  static const Color border        = Color(0xFFE8E8E8); // #E8E8E8
  static const Color border2       = Color(0xFFD0D0D0); // #D0D0D0

  // ── Status ──
  static const Color success       = Color(0xFF16A34A); // #16A34A
  static const Color successLight  = Color(0xFFDCFCE7); // #DCFCE7
  static const Color successDark   = Color(0xFF166534); // #166534
  static const Color error         = Color(0xFFDC2626); // #DC2626
  static const Color errorLight    = Color(0xFFFEE2E2); // #FEE2E2
  static const Color errorDark     = Color(0xFF991B1B); // #991B1B
  static const Color warning       = Color(0xFFFF9800); // #FF9800
  static const Color info          = Color(0xFF2196F3); // #2196F3

  // ── Ride Status ──
  static const Color searching     = Color(0xFF2196F3);
  static const Color accepted      = Color(0xFF16A34A);
  static const Color inProgress    = Color(0xFF00BCD4);
  static const Color completed     = Color(0xFF16A34A);
  static const Color cancelled     = Color(0xFFDC2626);

  // ── Others ──
  static const Color overlay       = Color(0x80000000);
  static const Color overlayLight  = Color(0x33000000);
  static const Color divider       = border; // alias
  static const Color shadow        = Color(0x0F000000); // 6% opacity
  static const Color secondary     = textPrimary; // alias
}

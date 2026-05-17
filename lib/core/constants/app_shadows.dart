import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  // s1 design: 6% opacity
  static BoxShadow get sm => const BoxShadow(
        color: Color(0x0F000000),
        blurRadius: 3,
        offset: Offset(0, 1),
        spreadRadius: 0,
      );

  // s2 design: 8% opacity
  static BoxShadow get md => const BoxShadow(
        color: Color(0x14000000),
        blurRadius: 12,
        offset: Offset(0, 4),
      );

  // s3 design: 10% opacity
  static BoxShadow get lg => const BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 24,
        offset: Offset(0, 8),
      );

  // Card — même que sm
  static BoxShadow get card => const BoxShadow(
        color: Color(0x0F000000),
        blurRadius: 3,
        offset: Offset(0, 1),
        spreadRadius: 0,
      );
}

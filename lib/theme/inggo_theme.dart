import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InggoColors {
  InggoColors._();

  static const Color primary = Color(0xFFFFC700);
  static const Color primaryLight = Color(0xFFFFF8E1);
  static const Color primaryBorder = Color(0xFFFFE070);
  static const Color primaryDark = Color(0xFFB38A00);

  static const Color text1 = Color(0xFF1A1A1A);
  static const Color text2 = Color(0xFF555555);
  static const Color text3 = Color(0xFF999999);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFAFAFA);

  static const Color border1 = Color(0xFFE8E8E8);
  static const Color border2 = Color(0xFFD0D0D0);

  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successDark = Color(0xFF166534);

  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFF991B1B);

  static const Color warning = Color(0xFFFFC700);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color warningDark = Color(0xFFB38A00);
}

class InggoSpacing {
  InggoSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class InggoRadius {
  InggoRadius._();

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double pill = 100;

  static BorderRadius get xsBorder => BorderRadius.circular(xs);
  static BorderRadius get smBorder => BorderRadius.circular(sm);
  static BorderRadius get mdBorder => BorderRadius.circular(md);
  static BorderRadius get lgBorder => BorderRadius.circular(lg);
  static BorderRadius get pillBorder => BorderRadius.circular(pill);
}

class InggoShadows {
  InggoShadows._();

  static List<BoxShadow> get level0 => [];

  static List<BoxShadow> get level1 => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get level2 => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get level3 => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get level4 => [
        BoxShadow(
          color: InggoColors.primary.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}

class InggoTextStyles {
  InggoTextStyles._();

  static String get fontFamily => 'DM Sans';

  static TextStyle get h1 => GoogleFonts.dmSans(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: InggoColors.text1,
        letterSpacing: -0.5,
      );

  static TextStyle get h2 => GoogleFonts.dmSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: InggoColors.text1,
      );

  static TextStyle get h3 => GoogleFonts.dmSans(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: InggoColors.text1,
      );

  static TextStyle get body => GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: InggoColors.text2,
        height: 1.6,
      );

  static TextStyle get caption => GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: InggoColors.text3,
      );

  static TextStyle get label => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: InggoColors.text3,
        letterSpacing: 0.08,
      );

  static TextStyle get accent => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: InggoColors.primaryDark,
      );

  static TextStyle get button => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.01,
      );

  static TextStyle get buttonSmall => GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      );
}

class InggoTheme {
  InggoTheme._();

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: InggoTextStyles.fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: InggoColors.primary,
        primary: InggoColors.primary,
        secondary: InggoColors.primaryLight,
        surface: InggoColors.surface,
        error: InggoColors.error,
        onPrimary: InggoColors.text1,
        onSecondary: InggoColors.primaryDark,
        onSurface: InggoColors.text1,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: InggoColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: InggoColors.surface,
        foregroundColor: InggoColors.text1,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: InggoTextStyles.h3,
      ),
      cardTheme: CardThemeData(
        color: InggoColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: InggoRadius.mdBorder,
          side: const BorderSide(color: InggoColors.border1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: InggoColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: InggoSpacing.lg,
          vertical: InggoSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: InggoRadius.smBorder,
          borderSide: const BorderSide(color: InggoColors.border1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: InggoRadius.smBorder,
          borderSide: const BorderSide(color: InggoColors.border1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: InggoRadius.smBorder,
          borderSide: const BorderSide(color: InggoColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: InggoRadius.smBorder,
          borderSide: const BorderSide(color: InggoColors.error),
        ),
        hintStyle: InggoTextStyles.body.copyWith(color: InggoColors.text3),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: InggoColors.primary,
          foregroundColor: InggoColors.text1,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: InggoSpacing.xl,
            vertical: InggoSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: InggoRadius.smBorder,
          ),
          textStyle: InggoTextStyles.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: InggoColors.text1,
          padding: const EdgeInsets.symmetric(
            horizontal: InggoSpacing.xl,
            vertical: InggoSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: InggoRadius.smBorder,
          ),
          side: const BorderSide(color: InggoColors.border2),
          textStyle: InggoTextStyles.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: InggoColors.text3,
          textStyle: InggoTextStyles.button,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: InggoColors.surface,
        selectedItemColor: InggoColors.text1,
        unselectedItemColor: InggoColors.text3,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: InggoColors.border1,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(
        color: InggoColors.text2,
        size: 24,
      ),
    );
  }
}

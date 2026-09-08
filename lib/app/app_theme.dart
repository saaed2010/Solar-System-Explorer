import 'package:flutter/material.dart';

abstract final class AppColors {
  static const voidBlack = Color(0xFF03060D);
  static const deepSpace = Color(0xFF080E1C);
  static const panel = Color(0xE6121A2B);
  static const panelSoft = Color(0xB3141E32);
  static const line = Color(0xFF26354D);
  static const starlight = Color(0xFFF4F7FF);
  static const muted = Color(0xFF9EABC0);
  static const cyan = Color(0xFF78D9F5);
  static const amber = Color(0xFFFFC76A);
  static const violet = Color(0xFF9E9BFF);
}

abstract final class AppTheme {
  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.cyan,
      brightness: Brightness.dark,
      surface: AppColors.deepSpace,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme.copyWith(
        primary: AppColors.cyan,
        secondary: AppColors.amber,
        surface: AppColors.deepSpace,
        onSurface: AppColors.starlight,
        outline: AppColors.line,
      ),
      scaffoldBackgroundColor: AppColors.voidBlack,
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontSize: 34,
          height: 1.05,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.2,
          color: AppColors.starlight,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          height: 1.12,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
          color: AppColors.starlight,
        ),
        titleLarge: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: AppColors.starlight,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.starlight,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: Color(0xFFD9E2F0),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.45,
          color: AppColors.muted,
        ),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: const Color(0xF20A101D),
        indicatorColor: AppColors.cyan.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? AppColors.starlight
                : AppColors.muted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: const Color(0xF2080E1A),
        indicatorColor: AppColors.cyan.withValues(alpha: 0.14),
        selectedIconTheme: const IconThemeData(color: AppColors.cyan),
        unselectedIconTheme: const IconThemeData(color: AppColors.muted),
        selectedLabelTextStyle: const TextStyle(
          color: AppColors.starlight,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: AppColors.muted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.panelSoft,
        hintStyle: const TextStyle(color: AppColors.muted),
        prefixIconColor: AppColors.muted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.cyan),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.panelSoft,
        selectedColor: AppColors.cyan.withValues(alpha: 0.16),
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        labelStyle: const TextStyle(color: AppColors.starlight),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}

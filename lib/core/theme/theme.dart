import 'package:flutter/material.dart';

class FoodFlowColors extends ThemeExtension<FoodFlowColors> {
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color success;
  final Color error;
  final Color warning;
  final Color info;
  final Color background;
  final Color cardBackground;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;

  FoodFlowColors({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
    required this.background,
    required this.cardBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
  });

  @override
  ThemeExtension<FoodFlowColors> copyWith({
    Color? primary,
    Color? secondary,
    Color? tertiary,
    Color? success,
    Color? error,
    Color? warning,
    Color? info,
    Color? background,
    Color? cardBackground,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
  }) {
    return FoodFlowColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      background: background ?? this.background,
      cardBackground: cardBackground ?? this.cardBackground,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
    );
  }

  @override
  ThemeExtension<FoodFlowColors> lerp(
    covariant ThemeExtension<FoodFlowColors>? other,
    double t,
  ) {
    if (other is! FoodFlowColors) {
      return this;
    }

    return FoodFlowColors(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      background: Color.lerp(background, other.background, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }

  static FoodFlowColors light = FoodFlowColors(
    primary: Colors.amber,
    secondary: Color(0xFFFFC3A0),
    tertiary: Color(0xFFFFE0B2),
    success: Color(0xFFAED581),
    error: Color(0xFFEF9A9A),
    warning: Color(0xFFFFD54F),
    info: Color(0xFF81D4FA),
    background: Colors.white,
    cardBackground: Color(0xFFFFFBF2),
    textPrimary: Color(0xFF212121),
    textSecondary: Color(0xFF757575),
    border: Color(0xFFE0E0E0),
  );

  static FoodFlowColors dark = FoodFlowColors(
    primary: Color(0xFFFFD54F),
    secondary: Color(0xFFE6A570),
    tertiary: Color(0xFF604020),
    success: Color(0xFF7CB342),
    error: Color(0xFFE57373),
    warning: Color(0xFFFFA000),
    info: Color(0xFF4FC3F7),
    background: Color(0xFF121212),
    cardBackground: Color(0xFF1E1E1E),
    textPrimary: Color(0xFFF5F5F5),
    textSecondary: Color(0xFFBDBDBD),
    border: Color(0xFF424242),
  );
}

class FoodFlowTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: Colors.amber,
      colorScheme: ColorScheme.light(
        primary: FoodFlowColors.light.primary,
        secondary: FoodFlowColors.light.secondary,
        tertiary: FoodFlowColors.light.tertiary,
        error: FoodFlowColors.light.error,
        background: FoodFlowColors.light.background,
        surface: FoodFlowColors.light.cardBackground,
      ),
      scaffoldBackgroundColor: FoodFlowColors.light.background,
      cardColor: FoodFlowColors.light.cardBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: FoodFlowColors.light.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FoodFlowColors.light.primary,
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FoodFlowColors.light.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: FoodFlowColors.light.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: FoodFlowColors.light.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: FoodFlowColors.light.primary, width: 2),
        ),
      ),
      extensions: [FoodFlowColors.light],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: Colors.amber,
      colorScheme: ColorScheme.dark(
        primary: FoodFlowColors.dark.primary,
        secondary: FoodFlowColors.dark.secondary,
        tertiary: FoodFlowColors.dark.tertiary,
        error: FoodFlowColors.dark.error,
        background: FoodFlowColors.dark.background,
        surface: FoodFlowColors.dark.cardBackground,
      ),
      scaffoldBackgroundColor: FoodFlowColors.dark.background,
      cardColor: FoodFlowColors.dark.cardBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: FoodFlowColors.dark.cardBackground,
        foregroundColor: FoodFlowColors.dark.textPrimary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FoodFlowColors.dark.primary,
          foregroundColor: Colors.black,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FoodFlowColors.dark.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: FoodFlowColors.dark.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: FoodFlowColors.dark.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: FoodFlowColors.dark.primary, width: 2),
        ),
      ),
      extensions: [FoodFlowColors.dark],
    );
  }
}

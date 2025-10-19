import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_button_styles.dart';

/// 🌟 Application Theme – QuizDuel
/// Thème principal clair de l’application
class AppTheme {
  AppTheme._();

  /// 🌞 Thème clair global
  static final ThemeData light = ThemeData(
    useMaterial3: false,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto',

    // 🟣 Couleurs principales
    primaryColor: AppColors.primary,
    hintColor: AppColors.textHint,
    splashColor: AppColors.primaryLight.withOpacity(0.2),

    // 🌈 AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      elevation: 3,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: AppColors.white),
    ),

    // 🧱 CardThemeData (au lieu de CardTheme)
    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 4,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    // ✍️ TextTheme basé sur AppTextStyles
    textTheme: TextTheme(
      displayLarge: AppTextStyles.pageTitle, // titres d’écran
      headlineMedium: AppTextStyles.sectionTitle, // sous-titres
      titleLarge: AppTextStyles.listTitle, // titres de carte
      bodyMedium: AppTextStyles.subtitle, // texte normal
      bodySmall: AppTextStyles.smallLabel, // petits labels
      labelLarge: AppTextStyles.button, // boutons
    ),

    // 🔘 Elevated Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppButtonStyles.primary,
    ),

    // 🩵 Outlined Buttons
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: AppButtonStyles.outline,
    ),

    // 🟣 Text Buttons (liens “Forgot password?”, etc.)
    textButtonTheme: TextButtonThemeData(
      style: AppButtonStyles.transparent,
    ),

    // 🧾 Input Fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      hintStyle: AppTextStyles.hint,
      labelStyle: AppTextStyles.inputLabel,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.greyLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.greyLight),
      ),
      errorStyle: AppTextStyles.error,
      contentPadding:
      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    ),

    // 🧭 Icones par défaut
    iconTheme: const IconThemeData(color: AppColors.primary),

    // 🪟 Dialogues (DialogThemeData au lieu de DialogTheme)
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      titleTextStyle: AppTextStyles.sectionTitle,
      contentTextStyle: AppTextStyles.subtitle,
    ),

    // 🍞 SnackBar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.primary,
      contentTextStyle: const TextStyle(
        color: AppColors.white,
        fontWeight: FontWeight.bold,
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 4,
    ),

    // 🧍‍♂️ Progress Indicator
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.greyLight,
      circularTrackColor: AppColors.greyLight,
    ),
  );
}

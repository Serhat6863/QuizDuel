import 'package:flutter/material.dart';
import 'app_colors.dart';

/// ✨ Application Text Styles – QuizDuel
/// Centralisation de toutes les polices et styles de texte.
class AppTextStyles {
  AppTextStyles._(); // empêche l’instanciation

  // 🏠 -----------------------------------------------------------
  // TITRES / HEADERS
  // --------------------------------------------------------------

  /// Titre principal des pages ("QuizDuel", "Welcome Back!", etc.)
  static const TextStyle pageTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    letterSpacing: 0.5,
  );

  /// Sous-titre secondaire (utilisé pour des phrases de description)
  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  /// En-têtes colorés (Leaderboard, Available Rooms, etc.)
  static const TextStyle headerWhite = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static const TextStyle headerBlack = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  /// Titres moyens (ex: “Quick Actions”, “Players”, “Your Stats”)
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // 🧠 -----------------------------------------------------------
  // FORMULAIRES / LABELS / CHAMPS DE TEXTE
  // --------------------------------------------------------------

  static const TextStyle inputLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final TextStyle hint = TextStyle(
    fontSize: 14,
    color: AppColors.textHint,
  );

  static const TextStyle inputText = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static final TextStyle link = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryLight,
  );

  static final TextStyle error = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.red,
  );

  // 🚀 -----------------------------------------------------------
  // BOUTONS
  // --------------------------------------------------------------

  static const TextStyle button = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  // 🧩 -----------------------------------------------------------
  // LISTES / CARTES / ÉLÉMENTS
  // --------------------------------------------------------------

  static const TextStyle listTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle listSubtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle rankNumber = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  // 🕹️ -----------------------------------------------------------
  // QUIZ / GAME SCREEN
  // --------------------------------------------------------------

  static const TextStyle question = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle answer = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  static const TextStyle gameInfo = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static const TextStyle timer = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // 🏆 -----------------------------------------------------------
  // WINNER / LEADERBOARD
  // --------------------------------------------------------------

  static final TextStyle winnerTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.greenDark,
  );

  static const TextStyle leaderboardTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static const TextStyle playerScore = TextStyle(
    fontSize: 16,
    color: AppColors.textSecondary,
  );

  // 💬 -----------------------------------------------------------
  // FEEDBACK / STATUS / SNACKS
  // --------------------------------------------------------------

  static final TextStyle success = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: AppColors.green,
  );

  static final TextStyle warning = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: AppColors.amberLight,
  );

  static final TextStyle failure = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: AppColors.red,
  );

  // 💎 -----------------------------------------------------------
  // HOME / CARDS
  // --------------------------------------------------------------

  /// Texte clair pour titre de carte (ex: "Your Stats")
  static const TextStyle cardTitleLight = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  /// Texte clair pour sous-titre de carte (ex: "Keep climbing...")
  static final TextStyle subtitleLight = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.white70,
  );

  /// Grand nombre blanc (ex: Score, Level, etc.)
  static const TextStyle bigNumber = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  // 💎 -----------------------------------------------------------
  // PETITS LABELS / TEXTE SECONDAIRE
  // --------------------------------------------------------------

  static final TextStyle smallLabel = TextStyle(
    fontSize: 13,
    color: AppColors.white70,
  );
}

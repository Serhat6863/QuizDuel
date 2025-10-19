import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// 🎯 Centralisation de tous les styles de boutons de l’app
/// Compatible avec ElevatedButton, OutlinedButton, TextButton
class AppButtonStyles {
  AppButtonStyles._(); // empêche l’instanciation

  // 🟣 ------------------------------------------------------------
  // BOUTONS PRINCIPAUX (ex: Login, Register, Start Game)
  // --------------------------------------------------------------
  static final ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.white,
    textStyle: AppTextStyles.button,
    padding: const EdgeInsets.symmetric(vertical: 15),
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  );

  // 🟢 ------------------------------------------------------------
  // BOUTONS DE SUCCÈS (ex: Create Room, Validations)
  // --------------------------------------------------------------
  static final ButtonStyle success = ElevatedButton.styleFrom(
    backgroundColor: AppColors.green,
    foregroundColor: AppColors.white,
    textStyle: AppTextStyles.button,
    padding: const EdgeInsets.symmetric(vertical: 15),
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  );

  // 🔴 ------------------------------------------------------------
  // BOUTONS DANGER / SUPPRESSION / QUITTER
  // --------------------------------------------------------------
  static final ButtonStyle danger = ElevatedButton.styleFrom(
    backgroundColor: AppColors.red,
    foregroundColor: AppColors.white,
    textStyle: AppTextStyles.button,
    padding: const EdgeInsets.symmetric(vertical: 15),
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  );

  // 🟡 ------------------------------------------------------------
  // BOUTONS SECONDAIRES (ex: Browse Rooms, Join, Leaderboard)
  // --------------------------------------------------------------
  static final ButtonStyle secondary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.amber,
    foregroundColor: AppColors.white,
    textStyle: AppTextStyles.button,
    padding: const EdgeInsets.symmetric(vertical: 15),
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  );

  // 🩵 ------------------------------------------------------------
  // BOUTONS INFO (ex: View Leaderboard, blue)
  // --------------------------------------------------------------
  static final ButtonStyle info = ElevatedButton.styleFrom(
    backgroundColor: AppColors.blue,
    foregroundColor: AppColors.white,
    textStyle: AppTextStyles.button,
    padding: const EdgeInsets.symmetric(vertical: 15),
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  );

  // ⚪ ------------------------------------------------------------
  // BOUTONS OUTLINE (ex: "I’ve verified my email")
  // --------------------------------------------------------------
  static final ButtonStyle outline = OutlinedButton.styleFrom(
    side: BorderSide(color: AppColors.primary, width: 2),
    padding: const EdgeInsets.symmetric(vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    textStyle: AppTextStyles.button,
    foregroundColor: AppColors.primary,
  );

  // 🔲 ------------------------------------------------------------
  // BOUTONS GLASS / TRANSLUCIDES (ex: Logout, BackButton)
  // --------------------------------------------------------------
  static final ButtonStyle glass = ElevatedButton.styleFrom(
    backgroundColor: AppColors.white.withOpacity(0.15),
    foregroundColor: AppColors.primary,
    padding: const EdgeInsets.all(8),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: AppColors.white.withOpacity(0.25)),
    ),
  );

  // 🔘 ------------------------------------------------------------
  // PETITS BOUTONS (Resend email, Cancel, etc.)
  // --------------------------------------------------------------
  static final ButtonStyle small = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryLight,
    foregroundColor: AppColors.white,
    textStyle: AppTextStyles.buttonSmall,
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );

  // 🔁 ------------------------------------------------------------
  // BOUTONS TRANSPARENTS (ex: TextButton ou actions secondaires)
  // --------------------------------------------------------------
  static final ButtonStyle transparent = TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    textStyle: AppTextStyles.link,
    padding: EdgeInsets.zero,
  );

  // 🧩 ------------------------------------------------------------
  // MÉTHODE PERSONNALISÉE (permet d’utiliser n’importe quelle couleur)
  // --------------------------------------------------------------
  static ButtonStyle colored(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: AppColors.white,
      textStyle: AppTextStyles.button,
      padding: const EdgeInsets.symmetric(vertical: 15),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}

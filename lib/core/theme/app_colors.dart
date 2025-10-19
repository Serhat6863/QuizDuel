import 'package:flutter/material.dart';

/// 🎨 Application Color Palette – QuizDuel
/// Centralisation de toutes les couleurs utilisées dans l’app.
class AppColors {
  AppColors._(); // empêche l’instanciation

  // Fond global
  static const Color background = Color(0xFFF5E6C4);

  // Fonds neutres
  static const Color white = Colors.white;
  static final Color white70 = Colors.white70;

  // Textes
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static final Color textHint = Colors.grey.shade600;

  // Couleurs principales
  static const Color primary = Colors.deepPurple;
  static final Color primaryLight = Colors.deepPurple.shade300;
  static final Color primaryDark = Colors.deepPurple.shade700;

  // Accent secondaire
  static const Color secondary = Colors.purpleAccent;

  // Couleurs bleues
  static final Color blue = Colors.blue.shade600;
  static final Color blueLight = Colors.blue.shade400;
  static final Color blueLighter = Colors.blue.shade200;
  static final Color blueGrey = Colors.blueGrey.shade200;

  // filled text field
  static final Color filledTextField = Colors.black87;

  //surface
  static const Color surfaceDark = Color(0xFF3E4A59); // gris bleuté foncé pour cartes et containers


  // Couleurs vertes (succès, création de room, start game)
  static final Color green = Colors.green.shade600;
  static final Color greenDark = Colors.green.shade700;

  // Couleurs rouges (erreur, suppression, quitter)
  static final Color red = Colors.red.shade600;

  // Couleurs or / ambrées
  static final Color amber = Colors.amber.shade600;
  static final Color amberLight = Colors.amber.shade400;
  static final Color gold = Colors.amber.shade700;

  // Couleurs marron / bronze (3e place)
  static final Color brown = Colors.brown.shade400;

  // Teal / turquoise (état de room)
  static final Color teal = Colors.teal.shade600;

  // Gris et nuances
  static final Color grey = Colors.grey.shade400;
  static final Color greyLight = Colors.grey.shade300;
  static final Color greyDark = Colors.grey.shade800;

  // Ombres / transparences
  static final Color shadowLight = Colors.black.withOpacity(0.05);
  static final Color shadow = Colors.black.withOpacity(0.1);
  static final Color shadowStrong = Colors.black.withOpacity(0.25);
  static const Color transparent = Colors.transparent;


  // ☕ Couleur bronze clair pour le 3e joueur du podium
  static const Color brownLight = Color(0xFF8D6E63);

// 💨 Ombre douce pour les cartes / containers
  static final Color shadowSoft = Colors.black.withOpacity(0.08);


  // Fond des cartes RoomList
  static const Color cardDark = Color(0xFF3E4A59);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Colors.deepPurple, Colors.purpleAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Colors.blue, Colors.lightBlueAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [Colors.amber, Colors.orangeAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Utilitaire pour rendre l'UI responsive sur tablette et petits écrans.
/// Utilisez ResponsiveHelper.scale(context, value) pour adapter une taille.
/// Utilisez ResponsiveHelper.textScale(context, value) pour adapter une taille de texte.

import 'package:flutter/material.dart';

class ResponsiveHelper {
  /// Scale une valeur (padding, taille, etc.) selon la largeur de l'écran.
  static double scale(BuildContext context, double value) {
    final width = MediaQuery.of(context).size.width;
    // Référence : 375 (iPhone), 600 (petite tablette)
    if (width >= 900) {
      // Grande tablette ou desktop
      return value * 1.5;
    } else if (width >= 600) {
      // Tablette
      return value * 1.2;
    } else if (width < 320) {
      // Très petit écran
      return value * 0.85;
    } else {
      // Téléphone standard
      return value;
    }
  }

  /// Scale une taille de texte selon la largeur de l'écran.
  static double textScale(BuildContext context, double value) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) {
      return value * 1.4;
    } else if (width >= 600) {
      return value * 1.15;
    } else if (width < 320) {
      return value * 0.85;
    } else {
      return value;
    }
  }
}

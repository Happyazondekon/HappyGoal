import 'dart:math';

import 'game_state.dart'; // pour ShotDirection et ShotEffect

class AIOpponent {
  final Random _random = Random();

  // Niveau d'intelligence de l'IA (0.0 = totalement aléatoire, 1.0 = parfaite)
  final double intelligence;

  AIOpponent({this.intelligence = 0.6}); // 60% d'intelligence par défaut

  Map<String, dynamic> takeShot() {
    // L'IA décide la direction
    int direction;
    if (_random.nextDouble() < intelligence) {
      // Plus intelligent => vise souvent le centre ou droite/gauche précis
      direction = _random.nextBool() ? ShotDirection.left : ShotDirection.right;
    } else {
      direction = ShotDirection.center;
    }

    // L'IA décide la puissance
    int power;
    if (_random.nextDouble() < intelligence) {
      power = 70 + _random.nextInt(30); // Tir puissant
    } else {
      power = 30 + _random.nextInt(40); // Tir moyen ou faible
    }

    // L'IA choisit un effet
    String effect;
    double roll = _random.nextDouble();
    if (roll < 0.4) {
      effect = ShotEffect.normal;
    } else if (roll < 0.6) {
      effect = ShotEffect.curve;
    } else if (roll < 0.8) {
      effect = ShotEffect.lob;
    } else {
      effect = ShotEffect.knuckle;
    }

    return {
      'direction': direction,
      'power': power,
      'effect': effect,
    };
  }
}

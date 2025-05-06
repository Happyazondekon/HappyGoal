import 'dart:math';

import 'game_state.dart'; // pour ShotDirection et ShotEffect

class AIOpponent {
  final Random _random = Random();

  // Niveau d'intelligence de l'IA (0.0 = totalement aléatoire, 1.0 = parfaite)
  final double intelligence;

  // Variables pour adapter le comportement de l'IA
  int _previousDirection = -1;
  int _consecutiveSameDirection = 0;
  List<String> _recentEffects = [];
  int _shotsTaken = 0;
  bool _lastShotWasGoal = false;

  AIOpponent({this.intelligence = 0.6}); // 60% d'intelligence par défaut

  Map<String, dynamic> takeShot() {
    _shotsTaken++;

    // ---- DIRECTION AVANCÉE ----
    int direction;
    double directionChoice = _random.nextDouble();

    // L'IA évite de tirer dans la même direction plusieurs fois de suite
    if (_previousDirection != -1 && _consecutiveSameDirection >= 1 && _random.nextDouble() < intelligence * 0.9) {
      // Choisit délibérément une direction différente
      List<int> otherDirections = [0, 1, 2]..remove(_previousDirection);
      direction = otherDirections[_random.nextInt(otherDirections.length)];
    }
    // Si l'IA est intelligente, elle évite plus le centre
    else if (directionChoice < intelligence * 0.9) {
      // Choix intelligent - évite le centre presque toujours
      direction = _random.nextBool() ? ShotDirection.left : ShotDirection.right;
    }
    // Parfois l'IA tire au centre mais rarement
    else if (directionChoice < intelligence) {
      // Choix semi-intelligent
      List<int> directions = [ShotDirection.left, ShotDirection.right];
      if (_random.nextDouble() > 0.8) {
        directions.add(ShotDirection.center);
      }
      direction = directions[_random.nextInt(directions.length)];
    }
    else {
      // Choix aléatoire - plus souvent centre
      direction = _random.nextBool() ? ShotDirection.center :
      (_random.nextBool() ? ShotDirection.left : ShotDirection.right);
    }

    // Garde une trace de la direction choisie
    if (direction == _previousDirection) {
      _consecutiveSameDirection++;
    } else {
      _previousDirection = direction;
      _consecutiveSameDirection = 0;
    }

    // ---- PUISSANCE ADAPTATIVE ----
    int power;

    // L'IA intelligente choisit une puissance optimale en fonction de la situation
    if (_random.nextDouble() < intelligence * 0.9) {
      // Tir puissant mais contrôlé
      power = 70 + _random.nextInt(25);

      // Parfois l'IA tente un tir très puissant, surtout si elle est en retard
      if (_random.nextDouble() < intelligence * 0.4) {
        power = 85 + _random.nextInt(15);
      }
    }
    // Si le dernier tir était réussi, elle peut reprendre la même stratégie
    else if (_lastShotWasGoal && _random.nextDouble() < intelligence * 0.7) {
      power = 65 + _random.nextInt(30);
    }
    else {
      // Tir moyen ou faible - même l'IA avancée peut faire des erreurs
      power = 40 + _random.nextInt(40);
    }

    // ---- EFFETS ADAPTIFS ----
    String effect;

    // Plus l'IA est intelligente, plus elle utilise des effets variés et avancés
    double effectChoice = _random.nextDouble();

    // Intelligence élevée = plus d'effets spéciaux stratégiques
    if (effectChoice < intelligence * 0.6) {
      // Utilise des effets plus avancés
      double specialEffect = _random.nextDouble();

      // Évite d'utiliser trop souvent le même effet
      List<String> availableEffects = [ShotEffect.curve, ShotEffect.lob, ShotEffect.knuckle];
      availableEffects.removeWhere((e) => _recentEffects.contains(e));

      if (availableEffects.isEmpty) {
        availableEffects = [ShotEffect.curve, ShotEffect.lob, ShotEffect.knuckle];
      }

      // Préférence pour le knuckle qui est plus difficile à arrêter
      if (specialEffect < 0.5) {
        effect = ShotEffect.knuckle;
      } else if (specialEffect < 0.8) {
        effect = ShotEffect.curve;
      } else {
        effect = ShotEffect.lob;
      }
    }
    // Parfois utilise un tir normal pour varier
    else if (effectChoice < 0.9) {
      effect = ShotEffect.normal;
    }
    // Fallback - tir normal
    else {
      effect = ShotEffect.normal;
    }

    // Mémorise l'effet utilisé pour éviter la répétition
    _recentEffects.add(effect);
    if (_recentEffects.length > 2) {
      _recentEffects.removeAt(0);
    }

    return {
      'direction': direction,
      'power': power,
      'effect': effect,
    };
  }

  // Permet de signaler à l'IA si son dernier tir était réussi
  void setLastShotResult(bool wasGoal) {
    _lastShotWasGoal = wasGoal;
  }

  // Analyse les tirs précédents pour prédire la direction du gardien
  int predictGoalkeeperMove(List<int> previousGoalkeeperMoves) {
    if (previousGoalkeeperMoves.isEmpty || _random.nextDouble() > intelligence * 0.8) {
      // Si pas d'historique ou IA pas assez intelligente, choix aléatoire
      return _random.nextInt(3);
    }

    // Analyse basique des tendances du gardien
    Map<int, int> moveFrequency = {0: 0, 1: 0, 2: 0};

    for (int move in previousGoalkeeperMoves) {
      moveFrequency[move] = (moveFrequency[move] ?? 0) + 1;
    }

    // Trouve la direction la moins utilisée par le gardien
    int leastUsedDirection = 1; // Par défaut centre
    int minFrequency = previousGoalkeeperMoves.length;

    moveFrequency.forEach((direction, frequency) {
      if (frequency < minFrequency) {
        minFrequency = frequency;
        leastUsedDirection = direction;
      }
    });

    // L'IA avancée tente de tirer là où le gardien va le moins souvent
    if (_random.nextDouble() < intelligence * 0.7) {
      return leastUsedDirection;
    }

    // Sinon décision aléatoire avec biais vers les coins
    return _random.nextBool() ? ShotDirection.left : ShotDirection.right;
  }
}
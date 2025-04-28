import 'team.dart';
import 'ai_opponent.dart'; // Ajout pour utiliser l'IA

enum GamePhase {
  notStarted,
  teamSelection,
  playerShooting,
  goalkeeeperSaving,
  goalScored,
  goalSaved,
  gameOver,
}

class ShotDirection {
  static const int left = 0;
  static const int center = 1;
  static const int right = 2;
}

class ShotEffect {
  static const String normal = 'normal';
  static const String curve = 'curve';
  static const String lob = 'lob';
  static const String knuckle = 'knuckle';

  static List<String> getAllEffects() {
    return [normal, curve, lob, knuckle];
  }

  static String getDisplayName(String effect) {
    switch (effect) {
      case normal: return 'Normal';
      case curve: return 'Effet';
      case lob: return 'Lob';
      case knuckle: return 'Knuckle';
      default: return effect;
    }
  }
}

class PenaltySettings {
  static const int shotsPerTeam = 5;
  static const int minPower = 0;
  static const int maxPower = 100;
  static const int defaultPower = 50;
}

class SuddenDeathSettings {
  static const int shotsPerRound = 1;
}

class GameState {
  Team? team1;
  Team? team2;
  Team? currentTeam;
  GamePhase currentPhase;
  int roundNumber;
  int team1Shots;
  int team2Shots;
  int selectedDirection;
  bool isGoalScored;
  int goalkeepeerDirection;

  int shotPower;
  String shotEffect;
  double shotPrecision;

  // ➡️ Nouvelles propriétés pour IA
  bool isSoloMode = false;
  AIOpponent? aiOpponent;

  Map<String, int> team1EffectUsage = {};
  Map<String, int> team2EffectUsage = {};
  int team1PowerfulShots = 0;
  int team2PowerfulShots = 0;
  int team1AccurateShots = 0;
  int team2AccurateShots = 0;

  List<bool> team1Results = [];
  List<bool> team2Results = [];
  List<bool> team1SuddenDeathResults = [];
  List<bool> team2SuddenDeathResults = [];
  bool isSuddenDeathActive = false;

  List<ShotData> team1ShotData = [];
  List<ShotData> team2ShotData = [];

  GameState({
    this.team1,
    this.team2,
    this.currentPhase = GamePhase.notStarted,
    this.roundNumber = 0,
    this.team1Shots = 0,
    this.team2Shots = 0,
    this.selectedDirection = ShotDirection.center,
    this.isGoalScored = false,
    this.goalkeepeerDirection = ShotDirection.center,
    this.shotPower = PenaltySettings.defaultPower,
    this.shotEffect = ShotEffect.normal,
    this.shotPrecision = 1.0,
    this.isSoloMode = false, // ⚡ ajouté ici
  }) {
    currentTeam = team1;

    // Initialiser l'IA si en mode solo
    if (isSoloMode) {
      aiOpponent = AIOpponent();
    }

    for (String effect in ShotEffect.getAllEffects()) {
      team1EffectUsage[effect] = 0;
      team2EffectUsage[effect] = 0;
    }
  }

  void switchTeam() {
    currentTeam = (currentTeam == team1) ? team2 : team1;
  }

  void recordShotResult(bool isGoal) {
    ShotData shotData = ShotData(
      direction: selectedDirection,
      power: shotPower,
      effect: shotEffect,
      precision: shotPrecision,
      goalkeeeperDirection: goalkeepeerDirection,
      isGoal: isGoal,
    );

    if (currentTeam == team1) {
      if (isSuddenDeathActive) {
        team1SuddenDeathResults.add(isGoal);
      } else {
        team1Results.add(isGoal);
      }
      team1Shots++;
      if (isGoal) team1?.incrementScore();

      team1ShotData.add(shotData);
      team1EffectUsage[shotEffect] = (team1EffectUsage[shotEffect] ?? 0) + 1;
      if (shotPower > 70) team1PowerfulShots++;
      if (shotPrecision > 0.8) team1AccurateShots++;
    } else {
      if (isSuddenDeathActive) {
        team2SuddenDeathResults.add(isGoal);
      } else {
        team2Results.add(isGoal);
      }
      team2Shots++;
      if (isGoal) team2?.incrementScore();

      team2ShotData.add(shotData);
      team2EffectUsage[shotEffect] = (team2EffectUsage[shotEffect] ?? 0) + 1;
      if (shotPower > 70) team2PowerfulShots++;
      if (shotPrecision > 0.8) team2AccurateShots++;
    }
  }

  bool isRegularPhase() => team1Shots < PenaltySettings.shotsPerTeam || team2Shots < PenaltySettings.shotsPerTeam;
  bool isSuddenDeathPhase() => !isRegularPhase();

  bool checkWinner() {
    if (team1?.score == null || team2?.score == null) return false;

    if (isRegularPhase()) {
      int team1Remaining = PenaltySettings.shotsPerTeam - team1Shots;
      int team2Remaining = PenaltySettings.shotsPerTeam - team2Shots;

      // Victoire anticipée si une équipe ne peut plus être rattrapée
      if (team1!.score > team2!.score + team2Remaining) return true;
      if (team2!.score > team1!.score + team1Remaining) return true;
    }

    if (team1Shots == PenaltySettings.shotsPerTeam &&
        team2Shots == PenaltySettings.shotsPerTeam) {
      if (team1!.score != team2!.score) {
        return true; // Vainqueur après tirs complets
      } else {
        if (!isSuddenDeathActive) {
          isSuddenDeathActive = true;
        }
      }
    }

    // Vérification en mort subite
    if (isSuddenDeathActive) {
      int suddenDeathRound = team1SuddenDeathResults.length;
      if (team2SuddenDeathResults.length == suddenDeathRound && suddenDeathRound > 0) {
        bool team1Last = team1SuddenDeathResults[suddenDeathRound - 1];
        bool team2Last = team2SuddenDeathResults[suddenDeathRound - 1];

        if (team1Last && !team2Last) return true;
        if (!team1Last && team2Last) return true;
      }
    }

    return false;
  }

  Team? getWinner() {
    if (team1?.score == null || team2?.score == null) return null;

    if (!isSuddenDeathActive) {
      if (team1!.score > team2!.score) return team1;
      if (team2!.score > team1!.score) return team2;
    } else {
      int lastRound = team1SuddenDeathResults.length - 1;
      if (lastRound >= 0 && team2SuddenDeathResults.length > lastRound) {
        bool team1Last = team1SuddenDeathResults[lastRound];
        bool team2Last = team2SuddenDeathResults[lastRound];

        if (team1Last && !team2Last) return team1;
        if (!team1Last && team2Last) return team2;
      }
    }

    return null;
  }

  bool shouldStartNewRound() {
    if (team1Shots == PenaltySettings.shotsPerTeam &&
        team2Shots == PenaltySettings.shotsPerTeam &&
        !isSuddenDeathActive &&
        team1?.score == team2?.score) {
      isSuddenDeathActive = true;
      roundNumber = 1;
      return true;
    }

    if (isSuddenDeathActive) {
      int suddenDeathRound = team1SuddenDeathResults.length;
      if (team2SuddenDeathResults.length == suddenDeathRound && currentTeam == team1) {
        roundNumber++;
        return true;
      }
    } else if (team1Shots % SuddenDeathSettings.shotsPerRound == 0 &&
        team2Shots % SuddenDeathSettings.shotsPerRound == 0 &&
        currentTeam == team1) {
      roundNumber++;
      return true;
    }

    return false;
  }

  // Méthode pour calculer la chance de marquer un but en fonction des paramètres du tir
  double calculateScoringChance() {
    // Base chance
    double chance = 0.5;

    // Si le gardien va dans la mauvaise direction, énorme avantage
    if (selectedDirection != goalkeepeerDirection) {
      chance += 0.4;
    } else {
      // Si le gardien va dans la bonne direction, c'est plus difficile
      chance -= 0.3;
    }

    // Les effets peuvent augmenter les chances de marquer
    switch (shotEffect) {
      case ShotEffect.curve: chance += 0.15; break;
      case ShotEffect.knuckle: chance += 0.2; break;
      case ShotEffect.lob: chance += 0.1; break;
    }

    // La puissance a un impact
    if (shotPower > 80) {
      chance += 0.1; // Tir puissant difficile à arrêter
    } else if (shotPower < 30) {
      chance -= 0.2; // Tir faible facile à arrêter
    }

    // La précision influence beaucoup
    chance *= shotPrecision;

    // Limiter entre 0.05 (toujours une petite chance) et 0.95 (toujours un risque)
    return chance.clamp(0.05, 0.95);
  }


  // Calculer la déviation du tir basée sur la précision ET la puissance
  Map<String, double> calculateShotDeviation() {
    double deviationFactor = 1.0 - shotPrecision;
    double xDeviation = 0.0;
    double yDeviation = 0.0;

    if (shotPrecision < 1.0) {
      xDeviation = deviationFactor * (DateTime.now().millisecondsSinceEpoch % 100) / 50.0 - 1.0;
      yDeviation = deviationFactor * (DateTime.now().millisecondsSinceEpoch % 71) / 35.0 - 1.0;
    }

    // 🔥 Nouvelle logique : augmenter les risques si tir très puissant
    if (shotPower > 80) {
      xDeviation *= 1.5; // Tir très fort = balle moins contrôlée horizontalement
      yDeviation *= 1.2; // Tir très fort = risque de tirer au-dessus
    }

    // 🔥 BONUS : tirs ultra faibles peuvent aussi dévier (par faiblesse)
    if (shotPower < 20) {
      xDeviation *= 1.3;
      yDeviation *= 1.1;
    }

    return {
      'x': xDeviation * 60, // étendu (avant c'était 50)
      'y': yDeviation * 40, // étendu (avant c'était 30)
    };
  }


  void reset() {
    team1?.resetScore();
    team2?.resetScore();
    currentTeam = team1;
    roundNumber = 1;
    team1Shots = 0;
    team2Shots = 0;
    shotPower = PenaltySettings.defaultPower;
    shotEffect = ShotEffect.normal;
    shotPrecision = 1.0;
    team1Results.clear();
    team2Results.clear();
    team1SuddenDeathResults.clear();
    team2SuddenDeathResults.clear();
    team1ShotData.clear();
    team2ShotData.clear();

    // Réinitialiser les statistiques
    for (String effect in ShotEffect.getAllEffects()) {
      team1EffectUsage[effect] = 0;
      team2EffectUsage[effect] = 0;
    }
    team1PowerfulShots = 0;
    team2PowerfulShots = 0;
    team1AccurateShots = 0;
    team2AccurateShots = 0;

    isSuddenDeathActive = false;
    currentPhase = GamePhase.teamSelection;
  }
// 🔥 Ajouter méthode pour IA
  Map<String, dynamic> getAIDecision() {
    if (!isSoloMode || aiOpponent == null) {
      return {
        'direction': ShotDirection.center,
        'power': PenaltySettings.defaultPower,
        'effect': ShotEffect.normal,
      };
    }
    return aiOpponent!.takeShot();
  }
  // Obtenir des statistiques sur l'efficacité d'un type d'effet
  Map<String, dynamic> getEffectStats(String effect) {
    int team1Count = team1EffectUsage[effect] ?? 0;
    int team2Count = team2EffectUsage[effect] ?? 0;

    int team1Goals = 0;
    int team2Goals = 0;

    // Compter les buts marqués avec cet effet
    for (var shot in team1ShotData) {
      if (shot.effect == effect && shot.isGoal) {
        team1Goals++;
      }
    }

    for (var shot in team2ShotData) {
      if (shot.effect == effect && shot.isGoal) {
        team2Goals++;
      }
    }

    return {
      'team1Usage': team1Count,
      'team2Usage': team2Count,
      'team1Goals': team1Goals,
      'team2Goals': team2Goals,
      'team1SuccessRate': team1Count > 0 ? team1Goals / team1Count : 0.0,
      'team2SuccessRate': team2Count > 0 ? team2Goals / team2Count : 0.0,
    };
  }
}

// Classe pour stocker les données détaillées d'un tir
class ShotData {
  final int direction;
  final int power;
  final String effect;
  final double precision;
  final int goalkeeeperDirection;
  final bool isGoal;

  ShotData({
    required this.direction,
    required this.power,
    required this.effect,
    required this.precision,
    required this.goalkeeeperDirection,
    required this.isGoal,
  });
}
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
    this.isSoloMode = false,
    double? aiIntelligenceLevel, // Nouveau paramètre optionnel
  }) {
    currentTeam = team1;

    // Initialiser l'IA si en mode solo avec l'intelligence spécifiée
    if (isSoloMode) {
      aiOpponent = AIOpponent(intelligence: aiIntelligenceLevel ?? 0.6);
    }

    for (String effect in ShotEffect.getAllEffects()) {
      team1EffectUsage[effect] = 0;
      team2EffectUsage[effect] = 0;
    }
  }
  double? get aiIntelligenceLevel => aiOpponent?.intelligence;
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
    // Base chance réduite pour augmenter la difficulté
    double chance = 0.4; // Avant: 0.5

    // Si le gardien va dans la mauvaise direction, avantage réduit
    if (selectedDirection != goalkeepeerDirection) {
      chance += 0.35; // Avant: 0.4
    } else {
      // Si le gardien va dans la bonne direction, c'est encore plus difficile
      chance -= 0.35; // Avant: 0.3
    }

    // Les effets peuvent augmenter les chances de marquer mais avec un bonus réduit
    switch (shotEffect) {
      case ShotEffect.curve: chance += 0.12; break; // Avant: 0.15
      case ShotEffect.knuckle: chance += 0.15; break; // Avant: 0.2
      case ShotEffect.lob: chance += 0.08; break; // Avant: 0.1
    }
    if (shotPower > 95) {
      // NOUVELLE CONDITION: Pénalité sévère pour les tirs à très haute puissance
      chance -= 0.7; // Grande pénalité pour rendre ces tirs très difficiles
    }
    // La puissance a un impact ajusté
    if (shotPower > 85) { // Seuil plus élevé (avant: 80)
      chance += 0.08; // Réduit (avant: 0.1)
    } else if (shotPower < 40) { // Seuil plus élevé (avant: 30)
      chance -= 0.25; // Pénalité accrue (avant: 0.2)
    } else if (shotPower < 60) {
      // Nouvelle condition: les tirs moyens sont aussi moins efficaces
      chance -= 0.1;
    }

    // La précision influence encore plus
    // Avec une fonction exponentielle pour pénaliser davantage les tirs moins précis
    chance *= (shotPrecision * shotPrecision);

    // Limiter entre 0.03 (chance réduite) et 0.9 (toujours un risque accru)
    return chance.clamp(0.03, 0.9); // Avant: 0.05 à 0.95
  }


  // 2. Améliorer calculateShotDeviation() pour plus de variations
  Map<String, double> calculateShotDeviation() {
    // Facteur de déviation de base augmenté
    double deviationFactor = 1.2 - shotPrecision; // Avant: 1.0 - shotPrecision
    double xDeviation = 0.0;
    double yDeviation = 0.0;

    if (shotPrecision < 1.0) {
      // Ajout d'un peu plus d'aléatoire pour augmenter la difficulté
      xDeviation = deviationFactor * (DateTime.now().millisecondsSinceEpoch % 120) / 50.0 - 1.2;
      yDeviation = deviationFactor * (DateTime.now().millisecondsSinceEpoch % 90) / 35.0 - 1.2;
    }

    // Augmenter l'impact de la puissance sur la déviation
    if (shotPower > 75) { // Seuil réduit (avant: 80)
      xDeviation *= 1.8; // Augmenté (avant: 1.5)
      yDeviation *= 1.5; // Augmenté (avant: 1.2)
    } else if (shotPower > 60) {
      // Nouvelle condition: même les tirs moyennement puissants ont une déviation
      xDeviation *= 1.3;
      yDeviation *= 1.2;
    }

    // Tirs faibles encore plus variables
    if (shotPower < 30) { // Seuil augmenté (avant: 20)
      xDeviation *= 1.5; // Augmenté (avant: 1.3)
      yDeviation *= 1.3; // Augmenté (avant: 1.1)
    }

    // Ajout d'une variable aléatoire supplémentaire pour créer des situations inattendues
    if (DateTime.now().millisecondsSinceEpoch % 10 == 0) {
      // 10% de chance que le tir dévie encore plus
      xDeviation *= 1.5;
      yDeviation *= 1.5;
    }

    return {
      'x': xDeviation * 70, // Étendu davantage (avant: 60)
      'y': yDeviation * 50, // Étendu davantage (avant: 40)
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
// 3. Modifier getAIDecision pour utiliser la prédiction des mouvements du gardien
  Map<String, dynamic> getAIDecision() {
    if (!isSoloMode || aiOpponent == null) {
      return {
        'direction': ShotDirection.center,
        'power': PenaltySettings.defaultPower,
        'effect': ShotEffect.normal,
      };
    }

    // Récupérer l'historique des mouvements du gardien
    List<int> goalkeeperHistory = [];

    // Pour l'équipe 2 (IA), nous examinons les tirs précédents de l'équipe 1
    for (var shot in team1ShotData) {
      goalkeeperHistory.add(shot.goalkeeeperDirection);
    }

    // Utiliser les données pour une décision plus intelligente
    var decision = aiOpponent!.takeShot();

    // Enregistrer le résultat du dernier tir pour adapter la stratégie
    if (team2ShotData.isNotEmpty) {
      aiOpponent!.setLastShotResult(team2ShotData.last.isGoal);
    }

    return decision;
  }
  // 4. Ajouter une nouvelle méthode pour calculer la difficulté du gardien de but
  double calculateGoalkeeperDifficulty() {
    // Difficulté de base plus élevée
    double difficulty = 0.6; // Base difficulty - plus élevée qu'avant

    // Ajuster en fonction de la situation de jeu
    if (isSuddenDeathActive) {
      difficulty += 0.20; // Plus difficile en mort subite
    }

    // Plus le match avance, plus le gardien devient difficile
    double progressionFactor = (team1Shots + team2Shots) / (PenaltySettings.shotsPerTeam * 2);
    difficulty += progressionFactor * 0.15;

    // Difficulté supplémentaire pour les tirs classiques
    if (shotEffect == ShotEffect.normal) {
      difficulty += 0.30; // Gardien plus efficace contre les tirs normaux
    }

    // Clamper entre 0.4 et 0.95 pour garder un équilibre
    return difficulty.clamp(0.4, 0.95);
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
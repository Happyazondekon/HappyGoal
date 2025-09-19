// game_state.dart - VERSION CORRIGÉE
import 'team.dart';
import 'ai_opponent.dart';

enum GamePhase {
  notStarted,
  teamSelection,
  playerShooting,
  goalkeepeerSaving,
  humanGoalkeeping,
  goalScored,
  goalSaved,
  gameOver,
}

enum TournamentPhase {
  notStarted,
  roundOf16,
  quarterFinals,
  semiFinals,
  finalMatch,
  finished
}

class TournamentState {
  final List<Team> allTeams;
  List<Team> remainingTeams;
  TournamentPhase currentPhase;
  Team? userTeam;
  Team? currentOpponent;
  int userWins = 0;
  int aiWins = 0;
  int currentMatchInPhase = 0;

  TournamentState({
    required this.allTeams,
    required this.userTeam,
  })  : remainingTeams = List.from(allTeams)..remove(userTeam),
        currentPhase = TournamentPhase.notStarted;

  void startTournament() {
    remainingTeams = List.from(allTeams)..remove(userTeam);
    remainingTeams.shuffle();
    _setNextValidOpponent();
    currentPhase = TournamentPhase.roundOf16;
    currentMatchInPhase = 1;

    print('🏆 Début du tournoi - ${remainingTeams.length} adversaires');
    print('🥅 Premier adversaire: ${currentOpponent?.name}');
  }

  void _setNextValidOpponent() {
    if (remainingTeams.isEmpty) return;

    for (var team in remainingTeams) {
      if (team != userTeam) {
        currentOpponent = team;
        break;
      }
    }
  }

  void advanceToNextRound(bool userWon) {
    print('📝 Résultat du match: ${userWon ? "Victoire" : "Défaite"} contre ${currentOpponent?.name}');

    if (userWon) {
      userWins++;
      print('✅ Victoires utilisateur: $userWins');
    } else {
      aiWins++;
      print('❌ L\'utilisateur a perdu - Tournoi terminé');
      currentPhase = TournamentPhase.finished;
      return;
    }

    remainingTeams.remove(currentOpponent);
    currentMatchInPhase++;

    print('🔄 Adversaires restants: ${remainingTeams.length}');

    if (_shouldAdvanceToNextPhase()) {
      _advancePhase();
    }

    if (remainingTeams.isEmpty || currentPhase == TournamentPhase.finished) {
      print('🏆 TOURNOI TERMINÉ !');
      currentPhase = TournamentPhase.finished;
      return;
    }

    currentOpponent = remainingTeams.first;
    print('⚽ Prochain adversaire: ${currentOpponent?.name} (${getPhaseName()})');
  }

  bool _shouldAdvanceToNextPhase() {
    switch (currentPhase) {
      case TournamentPhase.roundOf16:
        return currentMatchInPhase > _getMatchesInPhase(TournamentPhase.roundOf16);
      case TournamentPhase.quarterFinals:
        return currentMatchInPhase > _getMatchesInPhase(TournamentPhase.quarterFinals);
      case TournamentPhase.semiFinals:
        return currentMatchInPhase > _getMatchesInPhase(TournamentPhase.semiFinals);
      case TournamentPhase.finalMatch:
        return true;
      default:
        return false;
    }
  }

  int _getMatchesInPhase(TournamentPhase phase) {
    switch (phase) {
      case TournamentPhase.roundOf16:
        return 1;
      case TournamentPhase.quarterFinals:
        return 1;
      case TournamentPhase.semiFinals:
        return 1;
      case TournamentPhase.finalMatch:
        return 1;
      default:
        return 0;
    }
  }

  void _advancePhase() {
    currentMatchInPhase = 1;

    switch (currentPhase) {
      case TournamentPhase.roundOf16:
        currentPhase = TournamentPhase.quarterFinals;
        print('🥉 PASSAGE AUX QUARTS DE FINALE !');
        break;
      case TournamentPhase.quarterFinals:
        currentPhase = TournamentPhase.semiFinals;
        print('🥉 PASSAGE AUX DEMI-FINALES !');
        break;
      case TournamentPhase.semiFinals:
        currentPhase = TournamentPhase.finalMatch;
        print('🥉 PASSAGE EN FINALE !');
        break;
      case TournamentPhase.finalMatch:
        currentPhase = TournamentPhase.finished;
        print('🏆 TOURNOI TERMINÉ !');
        break;
      default:
        break;
    }
  }

  String getPhaseName() {
    switch (currentPhase) {
      case TournamentPhase.roundOf16:
        return 'Huitièmes de finale';
      case TournamentPhase.quarterFinals:
        return 'Quarts de finale';
      case TournamentPhase.semiFinals:
        return 'Demi-finales';
      case TournamentPhase.finalMatch:
        return 'Finale';
      case TournamentPhase.finished:
        return 'Tournoi terminé';
      default:
        return 'Tournoi';
    }
  }

  String getMatchInfo() {
    if (currentOpponent == null) return '';
    return '${userTeam?.name} vs ${currentOpponent?.name}';
  }

  String getTournamentProgress() {
    switch (currentPhase) {
      case TournamentPhase.roundOf16:
        return 'Match $currentMatchInPhase/1 - Huitièmes';
      case TournamentPhase.quarterFinals:
        return 'Match $currentMatchInPhase/1 - Quarts';
      case TournamentPhase.semiFinals:
        return 'Match $currentMatchInPhase/1 - Demis';
      case TournamentPhase.finalMatch:
        return 'FINALE';
      default:
        return getPhaseName();
    }
  }
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

// CORRECTION: Version simplifiée de GameStateSnapshot
class GameStateSnapshot {
  final int team1Score;
  final int team2Score;
  final List<bool> team1Results;
  final List<bool> team2Results;
  final List<bool> team1SuddenDeathResults;
  final List<bool> team2SuddenDeathResults;
  final int team1Shots;
  final int team2Shots;
  final Team? currentTeam;
  final GamePhase currentPhase;
  final int roundNumber;
  final bool isSuddenDeathActive;
  final List<ShotData> team1ShotData;
  final List<ShotData> team2ShotData;

  GameStateSnapshot({
    required this.team1Score,
    required this.team2Score,
    required this.team1Results,
    required this.team2Results,
    required this.team1SuddenDeathResults,
    required this.team2SuddenDeathResults,
    required this.team1Shots,
    required this.team2Shots,
    required this.currentTeam,
    required this.currentPhase,
    required this.roundNumber,
    required this.isSuddenDeathActive,
    required this.team1ShotData,
    required this.team2ShotData,
  });
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

  // Nouvelles propriétés pour IA
  bool isSoloMode = false;
  AIOpponent? aiOpponent;
  TournamentState? tournamentState;
  bool isTournamentMode = false;

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

  // CORRECTION: Système de rembobinage simplifié
  GameStateSnapshot? _lastSnapshot;
  bool _canRewind = false;

  // CORRECTION: Getter simplifié pour le rembobinage
  bool get canRewind => _canRewind && _lastSnapshot != null;

  // CORRECTION: Sauvegarder l'état avant un tir - TOUJOURS
  void saveStateBeforeShot() {
    print("💾 GameState: Sauvegarde de l'état avant le tir");

    _lastSnapshot = GameStateSnapshot(
      team1Score: team1?.score ?? 0,
      team2Score: team2?.score ?? 0,
      team1Results: List.from(team1Results),
      team2Results: List.from(team2Results),
      team1SuddenDeathResults: List.from(team1SuddenDeathResults),
      team2SuddenDeathResults: List.from(team2SuddenDeathResults),
      team1Shots: team1Shots,
      team2Shots: team2Shots,
      currentTeam: currentTeam,
      currentPhase: currentPhase,
      roundNumber: roundNumber,
      isSuddenDeathActive: isSuddenDeathActive,
      team1ShotData: List.from(team1ShotData),
      team2ShotData: List.from(team2ShotData),
    );

    _canRewind = true;
    print("✅ GameState: État sauvegardé, rembobinage disponible");
  }

  // CORRECTION: Restaurer l'état précédent - logique simplifiée
  bool rewindToLastShot() {
    print("🔄 GameState: Tentative de restauration...");

    if (!canRewind || _lastSnapshot == null) {
      print("❌ GameState: Impossible de rembobiner (pas de sauvegarde)");
      return false;
    }

    // Restaurer tous les états depuis la sauvegarde
    team1?.resetScore();
    team2?.resetScore();

    // Restaurer les scores depuis la sauvegarde
    for (int i = 0; i < _lastSnapshot!.team1Results.length; i++) {
      if (_lastSnapshot!.team1Results[i]) {
        team1?.incrementScore();
      }
    }
    for (int i = 0; i < _lastSnapshot!.team2Results.length; i++) {
      if (_lastSnapshot!.team2Results[i]) {
        team2?.incrementScore();
      }
    }

    team1Results = List.from(_lastSnapshot!.team1Results);
    team2Results = List.from(_lastSnapshot!.team2Results);
    team1SuddenDeathResults = List.from(_lastSnapshot!.team1SuddenDeathResults);
    team2SuddenDeathResults = List.from(_lastSnapshot!.team2SuddenDeathResults);
    team1Shots = _lastSnapshot!.team1Shots;
    team2Shots = _lastSnapshot!.team2Shots;
    currentTeam = _lastSnapshot!.currentTeam;
    currentPhase = _lastSnapshot!.currentPhase;
    roundNumber = _lastSnapshot!.roundNumber;
    isSuddenDeathActive = _lastSnapshot!.isSuddenDeathActive;
    team1ShotData = List.from(_lastSnapshot!.team1ShotData);
    team2ShotData = List.from(_lastSnapshot!.team2ShotData);

    // Invalider la sauvegarde après utilisation
    invalidateSnapshot();

    print("✅ GameState: État restauré avec succès");
    return true;
  }

  // Invalider la sauvegarde
  void invalidateSnapshot() {
    _canRewind = false;
    _lastSnapshot = null;
    print("🗑️ GameState: Sauvegarde invalidée");
  }

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
    double? aiIntelligenceLevel,
    required bool isTournamentMode,
  }) {
    this.isSoloMode = isTournamentMode ? true : isSoloMode;
    this.isTournamentMode = isTournamentMode;
    currentTeam = team1;

    if (this.isSoloMode || this.isTournamentMode) {
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
      goalkeepeerDirection: goalkeepeerDirection,
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

      if (team1!.score > team2!.score + team2Remaining) return true;
      if (team2!.score > team1!.score + team1Remaining) return true;
    }

    if (team1Shots == PenaltySettings.shotsPerTeam &&
        team2Shots == PenaltySettings.shotsPerTeam) {
      if (team1!.score != team2!.score) {
        return true;
      } else {
        if (!isSuddenDeathActive) {
          isSuddenDeathActive = true;
        }
      }
    }

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

  double calculateScoringChance() {
    double chance = 0.4;

    if (selectedDirection != goalkeepeerDirection) {
      chance += 0.35;
    } else {
      chance -= 0.35;
    }

    switch (shotEffect) {
      case ShotEffect.curve: chance += 0.12; break;
      case ShotEffect.knuckle: chance += 0.15; break;
      case ShotEffect.lob: chance += 0.08; break;
    }

    if (shotPower > 95) {
      chance -= 0.7;
    }

    if (shotPower > 85) {
      chance += 0.08;
    } else if (shotPower < 40) {
      chance -= 0.25;
    } else if (shotPower < 60) {
      chance -= 0.1;
    }

    chance *= (shotPrecision * shotPrecision);

    return chance.clamp(0.03, 0.9);
  }

  Map<String, double> calculateShotDeviation() {
    double deviationFactor = 1.2 - shotPrecision;
    double xDeviation = 0.0;
    double yDeviation = 0.0;

    if (shotPrecision < 1.0) {
      xDeviation = deviationFactor * (DateTime.now().millisecondsSinceEpoch % 120) / 50.0 - 1.2;
      yDeviation = deviationFactor * (DateTime.now().millisecondsSinceEpoch % 90) / 35.0 - 1.2;
    }

    if (shotPower > 75) {
      xDeviation *= 1.8;
      yDeviation *= 1.5;
    } else if (shotPower > 60) {
      xDeviation *= 1.3;
      yDeviation *= 1.2;
    }

    if (shotPower < 30) {
      xDeviation *= 1.5;
      yDeviation *= 1.3;
    }

    if (DateTime.now().millisecondsSinceEpoch % 10 == 0) {
      xDeviation *= 1.5;
      yDeviation *= 1.5;
    }

    return {
      'x': xDeviation * 70,
      'y': yDeviation * 50,
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

    // Réinitialisation de l'état de rembobinage
    invalidateSnapshot();
  }

  Map<String, dynamic> getAIDecision() {
    if (!isSoloMode || aiOpponent == null) {
      return {
        'direction': ShotDirection.center,
        'power': PenaltySettings.defaultPower,
        'effect': ShotEffect.normal,
      };
    }

    List<int> goalkeeperHistory = [];

    for (var shot in team1ShotData) {
      goalkeeperHistory.add(shot.goalkeepeerDirection);
    }

    var decision = aiOpponent!.takeShot();

    if (team2ShotData.isNotEmpty) {
      aiOpponent!.setLastShotResult(team2ShotData.last.isGoal);
    }

    return decision;
  }

  double calculateGoalkeeperDifficulty() {
    double difficulty = 0.6;

    if (isSuddenDeathActive) {
      difficulty += 0.20;
    }

    double progressionFactor = (team1Shots + team2Shots) / (PenaltySettings.shotsPerTeam * 2);
    difficulty += progressionFactor * 0.15;

    if (shotEffect == ShotEffect.normal) {
      difficulty += 0.30;
    }

    return difficulty.clamp(0.4, 0.95);
  }

  Map<String, dynamic> getEffectStats(String effect) {
    int team1Count = team1EffectUsage[effect] ?? 0;
    int team2Count = team2EffectUsage[effect] ?? 0;

    int team1Goals = 0;
    int team2Goals = 0;

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

class ShotData {
  final int direction;
  final int power;
  final String effect;
  final double precision;
  final int goalkeepeerDirection;
  final bool isGoal;

  ShotData({
    required this.direction,
    required this.power,
    required this.effect,
    required this.precision,
    required this.goalkeepeerDirection,
    required this.isGoal,
  });

}
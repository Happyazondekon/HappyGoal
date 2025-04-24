import 'team.dart';

enum GamePhase {
  notStarted,
  teamSelection,
  playerShooting,
  goalkeeeperSaving,
  goalScored,
  goalSaved,
  gameOver,
}
class PenaltySettings {
  static const int shotsPerTeam = 5;  // 5 tirs par équipe en phase régulière
}

class SuddenDeathSettings {
  static const int shotsPerRound = 1;  // 1 tir par équipe par round en mort subite
}


class GameState {
  Team? team1;
  Team? team2;
  Team? currentTeam;
  GamePhase currentPhase;
  int roundNumber;  // Numéro de la ronde actuelle (1-5 pour les tirs normaux, > 5 pour les tirs de mort subite)
  int team1Shots;   // Nombre de tirs effectués par l'équipe 1
  int team2Shots;   // Nombre de tirs effectués par l'équipe 2
  int selectedDirection;
  bool isGoalScored;
  int goalkeepeerDirection;

  // Pour suivre les résultats des tirs
  List<bool> team1Results = [];  // true = but marqué, false = tir raté
  List<bool> team2Results = [];  // true = but marqué, false = tir raté
  List<bool> team1SuddenDeathResults = [];
  List<bool> team2SuddenDeathResults = [];
  bool isSuddenDeathActive = false;
  GameState({
    this.team1,
    this.team2,
    this.currentPhase = GamePhase.notStarted,
    this.roundNumber = 1,
    this.team1Shots = 0,
    this.team2Shots = 0,
    this.selectedDirection = 1, // Default to center
    this.isGoalScored = false,
    this.goalkeepeerDirection = 1,
  }) {
    currentTeam = team1;
  }

  void switchTeam() {
    currentTeam = (currentTeam == team1) ? team2 : team1;
  }

  void recordShotResult(bool isGoal) {
    if (currentTeam == team1) {
      if (isSuddenDeathActive) {
        team1SuddenDeathResults.add(isGoal);
      } else {
        team1Results.add(isGoal);
      }
      team1Shots++;
      if (isGoal) team1?.incrementScore();
    } else {
      if (isSuddenDeathActive) {
        team2SuddenDeathResults.add(isGoal);
      } else {
        team2Results.add(isGoal);
      }
      team2Shots++;
      if (isGoal) team2?.incrementScore();
    }
  }

  bool isRegularPhase() {
    return team1Shots < PenaltySettings.shotsPerTeam || team2Shots < PenaltySettings.shotsPerTeam;
  }

  bool isSuddenDeathPhase() {
    return !isRegularPhase();
  }

  bool checkWinner() {
    if (isRegularPhase()) {
      // Pendant la phase régulière (5 tirs)
      // Si une équipe ne peut plus rattraper l'autre même en marquant tous ses tirs restants
      int team1Remaining = PenaltySettings.shotsPerTeam - team1Shots;
      int team2Remaining = PenaltySettings.shotsPerTeam - team2Shots;

      if (team1?.score != null && team2?.score != null) {
        if (team1!.score > team2!.score + team2Remaining) return true;
        if (team2!.score > team1!.score + team1Remaining) return true;
      }

      // Si les deux équipes ont tiré leurs 5 tirs et ont un score différent
      if (team1Shots == PenaltySettings.shotsPerTeam &&
          team2Shots == PenaltySettings.shotsPerTeam &&
          team1?.score != team2?.score) {
        return true;
      }

      // Si égalité après 5 tirs, activer la mort subite
      if (team1Shots == PenaltySettings.shotsPerTeam &&
          team2Shots == PenaltySettings.shotsPerTeam &&
          team1?.score == team2?.score) {
        isSuddenDeathActive = true;
      }
    }
    else {
      // En mort subite - vérifier après que chaque équipe ait tiré
      int suddenDeathRound = team1SuddenDeathResults.length;

      // S'assurer que les deux équipes ont tiré dans ce round de mort subite
      if (team2SuddenDeathResults.length == suddenDeathRound && suddenDeathRound > 0) {
        // Comparer les résultats du dernier round
        bool team1LastResult = team1SuddenDeathResults[suddenDeathRound - 1];
        bool team2LastResult = team2SuddenDeathResults[suddenDeathRound - 1];

        // Si une équipe marque et l'autre rate, nous avons un gagnant
        if (team1LastResult && !team2LastResult) return true;
        if (!team1LastResult && team2LastResult) return true;
      }
    }

    return false;
  }

  Team? getWinner() {
    if (team1?.score == null || team2?.score == null) return null;

    // En phase régulière, le vainqueur est celui avec le plus de points
    if (!isSuddenDeathActive) {
      if (team1!.score > team2!.score) return team1;
      if (team2!.score > team1!.score) return team2;
    }
    // En mort subite, comparons le dernier tir
    else {
      int lastRound = team1SuddenDeathResults.length - 1;
      if (lastRound >= 0 && team2SuddenDeathResults.length > lastRound) {
        bool team1LastResult = team1SuddenDeathResults[lastRound];
        bool team2LastResult = team2SuddenDeathResults[lastRound];

        if (team1LastResult && !team2LastResult) return team1;
        if (!team1LastResult && team2LastResult) return team2;
      }
    }

    return null;
  }

  bool shouldStartNewRound() {
    // Au début de la mort subite
    if (team1Shots == PenaltySettings.shotsPerTeam &&
        team2Shots == PenaltySettings.shotsPerTeam &&
        !isSuddenDeathActive &&
        team1?.score == team2?.score) {
      isSuddenDeathActive = true;
      roundNumber = 1; // Redémarrer le compteur pour la mort subite
      return true;
    }

    // Pendant la mort subite
    if (isSuddenDeathActive) {
      // Si les deux équipes ont tiré dans ce round de mort subite
      int suddenDeathRound = team1SuddenDeathResults.length;
      if (team2SuddenDeathResults.length == suddenDeathRound && currentTeam == team1) {
        roundNumber++;
        return true;
      }
    }
    // En phase régulière
    else if (team1Shots % SuddenDeathSettings.shotsPerRound == 0 &&
        team2Shots % SuddenDeathSettings.shotsPerRound == 0 &&
        currentTeam == team1) {
      roundNumber++;
      return true;
    }

    return false;
  }

  void reset() {
    team1?.resetScore();
    team2?.resetScore();
    currentTeam = team1;
    roundNumber = 1;
    team1Shots = 0;
    team2Shots = 0;
    team1Results.clear();
    team2Results.clear();
    team1SuddenDeathResults.clear();
    team2SuddenDeathResults.clear();
    isSuddenDeathActive = false;
    currentPhase = GamePhase.teamSelection;
  }
}
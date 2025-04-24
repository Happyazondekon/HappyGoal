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
  static const int shotsPerTeam = 5;
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

  List<bool> team1Results = [];
  List<bool> team2Results = [];
  List<bool> team1SuddenDeathResults = [];
  List<bool> team2SuddenDeathResults = [];
  bool isSuddenDeathActive = false;

  GameState({
    this.team1,
    this.team2,
    this.currentPhase = GamePhase.notStarted,
    this.roundNumber = 0,
    this.team1Shots = 0,
    this.team2Shots = 0,
    this.selectedDirection = 1,
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

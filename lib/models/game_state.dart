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

class GameState {
  Team? team1;
  Team? team2;
  Team? currentTeam;
  GamePhase currentPhase;
  int roundCount;
  int selectedDirection;
  bool isGoalScored;
  int goalkeepeerDirection;

  GameState({
    this.team1,
    this.team2,
    this.currentPhase = GamePhase.notStarted,
    this.roundCount = 0,
    this.selectedDirection = 1, // Default to center
    this.isGoalScored = false,
    this.goalkeepeerDirection = 1,
  }) {
    currentTeam = team1;
  }

  void switchTeam() {
    currentTeam = (currentTeam == team1) ? team2 : team1;
  }

  bool checkWinner() {
    return (team1?.score == GameSettings.winningScore ||
        team2?.score == GameSettings.winningScore);
  }

  Team? getWinner() {
    if (team1?.score == GameSettings.winningScore) return team1;
    if (team2?.score == GameSettings.winningScore) return team2;
    return null;
  }

  void reset() {
    team1?.resetScore();
    team2?.resetScore();
    currentTeam = team1;
    roundCount = 0;
    currentPhase = GamePhase.teamSelection;
  }
}

class GameSettings {
  static const int winningScore = 5;
}
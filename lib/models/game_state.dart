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
  int roundNumber;  // Numéro de la ronde actuelle (1-5 pour les tirs normaux, > 5 pour les tirs de mort subite)
  int team1Shots;   // Nombre de tirs effectués par l'équipe 1
  int team2Shots;   // Nombre de tirs effectués par l'équipe 2
  int selectedDirection;
  bool isGoalScored;
  int goalkeepeerDirection;

  // Pour suivre les résultats des tirs
  List<bool> team1Results = [];  // true = but marqué, false = tir raté
  List<bool> team2Results = [];  // true = but marqué, false = tir raté

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
      team1Results.add(isGoal);
      team1Shots++;
      if (isGoal) team1?.incrementScore();
    } else {
      team2Results.add(isGoal);
      team2Shots++;
      if (isGoal) team2?.incrementScore();
    }
  }

  bool isRegularPhase() {
    return roundNumber <= PenaltySettings.shotsPerTeam;
  }

  bool isSuddenDeathPhase() {
    return roundNumber > PenaltySettings.shotsPerTeam;
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
    }
    else {
      // En mode mort subite (après les 5 tirs)
      // Les deux équipes doivent avoir tiré le même nombre de fois dans le round actuel
      if (team1Shots == team2Shots && team1Shots > PenaltySettings.shotsPerTeam && team2Shots > PenaltySettings.shotsPerTeam) {
        // Obtenir les résultats du dernier tir pour chaque équipe
        // Nous devons calculer l'index en fonction du nombre de tirs effectués
        int lastTeam1Index = team1Results.length - 1;
        int lastTeam2Index = team2Results.length - 1;

        // S'assurer que nous avons des résultats à comparer
        if (lastTeam1Index >= 0 && lastTeam2Index >= 0) {
          bool team1LastResult = team1Results[lastTeam1Index];
          bool team2LastResult = team2Results[lastTeam2Index];

          // Si un marque et l'autre rate, nous avons un gagnant
          if (team1LastResult && !team2LastResult) return true;
          if (!team1LastResult && team2LastResult) return true;

          // Si les deux marquent ou les deux ratent, on continue
          // donc on retourne false
        }
      }
    }

    return false;
  }


  Team? getWinner() {
    if (team1?.score == null || team2?.score == null) return null;

    if (team1!.score > team2!.score) return team1;
    if (team2!.score > team1!.score) return team2;
    return null;
  }

  bool shouldStartNewRound() {
    // Si les deux équipes ont tiré dans ce round, passez au suivant
    if (team1Shots == team2Shots && currentTeam == team1) {
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
    currentPhase = GamePhase.teamSelection;
  }
}

class PenaltySettings {
  static const int shotsPerTeam = 5;  // 5 tirs par équipe en phase régulière
}
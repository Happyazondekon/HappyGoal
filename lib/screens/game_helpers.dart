import 'package:flutter/material.dart';
import 'package:happygoal/constants.dart' hide ShotDirection;
import 'package:happygoal/models/game_state.dart';


class GameHelpers {
  static Color getOpponentTeamColor(GameState gameState) {
    if (gameState.currentTeam == gameState.team1) {
      return gameState.team2!.color;
    } else {
      return gameState.team1!.color;
    }
  }



  static String getRoundText(GameState gameState) {
    if (gameState.isSuddenDeathPhase()) {
      return 'Tour de départage ${gameState.roundNumber - PenaltySettings.shotsPerTeam}';
    } else {
      return 'Tour ${gameState.roundNumber}/${PenaltySettings.shotsPerTeam}';
    }
  }



  static bool shouldShowShotControls(GameState gameState) {
    // En mode Hero, Solo ou Tournoi : seulement team1 (le joueur humain) voit les contrôles
    final bool isHumanTurn = (gameState.isSoloMode || gameState.isTournamentMode || gameState.isHeroMode)
        ? gameState.currentTeam == gameState.team1
        : true;
    final debug = '[DEBUG shouldShowShotControls] phase: \\${gameState.currentPhase} | team: \\${gameState.currentTeam?.name} | isSolo: \\${gameState.isSoloMode} | isHero: \\${gameState.isHeroMode} | isTournament: \\${gameState.isTournamentMode} | isHumanTurn: \\${isHumanTurn}';
    // ignore: avoid_print
    print(debug);
    return gameState.currentPhase == GamePhase.playerShooting && isHumanTurn;
  }

  static bool shouldShowResultText(GameState gameState) {
    return gameState.currentPhase == GamePhase.goalScored ||
        gameState.currentPhase == GamePhase.goalSaved;
  }

  static bool shouldShowGoalkeeperControls(GameState gameState) {
    return gameState.currentPhase == GamePhase.humanGoalkeeping;
  }

  static bool shouldShowAIIndicator(GameState gameState) {
    return (gameState.isSoloMode || gameState.isTournamentMode) &&
        gameState.currentTeam == gameState.team2 &&
        (gameState.currentPhase == GamePhase.playerShooting ||
            gameState.currentPhase == GamePhase.humanGoalkeeping);
  }
}
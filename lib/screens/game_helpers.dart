import 'package:flutter/material.dart';
import '../constants.dart' hide ShotDirection;
import '../models/game_state.dart';

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

  static bool shouldShowAIIndicator(GameState gameState) {
    return (gameState.isSoloMode || gameState.isTournamentMode) &&
        gameState.currentTeam == gameState.team2 &&
        gameState.currentPhase == GamePhase.playerShooting;
  }

  static bool shouldShowShotControls(GameState gameState) {
    return gameState.currentPhase == GamePhase.playerShooting &&
        (gameState.currentTeam == gameState.team1 ||
            (!gameState.isSoloMode && !gameState.isTournamentMode));
  }

  static bool shouldShowResultText(GameState gameState) {
    return gameState.currentPhase == GamePhase.goalScored ||
        gameState.currentPhase == GamePhase.goalSaved;
  }
}
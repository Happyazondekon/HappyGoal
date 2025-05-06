import 'package:firebase_analytics/firebase_analytics.dart';

/// Service qui gère toutes les interactions avec Firebase Analytics
class AnalyticsService {
  static late FirebaseAnalytics _analytics;

  /// Initialise le service avec une instance de FirebaseAnalytics
  static void initialize(FirebaseAnalytics analytics) {
    _analytics = analytics;
  }

  /// Enregistre l'ouverture de l'application
  static Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  /// Enregistre la mise en arrière-plan de l'application
  static Future<void> logAppBackground() async {
    await _analytics.logEvent(name: 'app_background');
  }

  /// Enregistre la remise au premier plan de l'application
  static Future<void> logAppForeground() async {
    await _analytics.logEvent(name: 'app_foreground');
  }

  /// Enregistre le début d'une partie
  static Future<void> logGameStart({
    required String gameMode, // 'solo' ou 'multi'
    required String team1Name,
    required String team2Name,
  }) async {
    await _analytics.logEvent(
      name: 'game_start',
      parameters: {
        'game_mode': gameMode,
        'team1': team1Name,
        'team2': team2Name,
      },
    );
  }

  /// Enregistre la fin d'une partie
  static Future<void> logGameEnd({
    required String gameMode,
    required String winnerTeam,
    required String loserTeam,
    required int winnerScore,
    required int loserScore,
    required int duration, // durée en secondes
    required bool isSuddenDeath,
  }) async {
    await _analytics.logEvent(
      name: 'game_end',
      parameters: {
        'game_mode': gameMode,
        'winner_team': winnerTeam,
        'loser_team': loserTeam,
        'winner_score': winnerScore,
        'loser_score': loserScore,
        'game_duration': duration,
        'is_sudden_death': isSuddenDeath,
      },
    );
  }

  /// Enregistre un tir au but
  static Future<void> logShot({
    required String teamName,
    required String direction, // 'gauche', 'centre', 'droite'
    required int power, // 0-100
    required String effect, // 'none', 'curve', 'lob', 'knuckle'
    required bool isGoal,
    required bool isAI,
  }) async {
    await _analytics.logEvent(
      name: 'shot_attempt',
      parameters: {
        'team': teamName,
        'direction': direction,
        'power': power,
        'effect': effect,
        'is_goal': isGoal,
        'is_ai_player': isAI,
      },
    );
  }

  /// Enregistre un changement de paramètres audio
  static Future<void> logAudioSettingsChange({
    required bool musicEnabled,
    required bool soundEnabled,
  }) async {
    await _analytics.logEvent(
      name: 'audio_settings_change',
      parameters: {
        'music_enabled': musicEnabled,
        'sound_enabled': soundEnabled,
      },
    );
  }

  /// Enregistre quand l'utilisateur consulte les règles
  static Future<void> logRulesView() async {
    await _analytics.logEvent(name: 'rules_view');
  }

  /// Enregistre quand l'utilisateur accède aux paramètres
  static Future<void> logSettingsView() async {
    await _analytics.logEvent(name: 'settings_view');
  }

  /// Enregistre une erreur non fatale
  static Future<void> logError(String errorType, String errorMessage) async {
    await _analytics.logEvent(
      name: 'app_error',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
      },
    );
  }
}
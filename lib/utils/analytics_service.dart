// analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';

/// Service qui gère toutes les interactions avec Firebase Analytics.
class AnalyticsService {
  static late FirebaseAnalytics _analytics;

  static void initialize(FirebaseAnalytics analytics) {
    _analytics = analytics;
  }

  static Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  static Future<void> logAppBackground() async {
    await _analytics.logEvent(name: 'happygoal_app_background');
  }

  static Future<void> logAppForeground() async {
    await _analytics.logEvent(name: 'app_foreground');
  }

  static Future<void> logGameStart({
    required String gameMode,
    required String team1Name,
    required String team2Name,
  }) async {
    // CORRECTION : Utilisation explicite de <String, Object>
    await _analytics.logEvent(
      name: 'game_start',
      parameters: <String, Object>{
        'game_mode': gameMode,
        'team1': team1Name,
        'team2': team2Name,
      },
    );
  }

  static Future<void> logGameEnd({
    required String gameMode,
    required String winnerTeam,
    required String loserTeam,
    required int winnerScore,
    required int loserScore,
    required int duration,
    required bool isSuddenDeath,
  }) async {
    // CORRECTION : Utilisation explicite de <String, Object>
    await _analytics.logEvent(
      name: 'game_end',
      parameters: <String, Object>{
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

  static Future<void> logShot({
    required String teamName,
    required String direction,
    required int power,
    required String effect,
    required bool isGoal,
    required bool isAI,
  }) async {
    // CORRECTION : Utilisation explicite de <String, Object>
    await _analytics.logEvent(
      name: 'shot_attempt',
      parameters: <String, Object>{
        'team': teamName,
        'direction': direction,
        'power': power,
        'effect': effect,
        'is_goal': isGoal,
        'is_ai_player': isAI,
      },
    );
  }

  static Future<void> logAudioSettingsChange({
    required bool musicEnabled,
    required bool soundEnabled,
  }) async {
    await _analytics.logEvent(
      name: 'audio_settings_change',
      parameters: <String, Object>{
        'music_enabled': musicEnabled,
        'sound_enabled': soundEnabled,
      },
    );
  }

  static Future<void> logRulesView() async {
    await _analytics.logEvent(name: 'rules_view');
  }

  static Future<void> logSettingsView() async {
    await _analytics.logEvent(name: 'settings_view');
  }

  static Future<void> logError(String errorType, String errorMessage) async {
    await _analytics.logEvent(
      name: 'app_error',
      parameters: <String, Object>{
        'error_type': errorType,
        'error_message': errorMessage,
      },
    );
  }

  // CORRECTION : Changement de 'dynamic' à 'Object' dans la signature
  static Future<void> logAdEvent(String eventName, {Map<String, Object>? parameters}) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }
}
// lib/services/achievement_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:happygoal/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:happygoal/models/achievement.dart';
import 'package:happygoal/utils/ad_controller.dart';

class AchievementService {
  static final AchievementService _instance = AchievementService._();
  factory AchievementService() => _instance;
  AchievementService._();

  static const String _progressKey = 'achievement_progress';
  static const String _statsKey = 'player_stats';

  // Statistiques du joueur (AVEC LES NOUVEAUX COMPTEURS)
  Map<String, int> _playerStats = {
    'tournaments_won': 0,
    'tournaments_played': 0,
    // --- HERO MODE ---
    'hero_max_level': 0, // Le plus haut niveau atteint en mode Hero
    'hero_3stars_levels': 0, // Nombre de niveaux où le joueur a obtenu 3 étoiles
    'hero_all_stars': 0, // 1 si toutes les étoiles de tous les niveaux sont obtenues
  };
  /// À appeler quand le joueur termine un niveau Hero (pour mettre à jour la progression Hero)
  Future<void> recordHeroLevel({
    required int level,
    required bool got3Stars,
    required bool allStarsCompleted,
    int total3StarsLevels = 0,
    BuildContext? context,
  }) async {
    if (level > (_playerStats['hero_max_level'] ?? 0)) {
      _playerStats['hero_max_level'] = level;
    }
    if (got3Stars) {
      // On suppose que total3StarsLevels est le nombre total de niveaux à 3 étoiles (à passer lors de l'appel)
      _playerStats['hero_3stars_levels'] = total3StarsLevels;
    }
    if (allStarsCompleted) {
      _playerStats['hero_all_stars'] = 1;
    }
    await _saveStats();
    await _checkAchievements(context: context);
  }

  Map<String, AchievementProgress> _progress = {};

  Future<void> initialize() async {
    await _loadProgress();
    await _loadStats();
    print('📊 AchievementService initialisé avec ${AchievementsList.all.length} succès');
  }

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString(_progressKey);

      if (progressJson != null) {
        final Map<String, dynamic> progressMap = json.decode(progressJson);
        _progress = progressMap.map(
              (key, value) => MapEntry(key, AchievementProgress.fromJson(value)),
        );
      }

      // Toujours s'assurer que tous les achievements existent (pour les mises à jour)
      for (var achievement in AchievementsList.all) {
        if (!_progress.containsKey(achievement.id)) {
          _progress[achievement.id] = AchievementProgress(achievementId: achievement.id);
        }
      }
      // On sauvegarde pour initialiser les nouveaux
      await _saveProgress();

    } catch (e) {
      print('❌ Erreur chargement achievements: $e');
    }
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressMap = _progress.map(
            (key, value) => MapEntry(key, value.toJson()),
      );
      await prefs.setString(_progressKey, json.encode(progressMap));
    } catch (e) {
      print('❌ Erreur sauvegarde achievements: $e');
    }
  }

  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_statsKey);

      if (statsJson != null) {
        final Map<String, dynamic> statsMap = json.decode(statsJson);
        // Fusionner avec les valeurs par défaut pour éviter les nulls sur les nouveaux champs
        final loadedStats = Map<String, int>.from(statsMap);
        _playerStats.addAll(loadedStats);
      }
    } catch (e) {
      print('❌ Erreur chargement stats: $e');
    }
  }

  Future<void> _saveStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_statsKey, json.encode(_playerStats));
    } catch (e) {
      print('❌ Erreur sauvegarde stats: $e');
    }
  }

  /// Enregistrer une victoire de match (Mise à jour avec nouveaux paramètres)
  Future<List<Achievement>> recordMatchWin({
    required int userScore,
    required int opponentScore,
    required int goalsScored,
    required int shotsTaken,
    required int rewindsUsed,
    // Paramètres optionnels pour les types de tirs
    int goalsCurve = 0,
    int goalsLob = 0,
    int goalsKnuckle = 0,
    BuildContext? context,
  }) async {
    _playerStats['total_matches_played'] = (_playerStats['total_matches_played'] ?? 0) + 1;
    _playerStats['total_matches_won'] = (_playerStats['total_matches_won'] ?? 0) + 1;
    _playerStats['total_goals_scored'] = (_playerStats['total_goals_scored'] ?? 0) + goalsScored;
    _playerStats['total_shots_taken'] = (_playerStats['total_shots_taken'] ?? 0) + shotsTaken;

    // --- Gestion des Séries (Streak) ---
    int currentStreak = (_playerStats['current_win_streak'] ?? 0) + 1;
    _playerStats['current_win_streak'] = currentStreak;
    if (currentStreak > (_playerStats['best_win_streak'] ?? 0)) {
      _playerStats['best_win_streak'] = currentStreak;
    }

    // --- Clean Sheets & Perfect Win ---
    if (opponentScore == 0) {
      _playerStats['clean_sheets'] = (_playerStats['clean_sheets'] ?? 0) + 1;
      if (userScore == 5) {
        _playerStats['perfect_wins'] = (_playerStats['perfect_wins'] ?? 0) + 1;
      }
    }

    // --- Types de tirs ---
    _playerStats['goals_curve'] = (_playerStats['goals_curve'] ?? 0) + goalsCurve;
    _playerStats['goals_lob'] = (_playerStats['goals_lob'] ?? 0) + goalsLob;
    _playerStats['goals_knuckle'] = (_playerStats['goals_knuckle'] ?? 0) + goalsKnuckle;

    // --- Utilisation d'objets ---
    _playerStats['total_rewinds_used'] = (_playerStats['total_rewinds_used'] ?? 0) + rewindsUsed;
    if (rewindsUsed == 0) {
      _playerStats['no_rewind_wins'] = (_playerStats['no_rewind_wins'] ?? 0) + 1;
    }

    await _saveStats();
    return await _checkAchievements(context: context);
  }

  /// Enregistrer une défaite (Pour casser la série)
  Future<void> recordMatchLoss({int rewindsUsed = 0, BuildContext? context}) async {
    _playerStats['total_matches_played'] = (_playerStats['total_matches_played'] ?? 0) + 1;
    _playerStats['current_win_streak'] = 0; // 😭 Série brisée

    // On compte quand même les rewinds utilisés même en cas de défaite
    _playerStats['total_rewinds_used'] = (_playerStats['total_rewinds_used'] ?? 0) + rewindsUsed;

    await _saveStats();
    // On vérifie quand même les achievements (ex: "Utiliser 100 rewinds" peut se débloquer même en perdant)
    await _checkAchievements(context: context);
  }

  /// Enregistrer une victoire de tournoi
  Future<List<Achievement>> recordTournamentWin({BuildContext? context}) async {
    _playerStats['tournaments_played'] = (_playerStats['tournaments_played'] ?? 0) + 1;
    _playerStats['tournaments_won'] = (_playerStats['tournaments_won'] ?? 0) + 1;

    await _saveStats();
    return await _checkAchievements(context: context);
  }

  /// Mettre à jour la série quotidienne
  Future<void> updateDailyStreak({BuildContext? context}) async {
    final now = DateTime.now();
    final lastPlayDate = DateTime.fromMillisecondsSinceEpoch(
      _playerStats['last_play_date'] ?? 0,
    );

    final daysSinceLastPlay = now.difference(lastPlayDate).inDays;

    if (daysSinceLastPlay == 1) {
      _playerStats['daily_streak'] = (_playerStats['daily_streak'] ?? 0) + 1;
    } else if (daysSinceLastPlay > 1) {
      _playerStats['daily_streak'] = 1;
    }

    _playerStats['last_play_date'] = now.millisecondsSinceEpoch;
    await _saveStats();
  }

  /// Vérifier les achievements débloqués
  Future<List<Achievement>> _checkAchievements({BuildContext? context}) async {
    List<Achievement> newlyUnlocked = [];

    for (var achievement in AchievementsList.all) {
      final progress = _progress[achievement.id];
      if (progress == null || progress.isUnlocked) continue;

      int currentValue = 0;

      switch (achievement.id) {
      // --- Championnat (tournois) ---
        case 'tournament_1':
        case 'tournament_5':
        case 'tournament_10':
          currentValue = _playerStats['tournaments_won'] ?? 0;
          break;

      // --- Mode Hero ---
        case 'hero_level_5':
          currentValue = _playerStats['hero_max_level'] ?? 0;
          break;
        case 'hero_level_10':
          currentValue = _playerStats['hero_max_level'] ?? 0;
          break;
        case 'hero_3stars_4levels':
          currentValue = _playerStats['hero_3stars_levels'] ?? 0;
          break;
        case 'hero_3stars_10levels':
          currentValue = _playerStats['hero_3stars_levels'] ?? 0;
          break;
        case 'hero_all_stars':
          currentValue = _playerStats['hero_all_stars'] ?? 0;
          break;
        default:
          currentValue = 0;
      }

      progress.currentValue = currentValue;

      if (currentValue >= achievement.targetValue) {
        progress.isUnlocked = true;
        progress.unlockedAt = DateTime.now();
        newlyUnlocked.add(achievement);
        print('🏆 Achievement débloqué: ${achievement.title}');

        // Notification automatique pour succès Hero (si contexte disponible)
        if (achievement.id.startsWith('hero_') && context != null) {
          await NotificationService().sendHeroAchievementNotification(achievement.id, context);
        }
        // Notification automatique pour championnat (si contexte disponible)
        if (achievement.id.startsWith('tournament_') && context != null) {
          await NotificationService().sendTournamentWinNotification(context);
        }
      }
    }

    await _saveProgress();
    return newlyUnlocked;
  }

  Future<bool> claimReward(String achievementId) async {
    final progress = _progress[achievementId];
    final achievement = AchievementsList.getById(achievementId);

    if (progress == null || achievement == null) return false;
    if (!progress.isUnlocked || progress.rewardClaimed) return false;

    await AdController.instance.addCoins(achievement.rewardCoins);
    progress.rewardClaimed = true;
    await _saveProgress();

    return true;
  }

  AchievementProgress? getProgress(String achievementId) {
    return _progress[achievementId];
  }

  List<MapEntry<Achievement, AchievementProgress>> getAllWithProgress() {
    return AchievementsList.all.map((achievement) {
      final progress = _progress[achievement.id] ??
          AchievementProgress(achievementId: achievement.id);
      return MapEntry(achievement, progress);
    }).toList();
  }

  /// Version localisée pour les widgets — retourne les achievements avec
  /// titres et descriptions dans la langue active.
  List<MapEntry<Achievement, AchievementProgress>> getAllWithProgressLocalized(BuildContext context) {
    return AchievementsList.getAllLocalized(context).map((achievement) {
      final progress = _progress[achievement.id] ??
          AchievementProgress(achievementId: achievement.id);
      return MapEntry(achievement, progress);
    }).toList();
  }

  Map<String, int> getPlayerStats() => Map.from(_playerStats);

  double getCompletionPercentage() {
    final total = AchievementsList.all.length;
    final unlocked = _progress.values.where((p) => p.isUnlocked).length;
    return total > 0 ? unlocked / total : 0.0;
  }

  Future<void> resetAll() async {
    _progress.clear();
    _playerStats.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
    await prefs.remove(_statsKey);
    await initialize();
  }
}
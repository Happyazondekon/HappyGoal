// lib/models/achievement.dart

import 'package:flutter/material.dart';

/// Catégories d'achievements
enum AchievementCategory {
  matches,      // Matchs gagnés & Séries
  goals,        // Buts marqués
  tournaments,  // Tournois
  special,      // Événements spéciaux & Objets
  skills,       // Compétences techniques & Clean Sheets
}

/// Rareté des achievements
enum AchievementRarity {
  common,    // Commun (Gris)
  rare,      // Rare (Bleu)
  epic,      // Épique (Violet)
  legendary, // Légendaire (Or)
}

/// Modèle d'un Achievement
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final int targetValue;
  final int rewardCoins;
  final Color color;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.rarity,
    required this.targetValue,
    required this.rewardCoins,
    required this.color,
  });

  /// Obtenir la couleur selon la rareté
  static Color getRarityColor(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return const Color(0xFF78909C); // Gris
      case AchievementRarity.rare:
        return const Color(0xFF2196F3); // Bleu
      case AchievementRarity.epic:
        return const Color(0xFF9C27B0); // Violet
      case AchievementRarity.legendary:
        return const Color(0xFFFFD700); // Or
    }
  }

  /// Obtenir le texte de la rareté
  static String getRarityText(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common: return 'COMMUN';
      case AchievementRarity.rare: return 'RARE';
      case AchievementRarity.epic: return 'ÉPIQUE';
      case AchievementRarity.legendary: return 'LÉGENDAIRE';
    }
  }
}

/// Progression d'un achievement pour un joueur
class AchievementProgress {
  final String achievementId;
  int currentValue;
  bool isUnlocked;
  DateTime? unlockedAt;
  bool rewardClaimed;

  AchievementProgress({
    required this.achievementId,
    this.currentValue = 0,
    this.isUnlocked = false,
    this.unlockedAt,
    this.rewardClaimed = false,
  });

  double getProgressPercentage(int targetValue) {
    if (targetValue == 0) return 0.0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() {
    return {
      'achievementId': achievementId,
      'currentValue': currentValue,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'rewardClaimed': rewardClaimed,
    };
  }

  factory AchievementProgress.fromJson(Map<String, dynamic> json) {
    return AchievementProgress(
      achievementId: json['achievementId'],
      currentValue: json['currentValue'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
      rewardClaimed: json['rewardClaimed'] ?? false,
    );
  }
}

/// Liste de tous les achievements du jeu
class AchievementsList {
  static final List<Achievement> all = [
    // ========== MATCHS GAGNÉS (Équilibrage : 5 à 250 coins) ==========
    Achievement(
      id: 'first_win',
      title: 'Première Victoire',
      description: 'Remportez votre premier match',
      icon: Icons.emoji_events,
      category: AchievementCategory.matches,
      rarity: AchievementRarity.common,
      targetValue: 1,
      rewardCoins: 5, // Juste un petit bonus
      color: const Color(0xFF4CAF50),
    ),
    Achievement(
      id: 'win_10',
      title: 'Débutant Prometteur',
      description: 'Remportez 10 matchs',
      icon: Icons.sports_soccer,
      category: AchievementCategory.matches,
      rarity: AchievementRarity.common,
      targetValue: 10,
      rewardCoins: 10,
      color: const Color(0xFF4CAF50),
    ),
    Achievement(
      id: 'win_25',
      title: 'Joueur Confirmé',
      description: 'Remportez 25 matchs',
      icon: Icons.military_tech,
      category: AchievementCategory.matches,
      rarity: AchievementRarity.rare,
      targetValue: 25,
      rewardCoins: 15, // Prix d'un rembobinage
      color: const Color(0xFF2196F3),
    ),
    Achievement(
      id: 'win_50',
      title: 'Champion en Herbe',
      description: 'Remportez 50 matchs',
      icon: Icons.star,
      category: AchievementCategory.matches,
      rarity: AchievementRarity.rare,
      targetValue: 50,
      rewardCoins: 25,
      color: const Color(0xFF2196F3),
    ),
    Achievement(
      id: 'win_100',
      title: 'Maître du Penalty',
      description: 'Remportez 100 matchs',
      icon: Icons.workspace_premium,
      category: AchievementCategory.matches,
      rarity: AchievementRarity.epic,
      targetValue: 100,
      rewardCoins: 100,
      color: const Color(0xFF9C27B0),
    ),
    Achievement(
      id: 'win_250',
      title: 'Légende Vivante',
      description: 'Remportez 250 matchs',
      icon: Icons.emoji_events_outlined,
      category: AchievementCategory.matches,
      rarity: AchievementRarity.legendary,
      targetValue: 250,
      rewardCoins: 200,
      color: const Color(0xFFFFD700),
    ),
    Achievement(
      id: 'win_500',
      title: 'Dominator',
      description: 'Remportez 500 matchs',
      icon: Icons.military_tech,
      category: AchievementCategory.matches,
      rarity: AchievementRarity.legendary,
      targetValue: 500,
      rewardCoins: 500, // C'était 1500 !
      color: const Color(0xFFFFD700),
    ),

    // ========== SÉRIES (Équilibrage : 10 à 200 coins) ==========
    Achievement(
      id: 'streak_3',
      title: 'En Feu 🔥',
      description: 'Gagnez 3 matchs d\'affilée',
      icon: Icons.local_fire_department,
      category: AchievementCategory.matches,
      rarity: AchievementRarity.common,
      targetValue: 3,
      rewardCoins: 10,
      color: const Color(0xFFFF5722),
    ),
    Achievement(
      id: 'streak_10',
      title: 'Invincible 🛡️',
      description: 'Gagnez 10 matchs d\'affilée',
      icon: Icons.shield,
      category: AchievementCategory.matches,
      rarity: AchievementRarity.epic,
      targetValue: 10,
      rewardCoins: 50, // C'était 300
      color: const Color(0xFFD32F2F),
    ),
    Achievement(
      id: 'streak_50',
      title: 'Dieu du Stade ⚡',
      description: 'Gagnez 50 matchs d\'affilée',
      icon: Icons.bolt,
      category: AchievementCategory.matches,
      rarity: AchievementRarity.legendary,
      targetValue: 50,
      rewardCoins: 200, // C'était 1000
      color: const Color(0xFFFFD700),
    ),

    // ========== BUTS (Équilibrage : 5 à 200 coins) ==========
    Achievement(
      id: 'goals_10',
      title: 'Buteur Débutant',
      description: 'Marquez 10 buts',
      icon: Icons.sports_soccer,
      category: AchievementCategory.goals,
      rarity: AchievementRarity.common,
      targetValue: 10,
      rewardCoins: 5,
      color: const Color(0xFFFF9800),
    ),
    Achievement(
      id: 'goals_50',
      title: 'Sniper des Surfaces',
      description: 'Marquez 50 buts',
      icon: Icons.gps_fixed,
      category: AchievementCategory.goals,
      rarity: AchievementRarity.rare,
      targetValue: 50,
      rewardCoins: 15,
      color: const Color(0xFFFF9800),
    ),
    Achievement(
      id: 'goals_100',
      title: 'Canonnier',
      description: 'Marquez 100 buts',
      icon: Icons.local_fire_department,
      category: AchievementCategory.goals,
      rarity: AchievementRarity.epic,
      targetValue: 100,
      rewardCoins: 30,
      color: const Color(0xFFFF9800),
    ),
    Achievement(
      id: 'goals_500',
      title: 'Légende du Goal',
      description: 'Marquez 500 buts',
      icon: Icons.whatshot,
      category: AchievementCategory.goals,
      rarity: AchievementRarity.legendary,
      targetValue: 500,
      rewardCoins: 100,
      color: const Color(0xFFFF9800),
    ),
    Achievement(
      id: 'goals_1000',
      title: 'Machine à Buts',
      description: 'Marquez 1000 buts au total',
      icon: Icons.stars,
      category: AchievementCategory.goals,
      rarity: AchievementRarity.legendary,
      targetValue: 1000,
      rewardCoins: 200, // C'était 1000
      color: const Color(0xFFFFC107),
    ),

    // ========== TOURNOIS (Équilibrage : 20 à 150 coins) ==========
    Achievement(
      id: 'tournament_1',
      title: 'Premier Trophée',
      description: 'Remportez votre premier tournoi',
      icon: Icons.emoji_events,
      category: AchievementCategory.tournaments,
      rarity: AchievementRarity.rare,
      targetValue: 1,
      rewardCoins: 20, // C'était 100
      color: const Color(0xFFFFD700),
    ),
    Achievement(
      id: 'tournament_5',
      title: 'Collectionneur de Coupes',
      description: 'Remportez 5 tournois',
      icon: Icons.workspace_premium,
      category: AchievementCategory.tournaments,
      rarity: AchievementRarity.epic,
      targetValue: 5,
      rewardCoins: 75,
      color: const Color(0xFFFFD700),
    ),
    Achievement(
      id: 'tournament_10',
      title: 'Empereur des Tournois',
      description: 'Remportez 10 tournois',
      icon: Icons.emoji_events,
      category: AchievementCategory.tournaments,
      rarity: AchievementRarity.legendary,
      targetValue: 10,
      rewardCoins: 150, // C'était 750
      color: const Color(0xFFFFD700),
    ),

    // ========== SKILLS (Équilibrage : 20 à 50 coins) ==========
    Achievement(
      id: 'perfect_match',
      title: 'Sans Faute',
      description: 'Gagnez un match 5-0',
      icon: Icons.check_circle,
      category: AchievementCategory.skills,
      rarity: AchievementRarity.rare,
      targetValue: 1,
      rewardCoins: 20,
      color: const Color(0xFF4CAF50),
    ),
    Achievement(
      id: 'comeback_king',
      title: 'Retour Héroïque',
      description: 'Gagnez après avoir été mené 0-2',
      icon: Icons.trending_up,
      category: AchievementCategory.skills,
      rarity: AchievementRarity.epic,
      targetValue: 1,
      rewardCoins: 30, // C'était 150
      color: const Color(0xFF2196F3),
    ),
    Achievement(
      id: 'no_rewind',
      title: 'Pureté',
      description: 'Gagnez un match sans utiliser de rembobinage',
      icon: Icons.block,
      category: AchievementCategory.skills,
      rarity: AchievementRarity.epic,
      targetValue: 1,
      rewardCoins: 25,
      color: const Color(0xFF9C27B0),
    ),
    Achievement(
      id: 'clean_sheet_10',
      title: 'Mur de Briques',
      description: 'Gagnez 10 matchs sans encaisser de but',
      icon: Icons.grid_view,
      category: AchievementCategory.skills,
      rarity: AchievementRarity.rare,
      targetValue: 10,
      rewardCoins: 25,
      color: const Color(0xFF607D8B),
    ),
    Achievement(
      id: 'clean_sheet_50',
      title: 'Forteresse',
      description: 'Gagnez 50 matchs sans encaisser de but',
      icon: Icons.security,
      category: AchievementCategory.skills,
      rarity: AchievementRarity.legendary,
      targetValue: 50,
      rewardCoins: 100,
      color: const Color(0xFF455A64),
    ),

    // ========== TYPES DE TIRS (Équilibrage : 10 à 50 coins) ==========
    Achievement(
      id: 'score_curve_10',
      title: 'Artiste du Ballon',
      description: 'Marquez 10 buts avec effet Courbe',
      icon: Icons.turn_right,
      category: AchievementCategory.skills,
      rarity: AchievementRarity.common,
      targetValue: 10,
      rewardCoins: 10,
      color: const Color(0xFF00BCD4),
    ),
    Achievement(
      id: 'score_curve_100',
      title: 'Le Nouveau Beckham',
      description: 'Marquez 100 buts avec effet Courbe',
      icon: Icons.all_inclusive,
      category: AchievementCategory.skills,
      rarity: AchievementRarity.epic,
      targetValue: 100,
      rewardCoins: 50,
      color: const Color(0xFF00BCD4),
    ),
    Achievement(
      id: 'score_lob_10',
      title: 'Petit Pont',
      description: 'Marquez 10 buts avec un Lob (Panenka)',
      icon: Icons.keyboard_arrow_up,
      category: AchievementCategory.skills,
      rarity: AchievementRarity.rare,
      targetValue: 10,
      rewardCoins: 15,
      color: const Color(0xFF9C27B0),
    ),
    Achievement(
      id: 'score_knuckle_50',
      title: 'Flottant',
      description: 'Marquez 50 buts avec effet Knuckle',
      icon: Icons.waves,
      category: AchievementCategory.skills,
      rarity: AchievementRarity.epic,
      targetValue: 50,
      rewardCoins: 50,
      color: const Color(0xFFE91E63),
    ),

    // ========== SPÉCIAUX (Équilibrage : 5 à 100 coins) ==========
    Achievement(
      id: 'daily_streak_7',
      title: 'Habitué',
      description: 'Jouez 7 jours consécutifs',
      icon: Icons.calendar_today,
      category: AchievementCategory.special,
      rarity: AchievementRarity.rare,
      targetValue: 7,
      rewardCoins: 25, // C'était 100
      color: const Color(0xFFFF5722),
    ),
    Achievement(
      id: 'coin_collector',
      title: 'Économe',
      description: 'Accumulez 1000 coins',
      icon: Icons.monetization_on,
      category: AchievementCategory.special,
      rarity: AchievementRarity.epic,
      targetValue: 1000,
      rewardCoins: 50,
      color: const Color(0xFFFFD700),
    ),
    Achievement(
      id: 'rich_kid',
      title: 'Millionnaire',
      description: 'Possédez 5000 coins',
      icon: Icons.savings,
      category: AchievementCategory.special,
      rarity: AchievementRarity.legendary,
      targetValue: 5000,
      rewardCoins: 100,
      color: const Color(0xFFFFD700),
    ),
    Achievement(
      id: 'rewind_user_10',
      title: 'Voyageur Temporel',
      description: 'Utilisez le rembobinage 10 fois',
      icon: Icons.history,
      category: AchievementCategory.special,
      rarity: AchievementRarity.common,
      targetValue: 10,
      rewardCoins: 5, // Juste un petit geste
      color: const Color(0xFF009688),
    ),
    Achievement(
      id: 'rewind_user_100',
      title: 'Maître du Temps',
      description: 'Utilisez le rembobinage 100 fois',
      icon: Icons.update,
      category: AchievementCategory.special,
      rarity: AchievementRarity.epic,
      targetValue: 100,
      rewardCoins: 50,
      color: const Color(0xFF009688),
    ),
  ];

  static Achievement? getById(String id) {
    try {
      return all.firstWhere((achievement) => achievement.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Achievement> getByCategory(AchievementCategory category) {
    return all.where((a) => a.category == category).toList();
  }

  static List<Achievement> getByRarity(AchievementRarity rarity) {
    return all.where((a) => a.rarity == rarity).toList();
  }
}
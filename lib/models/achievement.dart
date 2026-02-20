// lib/models/achievement.dart

import 'package:flutter/material.dart';
import 'package:happygoal/l10n/app_localizations.dart';

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

  /// Obtenir le texte localisé de la rareté
  static String getRarityText(AchievementRarity rarity, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (rarity) {
      case AchievementRarity.common:
        return l10n.rarityCommon;
      case AchievementRarity.rare:
        return l10n.rarityRare;
      case AchievementRarity.epic:
        return l10n.rarityEpic;
      case AchievementRarity.legendary:
        return l10n.rarityLegendary;
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
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
      rewardClaimed: json['rewardClaimed'] ?? false,
    );
  }
}

/// Liste de tous les achievements du jeu.
///
/// [AchievementsList.all] : version sans texte (IDs, icônes, couleurs, valeurs).
///   Utilisée par [AchievementService] pour la logique métier (sans context).
///
/// [AchievementsList.getAllLocalized(context)] : version avec titres/descriptions
///   localisés. Utilisée par les widgets (screens).
class AchievementsList {
  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Version structurelle (sans texte localisé) — pour la logique service.
  static final List<Achievement> all = [
    // ═══ TOURNOIS ════════════════════════════════════════════════════════════
    Achievement(
      id: 'tournament_1',
      title: 'tournament_1',       // placeholder — use getAllLocalized() in UI
      description: 'tournament_1',
      icon: Icons.emoji_events,
      category: AchievementCategory.tournaments,
      rarity: AchievementRarity.rare,
      targetValue: 1,
      rewardCoins: 20,
      color: const Color(0xFFFFD700),
    ),
    Achievement(
      id: 'tournament_5',
      title: 'tournament_5',
      description: 'tournament_5',
      icon: Icons.workspace_premium,
      category: AchievementCategory.tournaments,
      rarity: AchievementRarity.epic,
      targetValue: 5,
      rewardCoins: 75,
      color: const Color(0xFFFFD700),
    ),
    Achievement(
      id: 'tournament_10',
      title: 'tournament_10',
      description: 'tournament_10',
      icon: Icons.emoji_events,
      category: AchievementCategory.tournaments,
      rarity: AchievementRarity.legendary,
      targetValue: 10,
      rewardCoins: 150,
      color: const Color(0xFFFFD700),
    ),

    // ═══ MODE HERO ═══════════════════════════════════════════════════════════
    Achievement(
      id: 'hero_level_5',
      title: 'hero_level_5',
      description: 'hero_level_5',
      icon: Icons.military_tech,
      category: AchievementCategory.special,
      rarity: AchievementRarity.rare,
      targetValue: 5,
      rewardCoins: 30,
      color: const Color(0xFFFFD700),
    ),
    Achievement(
      id: 'hero_level_10',
      title: 'hero_level_10',
      description: 'hero_level_10',
      icon: Icons.military_tech,
      category: AchievementCategory.special,
      rarity: AchievementRarity.epic,
      targetValue: 10,
      rewardCoins: 60,
      color: const Color(0xFF9C27B0),
    ),
    Achievement(
      id: 'hero_3stars_4levels',
      title: 'hero_3stars_4levels',
      description: 'hero_3stars_4levels',
      icon: Icons.star,
      category: AchievementCategory.special,
      rarity: AchievementRarity.epic,
      targetValue: 4,
      rewardCoins: 50,
      color: const Color(0xFF9C27B0),
    ),
    Achievement(
      id: 'hero_3stars_10levels',
      title: 'hero_3stars_10levels',
      description: 'hero_3stars_10levels',
      icon: Icons.star,
      category: AchievementCategory.special,
      rarity: AchievementRarity.legendary,
      targetValue: 10,
      rewardCoins: 100,
      color: const Color(0xFFFFD700),
    ),
    Achievement(
      id: 'hero_all_stars',
      title: 'hero_all_stars',
      description: 'hero_all_stars',
      icon: Icons.workspace_premium,
      category: AchievementCategory.special,
      rarity: AchievementRarity.legendary,
      targetValue: 1,
      rewardCoins: 150,
      color: const Color(0xFFFFD700),
    ),
  ];

  /// Version pleinement localisée — à utiliser dans les widgets.
  ///
  /// Retourne la même liste structurelle mais avec [title] et [description]
  /// remplis depuis [AppLocalizations]. Doit être appelé dans [build()].
  static List<Achievement> getAllLocalized(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Achievement _loc(Achievement a, String title, String desc) => Achievement(
      id: a.id,
      title: title,
      description: desc,
      icon: a.icon,
      category: a.category,
      rarity: a.rarity,
      targetValue: a.targetValue,
      rewardCoins: a.rewardCoins,
      color: a.color,
    );

    return [
      // Tournois
      _loc(all[0], l10n.achievementTournament1Title, l10n.achievementTournament1Desc),
      _loc(all[1], l10n.achievementTournament5Title, l10n.achievementTournament5Desc),
      _loc(all[2], l10n.achievementTournament10Title, l10n.achievementTournament10Desc),
      // Hero mode
      _loc(all[3], l10n.achievementHeroLevel5Title, l10n.achievementHeroLevel5Desc),
      _loc(all[4], l10n.achievementHeroLevel10Title, l10n.achievementHeroLevel10Desc),
      _loc(all[5], l10n.achievementHero3stars4Title, l10n.achievementHero3stars4Desc),
      _loc(all[6], l10n.achievementHero3stars10Title, l10n.achievementHero3stars10Desc),
      _loc(all[7], l10n.achievementHeroAllStarsTitle, l10n.achievementHeroAllStarsDesc),
    ];
  }
}
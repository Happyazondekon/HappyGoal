// lib/screens/achievements_screen.dart

import 'package:flutter/material.dart';
import 'package:happygoal/models/achievement.dart';
import 'package:happygoal/services/achievement_service.dart';
import 'package:happygoal/constants.dart';
import 'package:happygoal/utils/responsive_helper.dart';
import 'package:happygoal/utils/audio_manager.dart';
import 'package:happygoal/l10n/app_localizations.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  final AchievementService _service = AchievementService();
  late TabController _tabController;

  AchievementCategory _selectedCategory = AchievementCategory.matches;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: AchievementCategory.values.length,
      vsync: this,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedCategory = AchievementCategory.values[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getCategoryName(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.matches:
        return AppLocalizations.of(context)!.achievementsCategoryMatches;
      case AchievementCategory.goals:
        return AppLocalizations.of(context)!.achievementsCategoryGoals;
      case AchievementCategory.tournaments:
        return AppLocalizations.of(context)!.achievementsCategoryTournaments;
      case AchievementCategory.special:
        return AppLocalizations.of(context)!.achievementsCategorySpecial;
      case AchievementCategory.skills:
        return AppLocalizations.of(context)!.achievementsCategorySkills;
    }
  }

  IconData _getCategoryIcon(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.matches:
        return Icons.sports_soccer;
      case AchievementCategory.goals:
        return Icons.gps_fixed;
      case AchievementCategory.tournaments:
        return Icons.emoji_events;
      case AchievementCategory.special:
        return Icons.star;
      case AchievementCategory.skills:
        return Icons.military_tech;
    }
  }

  @override
  Widget build(BuildContext context) {
    final achievements = _service.getAllWithProgress();
    final completionPercentage = _service.getCompletionPercentage();
    final stats = _service.getPlayerStats();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary, AppColors.fieldGreen, Color(0xFF0F4A2D)],
            stops: [0.0, 0.5, 1.0],

          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(completionPercentage, stats),

              // Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withOpacity(0.2),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  tabs: AchievementCategory.values.map((category) {
                    return Tab(
                      icon: Icon(_getCategoryIcon(category), size: 20),
                      text: _getCategoryName(category),
                    );
                  }).toList(),
                ),
              ),

              // Liste des achievements
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: AchievementCategory.values.map((category) {
                    final categoryAchievements = achievements
                        .where((entry) => entry.key.category == category)
                        .toList();
                    return _buildAchievementsList(categoryAchievements);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double completionPercentage, Map<String, int> stats) {
    final totalAchievements = AchievementsList.all.length;
    final unlockedCount = (completionPercentage * totalAchievements).round();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  AudioManager.playSound('click');
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.achievementsTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.achievementsUnlocked(unlockedCount, totalAchievements),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatBadge(
                Icons.emoji_events,
                '${stats['total_matches_won'] ?? 0}',
                AppLocalizations.of(context)!.achievementsStatWins,
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildProgressBar(completionPercentage),
        ],
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFFFD700), size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.achievementsProgressGlobal,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              AppLocalizations.of(context)!.achievementsCompletionPercent((progress * 100).toStringAsFixed(0)),
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD700)),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsList(
      List<MapEntry<Achievement, AchievementProgress>> achievements,
      ) {
    if (achievements.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.achievementsNone,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final entry = achievements[index];
        return _buildAchievementCard(entry.key, entry.value);
      },
    );
  }

  Widget _buildAchievementCard(
      Achievement achievement,
      AchievementProgress progress,
      ) {
    final isUnlocked = progress.isUnlocked;
    final percentage = progress.getProgressPercentage(achievement.targetValue);
    final rarityColor = Achievement.getRarityColor(achievement.rarity);

    String rarityText;
    switch (achievement.rarity) {
      case AchievementRarity.common:
        rarityText = AppLocalizations.of(context)!.achievementsRarityCommon;
        break;
      case AchievementRarity.rare:
        rarityText = AppLocalizations.of(context)!.achievementsRarityRare;
        break;
      case AchievementRarity.epic:
        rarityText = AppLocalizations.of(context)!.achievementsRarityEpic;
        break;
      case AchievementRarity.legendary:
        rarityText = AppLocalizations.of(context)!.achievementsRarityLegendary;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUnlocked
              ? [
            rarityColor.withOpacity(0.3),
            rarityColor.withOpacity(0.1),
          ]
              : [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isUnlocked
              ? rarityColor.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: isUnlocked && !progress.rewardClaimed
              ? () => _claimReward(achievement, progress)
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icône
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUnlocked
                        ? rarityColor.withOpacity(0.3)
                        : Colors.white.withOpacity(0.1),
                    border: Border.all(
                      color: isUnlocked
                          ? rarityColor
                          : Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    achievement.icon,
                    color: isUnlocked ? rarityColor : Colors.white60,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),

                // Détails
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              achievement.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isUnlocked
                                    ? Colors.white
                                    : Colors.white60,
                              ),
                            ),
                          ),
                          if (isUnlocked)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: rarityColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                rarityText,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Barre de progression
                      if (!isUnlocked) ...[
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: LinearProgressIndicator(
                                  value: percentage,
                                  minHeight: 6,
                                  backgroundColor:
                                  Colors.white.withOpacity(0.2),
                                  valueColor: AlwaysStoppedAnimation(
                                    achievement.color,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.achievementsProgress(progress.currentValue, achievement.targetValue),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Récompense
                      if (isUnlocked) ...[
                        Row(
                          children: [
                            Icon(
                              progress.rewardClaimed
                                  ? Icons.check_circle
                                  : Icons.card_giftcard,
                              color: progress.rewardClaimed
                                  ? Colors.green
                                  : const Color(0xFFFFD700),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              progress.rewardClaimed
                                ? AppLocalizations.of(context)!.achievementsClaimed
                                : AppLocalizations.of(context)!.achievementsReward(achievement.rewardCoins),
                              style: TextStyle(
                                fontSize: 12,
                                color: progress.rewardClaimed
                                    ? Colors.green
                                    : const Color(0xFFFFD700),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _claimReward(
      Achievement achievement,
      AchievementProgress progress,
      ) async {
    AudioManager.playSound('goal');

    final success = await _service.claimReward(achievement.id);

    if (success && mounted) {
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.monetization_on, color: Colors.white),
              const SizedBox(width: 10),
              Text(AppLocalizations.of(context)!.achievementsSnackClaimed(achievement.rewardCoins)),
            ],
          ),
          backgroundColor: const Color(0xFFFFD700),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
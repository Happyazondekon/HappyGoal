import 'package:flutter/material.dart';
import 'package:happygoal/l10n/app_localizations.dart';
import 'package:happygoal/models/game_state.dart';
import 'package:happygoal/services/hero_challenge_evaluator.dart';

/// Un challenge Hero avec son titre, sa description,
/// et sa condition d'évaluation basée sur le GameState réel.
class HeroChallenge {
  final String title;
  final String description;

  /// Retourne true UNIQUEMENT si le joueur a rempli la condition
  /// en se basant sur les vrais événements du match (team1ShotData, team2ShotData).
  final bool Function(GameState) isCompleted;

  HeroChallenge({
    required this.title,
    required this.description,
    required this.isCompleted,
  });
}

class HeroChallengeRepository {
  /// Retourne les challenges pour tous les niveaux.
  /// [context] est requis pour accéder aux strings localisés.
  static Map<int, List<HeroChallenge>> getChallenges(BuildContext context) {
    final Map<int, List<HeroChallenge>> challenges = {};
    for (int level = 1; level <= 100; level++) {
      challenges[level] = _buildChallenges(context, level);
    }
    return challenges;
  }

  /// Construit les 3 challenges d'un niveau.
  ///
  /// Challenge 0 : Gagner le match (toujours présent)
  /// Challenge 1 : Objectif offensif (varie selon le niveau)
  /// Challenge 2 : Objectif défensif / arrêt (toujours : au moins 1 arrêt)
  static List<HeroChallenge> _buildChallenges(BuildContext context, int level) {
    final l10n = AppLocalizations.of(context)!;
    return [
      // ─── Challenge 0 : Victoire ──────────────────────────────────────────
      HeroChallenge(
        title: l10n.challengeWinTitle,
        description: l10n.challengeWinDesc,
        isCompleted: (state) => HeroChallengeEvaluator.userWon(state),
      ),

      // ─── Challenge 1 : Objectif offensif/défensif ────────────────────────
      _buildOffensiveChallenge(context, level),

      // ─── Challenge 2 : Arrêt ─────────────────────────────────────────────
      HeroChallenge(
        title: l10n.challengeSaveTitle,
        description: l10n.challengeSaveDesc,
        isCompleted: (state) =>
        HeroChallengeEvaluator.userWon(state) &&
            HeroChallengeEvaluator.madeSaves(state, 1),
      ),
    ];
  }

  static HeroChallenge _buildOffensiveChallenge(BuildContext context, int level) {
    final l10n = AppLocalizations.of(context)!;

    if (level % 11 == 0) {
      return HeroChallenge(
        title: l10n.challengeKnuckleTitle,
        description: l10n.challengeKnuckleDesc,
        isCompleted: (state) =>
        HeroChallengeEvaluator.userWon(state) &&
            HeroChallengeEvaluator.scoredGoalsWithEffect(
                state, ShotEffect.knuckle, 1),
      );
    } else if (level % 13 == 0) {
      return HeroChallenge(
        title: l10n.challengePowerTitle,
        description: l10n.challengePowerDesc,
        isCompleted: (state) =>
        HeroChallengeEvaluator.userWon(state) &&
            HeroChallengeEvaluator.allGoalsWithPowerAbove(state, 80),
      );
    } else if (level % 7 == 0) {
      return HeroChallenge(
        title: l10n.challengeConcedeLessTitle,
        description: l10n.challengeConcedeLessDesc,
        isCompleted: (state) =>
        HeroChallengeEvaluator.userWon(state) &&
            HeroChallengeEvaluator.concededAtMost(state, 2),
      );
    } else if (level % 5 == 0) {
      return HeroChallenge(
        title: l10n.challengeAllLobTitle,
        description: l10n.challengeAllLobDesc,
        isCompleted: (state) =>
        HeroChallengeEvaluator.userWon(state) &&
            HeroChallengeEvaluator.allGoalsWithEffect(state, ShotEffect.lob),
      );
    } else if (level % 3 == 0) {
      return HeroChallenge(
        title: l10n.challengeCurveTitle,
        description: l10n.challengeCurveDesc,
        isCompleted: (state) =>
        HeroChallengeEvaluator.userWon(state) &&
            HeroChallengeEvaluator.scoredGoalsWithEffect(
                state, ShotEffect.curve, 2),
      );
    } else {
      return HeroChallenge(
        title: l10n.challengeLobTitle,
        description: l10n.challengeLobDesc,
        isCompleted: (state) =>
        HeroChallengeEvaluator.userWon(state) &&
            HeroChallengeEvaluator.scoredGoalsWithEffect(
                state, ShotEffect.lob, 3),
      );
    }
  }
}
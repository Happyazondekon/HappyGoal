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
  static Map<int, List<HeroChallenge>> getChallenges() {
    final Map<int, List<HeroChallenge>> challenges = {};
    for (int level = 1; level <= 100; level++) {
      challenges[level] = _buildChallenges(level);
    }
    return challenges;
  }

  /// Construit les 3 challenges d'un niveau.
  ///
  /// Challenge 0 : Gagner le match (toujours présent)
  /// Challenge 1 : Objectif offensif (varie selon le niveau)
  /// Challenge 2 : Objectif défensif / arrêt (toujours : au moins 1 arrêt)
  ///
  /// Priorité des conditions pour le challenge 1 :
  /// On utilise des intervalles exclusifs pour éviter toute ambiguïté.
  ///
  ///   level % 11 == 0                       → but knuckle
  ///   level % 13 == 0 (et pas % 11)         → tous les buts puissance > 80
  ///   level % 7  == 0 (et pas % 11 ni % 13) → encaisser max 2 buts
  ///   level % 5  == 0 (et pas les précédents)→ tous les buts en lob
  ///   level % 3  == 0 (et pas les précédents)→ 2 buts curve
  ///   sinon                                  → 3 buts lob
  static List<HeroChallenge> _buildChallenges(int level) {
    return [
      // ─── Challenge 0 : Victoire (obligatoire, toujours 1ère étoile) ─────────
      HeroChallenge(
        title: 'Gagner le match',
        description: 'Remportez la séance de tirs au but.',
        isCompleted: (state) => HeroChallengeEvaluator.userWon(state),
      ),

      // ─── Challenge 1 : Objectif offensif/défensif (2ème étoile) ─────────────
      _buildOffensiveChallenge(level),

      // ─── Challenge 2 : Arrêt (3ème étoile) ──────────────────────────────────
      HeroChallenge(
        title: 'Réaliser au moins 1 arrêt',
        description:
        'Votre gardien doit stopper au moins un tir adverse.',
        isCompleted: (state) =>
        HeroChallengeEvaluator.userWon(state) &&
            HeroChallengeEvaluator.madeSaves(state, 1),
      ),
    ];
  }

  static HeroChallenge _buildOffensiveChallenge(int level) {
    // Priorité décroissante avec des else-if strictement ordonnés :
    // les diviseurs les plus rares (11, 13) passent en premier.
    if (level % 11 == 0) {
      return HeroChallenge(
        title: 'Marquer un but en Knuckle',
        description: 'Marquez au moins 1 but avec l\'effet Knuckle.',
        isCompleted: (state) =>
        HeroChallengeEvaluator.userWon(state) &&
            HeroChallengeEvaluator.scoredGoalsWithEffect(
                state, ShotEffect.knuckle, 1),
      );
    } else if (level % 13 == 0) {
      return HeroChallenge(
        title: 'Tous les buts puissance > 80',
        description:
        'Chaque but marqué doit avoir été tiré avec une puissance supérieure à 80.',
        isCompleted: (state) =>
        HeroChallengeEvaluator.userWon(state) &&
            HeroChallengeEvaluator.allGoalsWithPowerAbove(state, 80),
      );
    } else if (level % 7 == 0) {
      return HeroChallenge(
        title: 'Encaisser maximum 2 buts',
        description: 'Ne laissez pas l\'adversaire marquer plus de 2 buts.',
        isCompleted: (state) =>
        HeroChallengeEvaluator.userWon(state) &&
            HeroChallengeEvaluator.concededAtMost(state, 2),
      );
    } else if (level % 5 == 0) {
      return HeroChallenge(
        title: 'Tous les buts en Lob',
        description:
        'Chaque but marqué doit avoir été tiré avec l\'effet Lob.',
        isCompleted: (state) =>
        HeroChallengeEvaluator.userWon(state) &&
            HeroChallengeEvaluator.allGoalsWithEffect(
                state, ShotEffect.lob),
      );
    } else if (level % 3 == 0) {
      return HeroChallenge(
        title: 'Marquer 2 buts en Curve',
        description: 'Marquez au moins 2 buts avec l\'effet Curve.',
        isCompleted: (state) =>
        HeroChallengeEvaluator.userWon(state) &&
            HeroChallengeEvaluator.scoredGoalsWithEffect(
                state, ShotEffect.curve, 2),
      );
    } else {
      return HeroChallenge(
        title: 'Marquer 3 buts en Lob',
        description: 'Marquez au moins 3 buts avec l\'effet Lob.',
        isCompleted: (state) =>
        HeroChallengeEvaluator.userWon(state) &&
            HeroChallengeEvaluator.scoredGoalsWithEffect(
                state, ShotEffect.lob, 3),
      );
    }
  }
}
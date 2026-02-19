import 'package:happygoal/models/game_state.dart';

class HeroChallenge {
  final String title;
  final String description;
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
      final String challengeTitle = _challengeTitle(level);
      challenges[level] = [
        HeroChallenge(
          title: 'Gagner le match',
          description: 'Remportez la séance de tirs au but.',
          isCompleted: (state) => state.isUserWinner,
        ),
        HeroChallenge(
          title: challengeTitle,
          description: _challengeDescription(level),
          isCompleted: (state) => _challengeCondition(level, state),
        ),
        HeroChallenge(
          title: 'Faire un arrêt',
          description: 'Arrêtez au moins un tir adverse.',
          isCompleted: (state) => state.team2Results.contains(false),
        ),
      ];
    }
    return challenges;
  }

  static String _challengeTitle(int level) {
    if (level % 5 == 0) {
      return 'Marquer tous les buts en lob';
    } else if (level % 3 == 0) {
      return 'Marquer 2 buts effet curve';
    } else if (level % 7 == 0) {
      return 'Encaisser max 2 buts';
    } else if (level % 11 == 0) {
      return 'Marquer un but knuckle';
    } else if (level % 13 == 0) {
      return 'Marquer tous les buts puissance > 80';
    } else {
      return 'Marquer 3 buts effet lob';
    }
  }

  static String _challengeDescription(int level) {
    if (level % 5 == 0) {
      return 'Marquez tous vos buts avec l\'effet lob.';
    } else if (level % 3 == 0) {
      return 'Marquez au moins 2 buts avec effet curve.';
    } else if (level % 7 == 0) {
      return 'Ne pas encaisser plus de 2 buts.';
    } else if (level % 11 == 0) {
      return 'Marquez un but knuckle.';
    } else if (level % 13 == 0) {
      return 'Marquez tous vos buts avec puissance > 80.';
    } else {
      return 'Marquez au moins 3 buts avec effet lob.';
    }
  }

  static bool _challengeCondition(int level, GameState state) {
    if (level % 5 == 0) {
      final allLob = state.team1ShotData
        .where((shot) => shot.isGoal)
        .every((shot) => shot.effect == 'lob');
      return allLob && state.isUserWinner;
    } else if (level % 3 == 0) {
      final curveGoals = state.team1ShotData
        .where((shot) => shot.isGoal && shot.effect == 'curve')
        .length;
      return curveGoals >= 2 && state.isUserWinner;
    } else if (level % 7 == 0) {
      final goalsAgainst = state.team2Results.where((r) => r).length;
      return goalsAgainst <= 2 && state.isUserWinner;
    } else if (level % 11 == 0) {
      final knuckleGoals = state.team1ShotData
        .where((shot) => shot.isGoal && shot.effect == 'knuckle')
        .length;
      return knuckleGoals >= 1 && state.isUserWinner;
    } else if (level % 13 == 0) {
      final allPower = state.team1ShotData
        .where((shot) => shot.isGoal)
        .every((shot) => shot.power > 80);
      return allPower && state.isUserWinner;
    } else {
      final lobGoals = state.team1ShotData
        .where((shot) => shot.isGoal && shot.effect == 'lob')
        .length;
      return lobGoals >= 3 && state.isUserWinner;
    }
  }
}

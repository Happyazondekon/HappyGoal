import 'package:happygoal/models/game_state.dart';
import 'package:happygoal/models/hero_challenge.dart';

/// Évalue précisément les challenges d'un niveau Hero
/// en se basant UNIQUEMENT sur les vrais événements enregistrés dans GameState.
/// Zéro étoile fictive : si la condition n'est pas remplie, c'est false.
class HeroChallengeEvaluator {
  /// Évalue tous les challenges du niveau et retourne une liste de bool.
  /// Index 0 = challenge 1, index 1 = challenge 2, etc.
  static List<bool> evaluateAll(int level, GameState state) {
    final challenges = HeroChallengeRepository.getChallenges()[level] ?? [];
    return challenges.map((c) => c.isCompleted(state)).toList();
  }

  // ─── VICTOIRE ────────────────────────────────────────────────────────────────

  /// Le joueur (team1) a-t-il remporté la séance de tirs au but ?
  static bool userWon(GameState state) {
    return state.isUserWinner;
  }

  // ─── TIRS DU JOUEUR (team1ShotData) ─────────────────────────────────────────

  /// Nombre de buts marqués par le joueur avec un effet précis.
  /// On filtre sur isGoal = true ET effect == effect demandé.
  static int countGoalsWithEffect(GameState state, String effect) {
    return state.team1ShotData
        .where((shot) => shot.isGoal && shot.effect == effect)
        .length;
  }

  /// Le joueur a-t-il marqué au moins [count] buts avec l'effet [effect] ?
  static bool scoredGoalsWithEffect(GameState state, String effect, int count) {
    if (count <= 0) return false;
    return countGoalsWithEffect(state, effect) >= count;
  }

  /// Tous les buts du joueur ont-ils été marqués avec l'effet [effect] ?
  /// (Au moins 1 but requis — si le joueur n'a pas marqué, c'est false)
  static bool allGoalsWithEffect(GameState state, String effect) {
    final goals = state.team1ShotData.where((shot) => shot.isGoal).toList();
    if (goals.isEmpty) return false;
    return goals.every((shot) => shot.effect == effect);
  }

  /// Tous les buts du joueur ont-ils été tirés avec une puissance > [minPower] ?
  /// (Au moins 1 but requis — si le joueur n'a pas marqué, c'est false)
  static bool allGoalsWithPowerAbove(GameState state, int minPower) {
    final goals = state.team1ShotData.where((shot) => shot.isGoal).toList();
    if (goals.isEmpty) return false;
    return goals.every((shot) => shot.power > minPower);
  }

  /// Le joueur a-t-il marqué au moins [count] buts avec n'importe quel effet
  /// parmi la liste [effects] ?
  static bool scoredGoalsWithAnyEffect(
      GameState state, List<String> effects, int count) {
    if (count <= 0) return false;
    final matching = state.team1ShotData
        .where((shot) => shot.isGoal && effects.contains(shot.effect))
        .length;
    return matching >= count;
  }

  // ─── GARDIEN DU JOUEUR (team2ShotData) ──────────────────────────────────────

  /// Nombre d'arrêts réalisés par le gardien du joueur.
  /// Un arrêt = un tir de l'IA (team2) enregistré avec isGoal = false.
  static int countSaves(GameState state) {
    return state.team2ShotData.where((shot) => !shot.isGoal).length;
  }

  /// Le gardien du joueur a-t-il réalisé au moins [count] arrêt(s) ?
  static bool madeSaves(GameState state, int count) {
    if (count <= 0) return false;
    return countSaves(state) >= count;
  }

  // ─── BUTS ENCAISSÉS ──────────────────────────────────────────────────────────

  /// Nombre de buts encaissés par le joueur (= buts marqués par l'IA).
  static int countGoalsConceded(GameState state) {
    return state.team2ShotData.where((shot) => shot.isGoal).length;
  }

  /// Le joueur a-t-il encaissé au maximum [maxGoals] buts ?
  static bool concededAtMost(GameState state, int maxGoals) {
    return countGoalsConceded(state) <= maxGoals;
  }

  // ─── SCORE FINAL ─────────────────────────────────────────────────────────────

  /// Le joueur a-t-il marqué au moins [minGoals] buts au total ?
  static bool scoredAtLeast(GameState state, int minGoals) {
    final total = state.team1ShotData.where((shot) => shot.isGoal).length;
    return total >= minGoals;
  }

  /// Le joueur a-t-il marqué exactement [count] buts ?
  static bool scoredExactly(GameState state, int count) {
    final total = state.team1ShotData.where((shot) => shot.isGoal).length;
    return total == count;
  }
}
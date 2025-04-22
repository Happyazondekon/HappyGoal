import 'dart:math';
import '../models/game_state.dart';
import '../constants.dart';

class GameLogic {
  static final Random _random = Random();

  // Returns true if goal is scored, false if saved
  static bool simulateShot(int shotDirection, int goalkeeperSkill) {
    // Goalkeeper has a higher chance to predict the direction based on skill
    int goalkeeperDirection = _predictGoalkeeperDirection(goalkeeperSkill);

    // Goal is scored if goalkeeper dives in wrong direction
    return shotDirection != goalkeeperDirection;
  }

  static int _predictGoalkeeperDirection(int goalkeeperSkill) {
    // Basic AI - higher skill increases chance of correct prediction
    // This is a simplified version

    double randomValue = _random.nextDouble();

    // Skill factor (0.5 to 0.8 based on skill 1-10)
    double skillFactor = 0.5 + (goalkeeperSkill / 30);

    // Random direction with skill influence
    if (randomValue < skillFactor) {
      // More skilled keeper has better chance at making the right call
      return _random.nextInt(3); // Completely random choice (0, 1, or 2)
    } else {
      // Less skilled keeper might make more mistakes
      return _random.nextInt(3); // Still random, but separate roll
    }
  }

  // More complex prediction could take into account player shooting patterns
  static int suggestOptimalDirection(List<int> previousShots) {
    // Simple implementation - could be expanded
    if (previousShots.isEmpty) {
      return ShotDirection.center;
    }

    // Count occurrences of each direction
    Map<int, int> counts = {
      ShotDirection.left: 0,
      ShotDirection.center: 0,
      ShotDirection.right: 0,
    };

    for (int shot in previousShots) {
      counts[shot] = (counts[shot] ?? 0) + 1;
    }

    // Find most common direction
    int maxCount = 0;
    int mostCommonDirection = ShotDirection.center;

    counts.forEach((direction, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommonDirection = direction;
      }
    });

    // Suggest opposite of most common direction as that might be unexpected
    switch (mostCommonDirection) {
      case ShotDirection.left:
        return ShotDirection.right;
      case ShotDirection.right:
        return ShotDirection.left;
      default:
      // If center is most common, randomize between left and right
        return _random.nextBool() ? ShotDirection.left : ShotDirection.right;
    }
  }
}
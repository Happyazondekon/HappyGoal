import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HeroProgression {
  final String selectedCountryCode;
  int currentLevel;
  final int maxLevel;
  final Map<int, int> starsPerLevel; // niveau -> nombre d'étoiles (0,1,2,3)

  /// Mémorise pour chaque niveau quels challenges ont été complétés
  /// lors du MEILLEUR passage (celui qui a donné le plus d'étoiles).
  /// completedPerLevel[level] = [true, false, true] par exemple.
  final Map<int, List<bool>> completedPerLevel;

  HeroProgression({
    required this.selectedCountryCode,
    this.currentLevel = 1,
    this.maxLevel = 100,
    Map<int, int>? starsPerLevel,
    Map<int, List<bool>>? completedPerLevel,
  })  : starsPerLevel = starsPerLevel ?? {},
        completedPerLevel = completedPerLevel ?? {};

  // Sérialisation JSON
  Map<String, dynamic> toJson() => {
    'selectedCountryCode': selectedCountryCode,
    'currentLevel': currentLevel,
    'maxLevel': maxLevel,
    'starsPerLevel': starsPerLevel.map((k, v) => MapEntry(k.toString(), v)),
    // On sérialise la liste de bool en liste d'int (0/1) pour JSON
    'completedPerLevel': completedPerLevel.map(
          (k, v) => MapEntry(k.toString(), v.map((b) => b ? 1 : 0).toList()),
    ),
  };

  static HeroProgression fromJson(Map<String, dynamic> json) {
    // Désérialisation de completedPerLevel (liste d'int 0/1 -> List<bool>)
    Map<int, List<bool>>? completed;
    final raw = json['completedPerLevel'] as Map<String, dynamic>?;
    if (raw != null) {
      completed = raw.map((k, v) {
        final list = (v as List).map((e) => e == 1).toList();
        return MapEntry(int.parse(k), list);
      });
    }

    return HeroProgression(
      selectedCountryCode: json['selectedCountryCode'],
      currentLevel: json['currentLevel'],
      maxLevel: json['maxLevel'] ?? 100,
      starsPerLevel: (json['starsPerLevel'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(int.parse(k), v as int)),
      completedPerLevel: completed,
    );
  }

  static const String _prefsKey = 'hero_progression';

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_prefsKey, jsonEncode(toJson()));
  }

  static Future<HeroProgression?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString == null) return null;
    return HeroProgression.fromJson(jsonDecode(jsonString));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  Future<void> resetProgression(String newCountryCode) async {
    currentLevel = 1;
    starsPerLevel.clear();
    completedPerLevel.clear();
    await save();
  }

  /// Met à jour la progression après un niveau terminé.
  /// [level]              : niveau joué
  /// [stars]              : nombre d'étoiles obtenues (calculé depuis les vrais challenges)
  /// [completedChallenges]: liste des challenges réellement complétés (index par index)
  Future<void> completeLevel(
      int level, int stars, List<bool> completedChallenges) async {
    final previous = starsPerLevel[level] ?? 0;
    // On ne remplace que si le joueur a fait mieux qu'avant
    if (stars > previous) {
      starsPerLevel[level] = stars;
      // On mémorise exactement quels challenges ont été complétés
      completedPerLevel[level] = List<bool>.from(completedChallenges);
    }
    if (level == currentLevel && currentLevel < maxLevel && stars > 0) {
      currentLevel++;
    }
    await save();
  }

  /// Retourne la liste des challenges complétés pour un niveau donné.
  /// Retourne une liste vide si le niveau n'a jamais été joué.
  List<bool> getCompletedChallenges(int level) {
    return completedPerLevel[level] ?? [];
  }
}
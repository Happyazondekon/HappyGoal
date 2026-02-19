import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HeroProgression {
  final String selectedCountryCode;
  int currentLevel;
  final int maxLevel;
  final Map<int, int> starsPerLevel; // niveau -> étoiles (1,2,3)

  HeroProgression({
    required this.selectedCountryCode,
    this.currentLevel = 1,
    this.maxLevel = 100,
    Map<int, int>? starsPerLevel,
  }) : starsPerLevel = starsPerLevel ?? {};

  // Sérialisation JSON
  Map<String, dynamic> toJson() => {
    'selectedCountryCode': selectedCountryCode,
    'currentLevel': currentLevel,
    'maxLevel': maxLevel,
    'starsPerLevel': starsPerLevel.map((k, v) => MapEntry(k.toString(), v)),
  };

  static HeroProgression fromJson(Map<String, dynamic> json) {
    return HeroProgression(
      selectedCountryCode: json['selectedCountryCode'],
      currentLevel: json['currentLevel'],
      maxLevel: json['maxLevel'] ?? 100,
      starsPerLevel: (json['starsPerLevel'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(int.parse(k), v as int)),
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
    await save();
  }

  Future<void> completeLevel(int level, int stars) async {
    // On garde le meilleur score d'étoiles pour chaque niveau
    final previous = starsPerLevel[level] ?? 0;
    if (stars > previous) {
      starsPerLevel[level] = stars;
    }
    if (level == currentLevel && currentLevel < maxLevel && stars > 0) {
      currentLevel++;
    }
    await save();
  }
}

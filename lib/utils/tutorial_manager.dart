import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialManager {
  static const String _tutorialPrefix = 'tutorial_shown_';

  static Future<bool> shouldShowTutorial(String screenName) async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('$_tutorialPrefix$screenName') ?? false);
  }

  static Future<void> markTutorialAsShown(String screenName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_tutorialPrefix$screenName', true);
  }

  static Future<void> resetTutorials() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_tutorialPrefix));
    for (String key in keys) {
      await prefs.remove(key);
    }
  }
}
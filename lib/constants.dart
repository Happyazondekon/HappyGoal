import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1B6B3A);
  static const Color secondary = Color(0xFF2196F3);
  static const Color background = Color(0xFFF5F5F5);
  static const Color fieldGreen = Color(0xFF4CAF50);
  static const Color team1 = Color(0xFF1E88E5);
  static const Color team2 = Color(0xFF1E88E5);
}

class GameSettings {
  static const int winningScore = 20;
  static const double fieldWidth = 360.0;
  static const double fieldHeight = 500.0;
  static const double goalWidth = 240.0;
  static const double goalHeight = 120.0;
}

class ShotDirection {
  static const int left = 0;
  static const int center = 1;
  static const int right = 2;
}
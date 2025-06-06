import 'package:flutter/material.dart';


class Team {
  final String name;
  final Color color;
  final String flagImage;
  int score;

  Team({
    required this.name,
    required this.color,
    required this.flagImage,
    this.score = 0,
  });

  void incrementScore() {
    score++;
  }

  void resetScore() {
    score = 0;
  }

  static List<Team> getPredefinedTeams() {
    return [
      Team(
        name: 'France',
        color: Colors.blue,
        flagImage: 'assets/images/flags/france_flag.png',
      ),
      Team(
        name: 'Bénin',
        color: Colors.yellow,
        flagImage: 'assets/images/flags/benin_flag.png',
      ),
      Team(
        name: 'Allemagne',
        color: Colors.greenAccent,
        flagImage: 'assets/images/flags/germany_flag.png',
      ),
      Team(
        name: 'Espagne',
        color: Colors.red,
        flagImage: 'assets/images/flags/spain_flag.png',
      ),
      Team(
        name: 'Argentine',
        color: Colors.lightBlueAccent,
        flagImage: 'assets/images/flags/argentina_flag.png',
      ),
      Team(
        name: 'Italie',
        color: Colors.green,
        flagImage: 'assets/images/flags/italy_flag.png',
      ),
      Team(
        name: 'Brésil',
        color: Colors.yellow,
        flagImage: 'assets/images/flags/brasil_flag.png',
      ),
      Team(
        name: 'Nigéria',
        color: Colors.green,
        flagImage: 'assets/images/flags/nigeria_flag.png',
      ),
      Team(
        name: 'Japon',
        color: Colors.greenAccent,
        flagImage: 'assets/images/flags/japan_flag.png',
      ),
      Team(
        name: 'Russie',
        color: Colors.blue,
        flagImage: 'assets/images/flags/russia_flag.png',
      ),
      Team(
        name: 'Angleterre',
        color: Colors.white70,
        flagImage: 'assets/images/flags/england_flag.png',
      ),
      Team(
        name: 'USA',
        color: Colors.red,
        flagImage: 'assets/images/flags/usa_flag.png',
      ),
    ];
  }
}
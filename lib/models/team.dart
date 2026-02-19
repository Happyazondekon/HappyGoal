// lib/models/team.dart
import 'package:flutter/material.dart';

class Team {
    Team copyWith({
      String? name,
      Color? color,
      String? flagImage,
      String? continent,
      int? score,
    }) {
      return Team(
        name: name ?? this.name,
        color: color ?? this.color,
        flagImage: flagImage ?? this.flagImage,
        continent: continent ?? this.continent,
        score: score ?? this.score,
      );
    }
  final String name;
  final Color color;
  final String flagImage;
  final String continent; // Nouvelle propriété
  int score;

  Team({
    required this.name,
    required this.color,
    required this.flagImage,
    required this.continent, // Nouvelle propriété
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
      // Europe
      Team(
        name: 'France',
        color: Colors.blue,
        flagImage: 'assets/images/flags/france_flag.png',
        continent: 'Europe',
      ),
      Team(
        name: 'Allemagne',
        color: Colors.greenAccent,
        flagImage: 'assets/images/flags/germany_flag.png',
        continent: 'Europe',
      ),
      Team(
        name: 'Espagne',
        color: Colors.red,
        flagImage: 'assets/images/flags/spain_flag.png',
        continent: 'Europe',
      ),
      Team(
        name: 'Italie',
        color: Colors.green,
        flagImage: 'assets/images/flags/italy_flag.png',
        continent: 'Europe',
      ),
      Team(
        name: 'Russie',
        color: Colors.blue,
        flagImage: 'assets/images/flags/russia_flag.png',
        continent: 'Europe',
      ),
      Team(
        name: 'Angleterre',
        color: Colors.white70,
        flagImage: 'assets/images/flags/england_flag.png',
        continent: 'Europe',
      ),
      Team(
        name: 'Portugal',
        color: Colors.red,
        flagImage: 'assets/images/flags/portugal_flag.png',
        continent: 'Europe',
      ),
      Team(
        name: 'Belgique',
        color: Colors.black,
        flagImage: 'assets/images/flags/belgium_flag.png',
        continent: 'Europe',
      ),

      // Amérique
      Team(
        name: 'Argentine',
        color: Colors.lightBlueAccent,
        flagImage: 'assets/images/flags/argentina_flag.png',
        continent: 'Amérique',
      ),
      Team(
        name: 'Brésil',
        color: Colors.yellow,
        flagImage: 'assets/images/flags/brasil_flag.png',
        continent: 'Amérique',
      ),
      Team(
        name: 'USA',
        color: Colors.red,
        flagImage: 'assets/images/flags/usa_flag.png',
        continent: 'Amérique',
      ),
      Team(
        name: 'Canada',
        color: Colors.red,
        flagImage: 'assets/images/flags/canada_flag.png',
        continent: 'Amérique',
      ),

      // Afrique
      Team(
        name: 'Bénin',
        color: Colors.yellow,
        flagImage: 'assets/images/flags/benin_flag.png',
        continent: 'Afrique',
      ),
      Team(
        name: 'Nigéria',
        color: Colors.green,
        flagImage: 'assets/images/flags/nigeria_flag.png',
        continent: 'Afrique',
      ),
      Team(
        name: 'Togo',
        color: Colors.red,
        flagImage: 'assets/images/flags/togo_flag.png',
        continent: 'Afrique',
      ),
      Team(
        name: 'Niger',
        color: Colors.yellow,
        flagImage: 'assets/images/flags/niger_flag.png',
        continent: 'Afrique',
      ),
      Team(
        name: 'Ghana',
        color: Colors.white,
        flagImage: 'assets/images/flags/ghana_flag.png',
        continent: 'Afrique',
      ),
      Team(
        name: 'Côte d\'Ivoire',
        color: Colors.orange,
        flagImage: 'assets/images/flags/ivory_coast_flag.png',
        continent: 'Afrique',
      ),

      // Asie
      Team(
        name: 'Japon',
        color: Colors.greenAccent,
        flagImage: 'assets/images/flags/japan_flag.png',
        continent: 'Asie',
      ),
      Team(
        name: 'Corée du Sud',
        color: Colors.red,
        flagImage: 'assets/images/flags/south_korea_flag.png',
        continent: 'Asie',
      ),
      Team(
        name: 'Chine',
        color: Colors.red,
        flagImage: 'assets/images/flags/china_flag.png',
        continent: 'Asie',
      ),
      Team(
        name: 'Arabie Saoudite',
        color: Colors.green,
        flagImage: 'assets/images/flags/saudi_arabia_flag.png',
        continent: 'Asie',
      ),

      // Océanie
      Team(
        name: 'Australie',
        color: Colors.blue,
        flagImage: 'assets/images/flags/australia_flag.png',
        continent: 'Océanie',
      ),
    ];
  }
}
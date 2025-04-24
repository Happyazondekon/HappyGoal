import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/team.dart';
import '../models/game_state.dart';

class ScoreBoardWidget extends StatelessWidget {
  final Team team1;
  final Team team2;
  final Team currentTeam;
  final List<bool> team1Results;
  final List<bool> team2Results;
  final int shotsPerTeam;

  const ScoreBoardWidget({
    Key? key,
    required this.team1,
    required this.team2,
    required this.currentTeam,
    required this.team1Results,
    required this.team2Results,
    required this.shotsPerTeam,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTeamScore(team1, AppColors.team1, currentTeam == team1),
              Text(
                "${team1.score} - ${team2.score}",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildTeamScore(team2, AppColors.team2, currentTeam == team2),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildShotIndicators(team1Results, shotsPerTeam),
              _buildShotIndicators(team2Results, shotsPerTeam),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamScore(Team team, Color color, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        border: isActive
            ? Border.all(color: color, width: 2)
            : null,
      ),
      child: Row(
        children: [
          Image.asset(
            team.flagImage,
            width: 30,
            height: 20,
          ),
          const SizedBox(width: 8),
          Text(
            team.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShotIndicators(List<bool> results, int maxShots) {
    // Créer une liste fixe de 5 indicateurs (ou le nombre spécifié par maxShots)
    List<Widget> indicators = [];

    // Ajouter les résultats déjà joués
    for (int i = 0; i < results.length; i++) {
      indicators.add(
          _buildShotIndicator(results[i])
      );
    }

    // Ajouter des espaces vides pour les tirs restants (réguliers seulement)
    for (int i = results.length; i < maxShots; i++) {
      indicators.add(
          _buildEmptyShotIndicator()
      );
    }

    return Row(
      children: indicators,
    );
  }

  Widget _buildShotIndicator(bool isGoal) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isGoal ? Colors.green : Colors.red,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Center(
        child: Icon(
          isGoal ? Icons.check : Icons.close,
          color: Colors.white,
          size: 14,
        ),
      ),
    );
  }

  Widget _buildEmptyShotIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey, width: 1),
      ),
    );
  }
}
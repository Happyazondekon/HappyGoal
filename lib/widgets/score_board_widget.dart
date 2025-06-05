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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF8BC34A),
            Color(0xFFF5F5F5),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Team names and flags
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTeamHeader(team1, currentTeam == team1),
              _buildScoreDisplay(),
              _buildTeamHeader(team2, currentTeam == team2),
            ],
          ),

          const SizedBox(height: 10),

          // Shot indicators
          _buildShotIndicatorsRow(),
        ],
      ),
    );
  }

  Widget _buildTeamHeader(Team team, bool isActive) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? const Color(0xFF4B92DB) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Image.asset(
            team.flagImage,
            width: 36,
            height: 36,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          team.name.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF8BC34A),
            Color(0xFFF5F5F5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.5),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        "${team1.score} - ${team2.score}",
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              blurRadius: 5,
              color: Colors.black,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShotIndicatorsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTeamShots(team1Results, AppColors.team1),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "TIRS",
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              letterSpacing: 1.0,
            ),
          ),
        ),
        _buildTeamShots(team2Results, AppColors.team2),
      ],
    );
  }

  Widget _buildTeamShots(List<bool> results, Color color) {
    return Row(
      children: [
        for (int i = 0; i < results.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _buildShotIndicator(results[i], color),
          ),
        for (int i = results.length; i < shotsPerTeam; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _buildEmptyShotIndicator(),
          ),
      ],
    );
  }

  Widget _buildShotIndicator(bool isGoal, Color color) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: isGoal ? color : Colors.red[400],
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          isGoal ? Icons.check : Icons.close,
          color: Colors.white,
          size: 10,
        ),
      ),
    );
  }

  Widget _buildEmptyShotIndicator() {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(1),
          width: 1,
        ),
      ),
    );
  }
}
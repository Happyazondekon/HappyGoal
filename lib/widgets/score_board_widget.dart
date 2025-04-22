import 'package:flutter/material.dart';
import '../models/team.dart';
import '../constants.dart';

class ScoreBoardWidget extends StatelessWidget {
  final Team team1;
  final Team team2;
  final Team currentTeam;

  const ScoreBoardWidget({
    Key? key,
    required this.team1,
    required this.team2,
    required this.currentTeam,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      color: Colors.black.withOpacity(0.6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Team 1
          _buildTeamScore(
            team: team1,
            isActive: currentTeam == team1,
            alignment: MainAxisAlignment.start,
          ),

          // VS
          const Text(
            'VS',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),

          // Team 2
          _buildTeamScore(
            team: team2,
            isActive: currentTeam == team2,
            alignment: MainAxisAlignment.end,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamScore({
    required Team team,
    required bool isActive,
    required MainAxisAlignment alignment,
  }) {
    return Expanded(
      child: Row(
        mainAxisAlignment: alignment,
        children: [
          if (alignment == MainAxisAlignment.end)
            Text(
              '${team.score}',
              style: TextStyle(
                color: isActive ? Colors.yellow : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),

          const SizedBox(width: 10),

          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(
                color: isActive ? Colors.yellow : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Image.asset(
                  team.flagImage,
                  width: 30,
                  height: 20,
                ),
                const SizedBox(width: 5),
                Text(
                  team.name,
                  style: TextStyle(
                    color: isActive ? Colors.yellow : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          if (alignment == MainAxisAlignment.start)
            Row(
              children: [
                const SizedBox(width: 10),
                Text(
                  '${team.score}',
                  style: TextStyle(
                    color: isActive ? Colors.yellow : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:happygoal/constants.dart';
import 'package:happygoal/models/team.dart';
import 'package:happygoal/models/game_state.dart';
import 'package:happygoal/utils/responsive_helper.dart';

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
      padding: EdgeInsets.all(ResponsiveHelper.scale(context, 12)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2E7D32),
            Color(0xFFF5F5F5),
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveHelper.scale(context, 8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: ResponsiveHelper.scale(context, 10),
            offset: Offset(0, ResponsiveHelper.scale(context, 5)),
          ),
        ],
        border: Border.all(
          color: Colors.white,
          width: ResponsiveHelper.scale(context, 1),
        ),
      ),
      child: Column(
        children: [
          // Team names and flags
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTeamHeader(context, team1, currentTeam == team1),
              _buildScoreDisplay(context),
              _buildTeamHeader(context, team2, currentTeam == team2),
            ],
          ),
          SizedBox(height: ResponsiveHelper.scale(context, 10)),
          // Shot indicators
          _buildShotIndicatorsRow(context),
        ],
      ),
    );
  }

  Widget _buildTeamHeader(BuildContext context, Team team, bool isActive) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveHelper.scale(context, 4)),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? const Color(0xFF4B92DB) : Colors.transparent,
              width: ResponsiveHelper.scale(context, 2),
            ),
          ),
          child: Image.asset(
            team.flagImage,
            width: ResponsiveHelper.scale(context, 36),
            height: ResponsiveHelper.scale(context, 36),
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: ResponsiveHelper.scale(context, 4)),
        Text(
          team.name.toUpperCase(),
          style: TextStyle(
            fontSize: ResponsiveHelper.textScale(context, 12),
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreDisplay(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.scale(context, 16), vertical: ResponsiveHelper.scale(context, 4)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2E7D32),
            Color(0xFFF5F5F5),
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveHelper.scale(context, 20)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.5),
            blurRadius: ResponsiveHelper.scale(context, 5),
            offset: Offset(0, ResponsiveHelper.scale(context, 2)),
          ),
        ],
      ),
      child: Text(
        "${team1.score} - ${team2.score}",
        style: TextStyle(
          fontSize: ResponsiveHelper.textScale(context, 24),
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              blurRadius: ResponsiveHelper.scale(context, 5),
              color: Colors.black,
              offset: Offset(0, ResponsiveHelper.scale(context, 1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShotIndicatorsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTeamShots(context, team1Results, AppColors.team1),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.scale(context, 8)),
          child: Text(
            "TIRS",
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveHelper.textScale(context, 11),
              letterSpacing: 1.0,
            ),
          ),
        ),
        _buildTeamShots(context, team2Results, AppColors.team2),
      ],
    );
  }

  Widget _buildTeamShots(BuildContext context, List<bool> results, Color color) {
    return Row(
      children: [
        for (int i = 0; i < results.length; i++)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.scale(context, 2)),
            child: _buildShotIndicator(context, results[i], color),
          ),
        for (int i = results.length; i < shotsPerTeam; i++)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.scale(context, 2)),
            child: _buildEmptyShotIndicator(context),
          ),
      ],
    );
  }

  Widget _buildShotIndicator(BuildContext context, bool isGoal, Color color) {
    return Container(
      width: ResponsiveHelper.scale(context, 16),
      height: ResponsiveHelper.scale(context, 16),
      decoration: BoxDecoration(
        color: isGoal ? color : Colors.red[400],
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: ResponsiveHelper.scale(context, 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: ResponsiveHelper.scale(context, 2),
            offset: Offset(0, ResponsiveHelper.scale(context, 1)),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          isGoal ? Icons.check : Icons.close,
          color: Colors.white,
          size: ResponsiveHelper.scale(context, 10),
        ),
      ),
    );
  }

  Widget _buildEmptyShotIndicator(BuildContext context) {
    return Container(
      width: ResponsiveHelper.scale(context, 16),
      height: ResponsiveHelper.scale(context, 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(1),
          width: ResponsiveHelper.scale(context, 1),
        ),
      ),
    );
  }
}
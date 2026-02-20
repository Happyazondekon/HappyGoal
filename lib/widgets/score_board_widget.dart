import 'package:flutter/material.dart';
import 'package:happygoal/constants.dart';
import 'package:happygoal/models/team.dart';
import 'package:happygoal/models/game_state.dart';
import 'package:happygoal/utils/responsive_helper.dart';

class ScoreBoardWidget extends StatefulWidget {
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
  State<ScoreBoardWidget> createState() => _ScoreBoardWidgetState();
}

class _ScoreBoardWidgetState extends State<ScoreBoardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.scale(context, 16)),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.5,
          colors: [
            const Color(0xFF1A3A22),
            const Color(0xFF0A1A0F),
            const Color(0xFF050D07),
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveHelper.scale(context, 20)),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: ResponsiveHelper.scale(context, 1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.2),
            blurRadius: ResponsiveHelper.scale(context, 15),
            offset: Offset(0, ResponsiveHelper.scale(context, 6)),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: ResponsiveHelper.scale(context, 20),
            offset: Offset(0, ResponsiveHelper.scale(context, 8)),
          ),
        ],
      ),
      child: Column(
        children: [
          // Team names and flags
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTeamHeader(context, widget.team1, widget.currentTeam == widget.team1),
              _buildScoreDisplay(context),
              _buildTeamHeader(context, widget.team2, widget.currentTeam == widget.team2),
            ],
          ),
          SizedBox(height: ResponsiveHelper.scale(context, 14)),
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
          padding: EdgeInsets.all(ResponsiveHelper.scale(context, 6)),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? const Color(0xFFFFD700) : Colors.white.withOpacity(0.3),
              width: ResponsiveHelper.scale(context, 2.5),
            ),
            boxShadow: [
              BoxShadow(
                color: isActive
                    ? const Color(0xFFFFD700).withOpacity(0.4)
                    : Colors.transparent,
                blurRadius: ResponsiveHelper.scale(context, 8),
                spreadRadius: ResponsiveHelper.scale(context, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(ResponsiveHelper.scale(context, 20)),
            child: Image.asset(
              team.flagImage,
              width: ResponsiveHelper.scale(context, 44),
              height: ResponsiveHelper.scale(context, 44),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: ResponsiveHelper.scale(context, 6)),
        Text(
          team.name.toUpperCase(),
          style: TextStyle(
            fontSize: ResponsiveHelper.textScale(context, 13),
            fontWeight: FontWeight.bold,
            color: isActive ? const Color(0xFFFFD700) : Colors.white,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: ResponsiveHelper.scale(context, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreDisplay(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.scale(context, 20),
            vertical: ResponsiveHelper.scale(context, 8),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFFD700),
                const Color(0xFFF57F17),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(ResponsiveHelper.scale(context, 24)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.5 * _pulseAnim.value),
                blurRadius: ResponsiveHelper.scale(context, 16),
                spreadRadius: ResponsiveHelper.scale(context, 2),
                offset: Offset(0, ResponsiveHelper.scale(context, 4)),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: ResponsiveHelper.scale(context, 8),
                offset: Offset(0, ResponsiveHelper.scale(context, 2)),
              ),
            ],
          ),
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Colors.white,
                Colors.white.withOpacity(0.9),
              ],
            ).createShader(bounds),
            child: Text(
              "${widget.team1.score} - ${widget.team2.score}",
              style: TextStyle(
                fontSize: ResponsiveHelper.textScale(context, 32),
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    blurRadius: ResponsiveHelper.scale(context, 4),
                    color: Colors.black.withOpacity(0.4),
                    offset: Offset(0, ResponsiveHelper.scale(context, 2)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShotIndicatorsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTeamShots(context, widget.team1Results, const Color(0xFFFFD700)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.scale(context, 12)),
          child: Column(
            children: [
              Text(
                "●",
                style: TextStyle(
                  color: const Color(0xFFFFD700),
                  fontSize: ResponsiveHelper.textScale(context, 18),
                ),
              ),
              Text(
                "SHOTS",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: ResponsiveHelper.textScale(context, 10),
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        _buildTeamShots(context, widget.team2Results, const Color(0xFFFFD700)),
      ],
    );
  }

  Widget _buildTeamShots(BuildContext context, List<bool> results, Color color) {
    return Row(
      children: [
        for (int i = 0; i < results.length; i++)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.scale(context, 3)),
            child: _buildShotIndicator(context, results[i], color),
          ),
        for (int i = results.length; i < widget.shotsPerTeam; i++)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.scale(context, 3)),
            child: _buildEmptyShotIndicator(context),
          ),
      ],
    );
  }

  Widget _buildShotIndicator(BuildContext context, bool isGoal, Color color) {
    return Container(
      width: ResponsiveHelper.scale(context, 18),
      height: ResponsiveHelper.scale(context, 18),
      decoration: BoxDecoration(
        gradient: isGoal
            ? LinearGradient(
          colors: [
            color,
            color.withOpacity(0.7),
          ],
        )
            : LinearGradient(
          colors: [
            const Color(0xFFE53935),
            const Color(0xFFC62828),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: ResponsiveHelper.scale(context, 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: (isGoal ? color : const Color(0xFFE53935)).withOpacity(0.4),
            blurRadius: ResponsiveHelper.scale(context, 6),
            spreadRadius: ResponsiveHelper.scale(context, 1),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          isGoal ? Icons.check : Icons.close,
          color: Colors.white,
          size: ResponsiveHelper.scale(context, 11),
        ),
      ),
    );
  }

  Widget _buildEmptyShotIndicator(BuildContext context) {
    return Container(
      width: ResponsiveHelper.scale(context, 18),
      height: ResponsiveHelper.scale(context, 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
          width: ResponsiveHelper.scale(context, 1),
        ),
      ),
    );
  }
}
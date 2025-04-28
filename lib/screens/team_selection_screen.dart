// lib/screens/team_selection_screen.dart
import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/team.dart';
import '../models/game_state.dart';
import 'game_screen.dart';

class TeamSelectionScreen extends StatefulWidget {
  final bool isSoloMode;

  const TeamSelectionScreen({
    Key? key,
    this.isSoloMode = false,
  }) : super(key: key);

  @override
  State<TeamSelectionScreen> createState() => _TeamSelectionScreenState();
}

class _TeamSelectionScreenState extends State<TeamSelectionScreen> with SingleTickerProviderStateMixin {
  Team? selectedTeam1;
  Team? selectedTeam2;
  final List<Team> teams = Team.getPredefinedTeams();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late String _modeTitle;

  @override
  void initState() {
    super.initState();
    _modeTitle = widget.isSoloMode ? 'Mode Solo' : 'Mode Multijoueur';

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTeamSelection(Team team) {
    setState(() {
      if (team == selectedTeam1) {
        selectedTeam1 = null;
        _controller.reverse();
      } else if (team == selectedTeam2) {
        selectedTeam2 = null;
        _controller.reverse();
      } else if (selectedTeam1 == null) {
        selectedTeam1 = team;
        _controller.forward();
      } else if (selectedTeam2 == null && team != selectedTeam1) {
        selectedTeam2 = team;
        _controller.forward();
      }
    });
  }

  void _startGame() {
    if (selectedTeam1 != null && selectedTeam2 != null) {
      final gameState = GameState(
        team1: selectedTeam1,
        team2: selectedTeam2,
        currentPhase: GamePhase.playerShooting,
        isSoloMode: widget.isSoloMode,
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GameScreen(gameState: gameState),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner deux équipes')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sélection des équipes'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Chip(
              label: Text(_modeTitle),
              backgroundColor: AppColors.primary,
              labelStyle: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),

          // Texte d'aide en mode solo
          if (widget.isSoloMode)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Choisissez votre équipe et l\'équipe adverse contrôlée par l\'ordinateur',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: const Offset(1.0, 1.0),
                      blurRadius: 3.0,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),

          // Affichage des équipes sélectionnées
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSelectedTeamCard(
                      team: selectedTeam1,
                      teamColor: AppColors.team1,
                      label: widget.isSoloMode ? 'Votre Équipe' : 'Équipe 1',
                    ),
                    _buildSelectedTeamCard(
                      team: selectedTeam2,
                      teamColor: AppColors.team2,
                      label: widget.isSoloMode ? 'Équipe IA' : 'Équipe 2',
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          // Grille des équipes disponibles
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: teams.length,
                itemBuilder: (context, index) {
                  final team = teams[index];
                  final bool isSelected = team == selectedTeam1 || team == selectedTeam2;
                  final bool isDisabled = (selectedTeam1 == team && selectedTeam2 != null) ||
                      (selectedTeam2 == team && selectedTeam1 != null);

                  return _buildTeamCard(team, isSelected, isDisabled);
                },
              ),
            ),
          ),
          // Bouton de démarrage
          Padding(
            padding: const EdgeInsets.all(20),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: selectedTeam1 != null && selectedTeam2 != null ? 1.0 : 0.5,
              child: ElevatedButton(
                onPressed: selectedTeam1 != null && selectedTeam2 != null ? _startGame : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                  shadowColor: AppColors.primary.withOpacity(0.5),
                ),
                child: const Text(
                  'COMMENCER LE MATCH',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTeamCard({
    required Team? team,
    required Color teamColor,
    required String label,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          if (team != null) ...[
            Container(
              height: 60,
              width: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: teamColor,
                  width: 2,
                ),
              ),
              child: Image.asset(
                team.flagImage,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              team.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: teamColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ] else ...[
            Container(
              height: 60,
              width: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade200,
              ),
              child: const Icon(
                Icons.flag,
                size: 30,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'À sélectionner',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTeamCard(Team team, bool isSelected, bool isDisabled) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? team.color.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? (team == selectedTeam1 ? AppColors.team1 : AppColors.team2)
              : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: team.color.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isDisabled ? null : () => _handleTeamSelection(team),
          child: Opacity(
            opacity: isDisabled ? 0.5 : 1.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  team.flagImage,
                  height: 50,
                  width: 80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
                Text(
                  team.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDisabled ? Colors.grey : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
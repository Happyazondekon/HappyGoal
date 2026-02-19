// lib/screens/team_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:happygoal/constants.dart';
import 'package:happygoal/models/team.dart';
import 'package:happygoal/models/game_state.dart';
import 'game_screen.dart';
import 'package:happygoal/models/ai_opponent.dart';

class TeamSelectionScreen extends StatefulWidget {
  final bool isSoloMode;
  final bool isTournamentMode;
  final Function(Team)? onTeamSelected;
  final double? aiIntelligence;
  final Team? preSelectedTeam1;
  final Team? preSelectedTeam2;
  final bool startDirectly;

  const TeamSelectionScreen({
    Key? key,
    this.isSoloMode = false,
    this.isTournamentMode = false,
    this.aiIntelligence,
    this.preSelectedTeam1,
    this.preSelectedTeam2,
    this.startDirectly = false, this.onTeamSelected,
  }) : super(key: key);


  @override
  State<TeamSelectionScreen> createState() => _TeamSelectionScreenState();
}


class _TeamSelectionScreenState extends State<TeamSelectionScreen> with SingleTickerProviderStateMixin {
  Team? selectedTeam1;
  Team? selectedTeam2;
  late final Map<String, List<Team>> _teamsByContinent;
  String? _selectedContinent;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late String _modeTitle;

  @override
  void initState() {
    super.initState();
    // Grouper les équipes par continent
    _teamsByContinent = _groupTeamsByContinent(Team.getPredefinedTeams());

    if (widget.preSelectedTeam1 != null) {
      selectedTeam1 = widget.preSelectedTeam1;
    }
    if (widget.preSelectedTeam2 != null) {
      selectedTeam2 = widget.preSelectedTeam2;
    }

    if (widget.startDirectly && selectedTeam1 != null && selectedTeam2 != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startGame();
      });
    }

    if (widget.isTournamentMode) {
      _modeTitle = 'Mode Tournoi';
    } else {
      _modeTitle = widget.isSoloMode ? 'Mode Solo' : 'Mode Multijoueur';
    }

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

  // Méthode pour regrouper les équipes par continent
  Map<String, List<Team>> _groupTeamsByContinent(List<Team> allTeams) {
    Map<String, List<Team>> map = {};
    for (var team in allTeams) {
      if (!map.containsKey(team.continent)) {
        map[team.continent] = [];
      }
      map[team.continent]!.add(team);
    }
    return map;
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
    if (widget.isTournamentMode) {
      widget.onTeamSelected?.call(team);
      Navigator.pop(context);
      return;
    }
  }

  void _startGame() {
    if (selectedTeam1 != null && selectedTeam2 != null) {
      final gameState = GameState(
        team1: selectedTeam1!,
        team2: selectedTeam2!,
        currentPhase: GamePhase.playerShooting,
        isSoloMode: widget.isSoloMode,
        isTournamentMode: widget.isTournamentMode,
      );

      if (widget.isSoloMode && widget.aiIntelligence != null) {
        gameState.aiOpponent = AIOpponent(intelligence: widget.aiIntelligence!);
      }

      Navigator.push(
        context,
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
        title: Text(_selectedContinent ?? 'Sélection des équipes'),
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
        leading: _selectedContinent != null
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _selectedContinent = null;
            });
          },
        )
            : null,
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _selectedContinent == null
                  ? _buildContinentList()
                  : _buildTeamsGridView(_teamsByContinent[_selectedContinent]!),
            ),
          ),
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

  // Widget pour afficher la liste des continents
  Widget _buildContinentList() {
    final continents = _teamsByContinent.keys.toList();
    return ListView.builder(
      itemCount: continents.length,
      itemBuilder: (context, index) {
        final continent = continents[index];
        final continentTeams = _teamsByContinent[continent]!;
        // Déterminer la première équipe du continent pour l'image
        final displayTeam = continentTeams.isNotEmpty ? continentTeams.first : null;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedContinent = continent;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (displayTeam != null)
                    Image.asset(
                      displayTeam.flagImage,
                      height: 50,
                      width: 80,
                      fit: BoxFit.contain,
                    ),
                  const SizedBox(width: 20),
                  Text(
                    continent,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget pour afficher la grille des équipes d'un continent
  Widget _buildTeamsGridView(List<Team> teams) {
    return GridView.builder(
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
        final bool isDisabled = !isSelected &&
            (selectedTeam1 != null && selectedTeam2 != null);

        return _buildTeamCard(team, isSelected, isDisabled);
      },
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
          onTap: () => _handleTeamSelection(team),
          child: Opacity(
            opacity: isDisabled && !isSelected ? 0.5 : 1.0,
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
                    color: isDisabled && !isSelected ? Colors.grey : Colors.black,
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
import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/team.dart';
import '../models/game_state.dart';
import 'game_screen.dart';

class TeamSelectionScreen extends StatefulWidget {
  const TeamSelectionScreen({Key? key}) : super(key: key);

  @override
  State<TeamSelectionScreen> createState() => _TeamSelectionScreenState();
}

class _TeamSelectionScreenState extends State<TeamSelectionScreen> {
  Team? selectedTeam1;
  Team? selectedTeam2;
  final List<Team> teams = Team.getPredefinedTeams();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélection des équipes'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            selectedTeam1 == null ? 'Choisissez l\'équipe 1' : 'Équipe 1: ${selectedTeam1!.name}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.team1,
            ),
          ),
          const SizedBox(height: 10),
          if (selectedTeam1 != null)
            Text(
              selectedTeam2 == null ? 'Choisissez l\'équipe 2' : 'Équipe 2: ${selectedTeam2!.name}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.team2,
              ),
            ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                final bool isSelected = team == selectedTeam1 || team == selectedTeam2;
                final bool isDisabled =
                    (selectedTeam1 != null && selectedTeam2 != null) ||
                        (selectedTeam1 != null && team == selectedTeam1) ||
                        (selectedTeam2 != null && team == selectedTeam2);

                return GestureDetector(
                  onTap: isDisabled ? null : () {
                    setState(() {
                      if (selectedTeam1 == null) {
                        selectedTeam1 = team;
                      } else if (selectedTeam2 == null && team != selectedTeam1) {
                        selectedTeam2 = team;
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.grey.shade300 : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? team == selectedTeam1 ? AppColors.team1 : AppColors.team2 : Colors.grey,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          team.flagImage,
                          height: 60,
                          width: 100,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          team.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: selectedTeam1 != null && selectedTeam2 != null
                  ? () {
                final gameState = GameState(
                  team1: selectedTeam1,
                  team2: selectedTeam2,
                  currentPhase: GamePhase.playerShooting,
                );

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => GameScreen(gameState: gameState),
                  ),
                );
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'COMMENCER',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
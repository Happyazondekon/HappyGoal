// tournament_mode_screen.dart
import 'package:flutter/material.dart';
import 'package:happygoal/screens/game_screen.dart';
import '../models/team.dart';
import '../models/game_state.dart';
import 'team_selection_screen.dart';
import '../constants.dart';

class TournamentModeScreen extends StatefulWidget {
  const TournamentModeScreen({Key? key}) : super(key: key);

  @override
  _TournamentModeScreenState createState() => _TournamentModeScreenState();
}

class _TournamentModeScreenState extends State<TournamentModeScreen> {
  Team? selectedTeam;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/stadium_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Mode Tournoi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 4.0,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Affrontez 8 équipes IA\net remportez la coupe!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    shadows: [
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 2.0,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Affichage de l'équipe sélectionnée
                if (selectedTeam != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Votre équipe:',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Image.asset(
                          selectedTeam!.flagImage,
                          height: 60,
                          width: 100,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          selectedTeam!.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: selectedTeam!.color,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeamSelectionScreen(
                          isSoloMode: true,
                          isTournamentMode: true,
                          onTeamSelected: (team) {
                            setState(() {
                              selectedTeam = team;
                            });
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'CHOISIR VOTRE ÉQUIPE',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Spacer(),

                if (selectedTeam != null)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: // Remplacez le bouton "COMMENCER LE TOURNOI" dans tournament_mode_screen.dart

                    ElevatedButton(
                      onPressed: () {
                        // Obtenir toutes les équipes disponibles
                        List<Team> allTeams = Team.getPredefinedTeams();

                        // S'assurer qu'on a assez d'équipes pour un tournoi (minimum 8)
                        if (allTeams.length < 8) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pas assez d\'équipes pour un tournoi complet'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Créer l'état du tournoi
                        final tournamentState = TournamentState(
                          allTeams: allTeams,
                          userTeam: selectedTeam,
                        );

                        // Démarrer le tournoi
                        tournamentState.startTournament();

                        // Créer l'état de jeu avec le premier adversaire
                        final gameState = GameState(
                          team1: selectedTeam,
                          team2: tournamentState.currentOpponent,
                          isSoloMode: true,
                          isTournamentMode: true,
                          currentPhase: GamePhase.playerShooting,
                        );

                        // Associer l'état du tournoi à l'état de jeu
                        gameState.tournamentState = tournamentState;

                        // Debug: afficher l'état initial
                        print('🚀 Lancement du tournoi');
                        print('👤 Équipe utilisateur: ${selectedTeam?.name}');
                        print('🤖 Premier adversaire: ${tournamentState.currentOpponent?.name}');
                        tournamentState.printTournamentStatus();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameScreen(gameState: gameState),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'COMMENCER LE TOURNOI',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
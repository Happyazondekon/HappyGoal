// tournament_mode_screen.dart
import 'package:flutter/material.dart';
import 'package:happygoal/screens/game_screen.dart';
import '../models/team.dart';
import '../models/game_state.dart';
import 'mode_selection_screen.dart';
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
                fit: BoxFit.fill,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Bouton retour en haut à gauche
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        child: IconButton(
                          onPressed: () {
                            // Remplacer le simple pop par un pushReplacement vers le SelectionScreen
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ModeSelectionScreen(), // Écran de sélection de mode
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                // Contenu principal avec scroll
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          // Header avec icône trophée
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: const Text(
                                  'TOURNOI HAPPY',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(2.0, 2.0),
                                        blurRadius: 4.0,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          // Description du tournoi
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Parcours vers la gloire',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                _buildTournamentPhase('🥅', 'HUITIÈMES', 'DE FINALE', Colors.blue),
                                const SizedBox(height: 8),
                                _buildTournamentPhase('⚽', 'QUARTS', 'DE FINALE', Colors.green),
                                const SizedBox(height: 8),
                                _buildTournamentPhase('🏆', 'DEMI-', 'FINALES', Colors.orange),
                                const SizedBox(height: 8),
                                _buildTournamentPhase('👑', 'GRANDE', 'FINALE', Colors.amber),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Affichage de l'équipe sélectionnée
                          if (selectedTeam != null)
                            Container(
                              padding: const EdgeInsets.all(15),
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.white, Colors.grey[100]!],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.sports_soccer,
                                        color: selectedTeam!.color,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: Text(
                                          'VOTRE ÉQUIPE',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: selectedTeam!.color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: selectedTeam!.color.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.1),
                                                blurRadius: 5,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.asset(
                                              selectedTeam!.flagImage,
                                              height: 50,
                                              width: 75,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                selectedTeam!.name,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: selectedTeam!.color,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 5),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: selectedTeam!.color,
                                                  borderRadius: BorderRadius.circular(15),
                                                ),
                                                child: const Text(
                                                  'PRÊT AU COMBAT',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 20),

                          // Bouton de sélection d'équipe
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            child: ElevatedButton(
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
                                backgroundColor: selectedTeam == null ? AppColors.primary : Colors.orange,
                                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    selectedTeam == null ? Icons.add_circle_outline : Icons.swap_horiz,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      selectedTeam == null ? 'CHOISIR VOTRE ÉQUIPE' : 'CHANGER D\'ÉQUIPE',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Bouton de démarrage du tournoi
                          if (selectedTeam != null)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.amber.withOpacity(0.5)),
                                    ),
                                    child: const Text(
                                      '⚡ 4 MATCHES POUR LA VICTOIRE ⚡',
                                      style: TextStyle(
                                        color: Colors.amber,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  ElevatedButton(
                                    onPressed: () => _startTournament(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 10,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                          size: 26,
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: const Text(
                                            'LANCER LE TOURNOI',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
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

  Widget _buildTournamentPhase(String emoji, String phase1, String phase2, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: phase1,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' $phase2',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startTournament() {
    // Obtenir toutes les équipes disponibles
    List<Team> allTeams = Team.getPredefinedTeams();

    // S'assurer qu'on a assez d'équipes pour un tournoi (minimum 16 pour les huitièmes)
    if (allTeams.length < 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pas assez d\'équipes pour un tournoi complet (16 équipes requises)'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Créer l'état du tournoi
    final tournamentState = TournamentState(
      allTeams: allTeams,
      userTeam: selectedTeam,
    );

    // Démarrer le tournoi (phase huitièmes de finale)
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
    print('🏆 Lancement du tournoi - Phase: ${tournamentState.currentPhase}');
    print('👤 Équipe utilisateur: ${selectedTeam?.name}');
    print('🤖 Premier adversaire: ${tournamentState.currentOpponent?.name}');
    tournamentState.printTournamentStatus();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(gameState: gameState),
      ),
    );
  }
}
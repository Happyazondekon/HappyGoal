import 'package:flutter/material.dart';
import '../constants.dart';
import 'team_selection_screen.dart';
import '../utils/audio_manager.dart';

class DifficultyLevel {
  final String name;
  final String description;
  final double intelligence;
  final Color color;
  final IconData icon;

  const DifficultyLevel({
    required this.name,
    required this.description,
    required this.intelligence,
    required this.color,
    required this.icon,
  });
}

class DifficultySelectionScreen extends StatelessWidget {
  const DifficultySelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Définition des niveaux de difficulté
    final List<DifficultyLevel> difficulties = [
      DifficultyLevel(
        name: 'FACILE',
        description: 'L\'IA joue de façon prévisible',
        intelligence: 0.3,
        color: Colors.green,
        icon: Icons.sentiment_very_satisfied,
      ),
      DifficultyLevel(
        name: 'NORMAL',
        description: 'Une IA équilibrée',
        intelligence: 0.6,
        color: AppColors.primary,
        icon: Icons.sentiment_satisfied,
      ),
      DifficultyLevel(
        name: 'DIFFICILE',
        description: 'L\'IA fait des choix intelligents',
        intelligence: 0.8,
        color: Colors.orange,
        icon: Icons.sentiment_dissatisfied,
      ),
      DifficultyLevel(
        name: 'EXPERT',
        description: 'L\'IA joue comme un pro',
        intelligence: 0.95,
        color: Colors.red,
        icon: Icons.sentiment_very_dissatisfied,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Arrière-plan
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/stadium_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ColorFilter.mode(
                Colors.white,
                BlendMode.darken,
              ),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          // Contenu principal
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Choisir la difficulté',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              offset: Offset(3.0, 3.0),
                              blurRadius: 6.0,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Comment voulez-vous que l\'IA joue contre vous ?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          shadows: [
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 3.0,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      // Liste des difficultés
                      ...difficulties.map((difficulty) => _buildDifficultyButton(
                        context,
                        difficulty: difficulty,
                      )),

                      const SizedBox(height: 30),

                      // Bouton Retour
                      TextButton.icon(
                        onPressed: () {
                          AudioManager.playSound('click');
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        label: const Text(
                          'Retour',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyButton(
      BuildContext context, {
        required DifficultyLevel difficulty,
      }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth > 400 ? screenWidth * 0.8 : screenWidth - 32;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SizedBox(
        width: buttonWidth,
        height: 85,
        child: ElevatedButton(
          onPressed: () {
            AudioManager.playSound('click');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeamSelectionScreen(
                  isSoloMode: true,
                  aiIntelligence: difficulty.intelligence,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: difficulty.color,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            shadowColor: difficulty.color.withOpacity(0.5),
          ),
          child: Row(
            children: [
              Icon(difficulty.icon, size: 35, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      difficulty.name,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      difficulty.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:happygoal/screens/tournament_mode_screen.dart';
import '../constants.dart';
import 'home_screen.dart';
import 'team_selection_screen.dart';
import 'difficulty_selection_screen.dart';
import '../utils/audio_manager.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              child: SingleChildScrollView(  // Ajout du SingleChildScrollView
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Choisir un mode',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,  // Taille réduite
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
                        textAlign: TextAlign.center,  // Pour centrer si le texte est sur plusieurs lignes
                      ),
                      const SizedBox(height: 30),  // Espace réduit

                      // Mode Solo
                      _buildModeButton(
                        context,
                        title: 'MODE SOLO',
                        subtitle: 'Jouez contre l\'ordinateur',
                        icon: Icons.person,
                        onPressed: () {
                          AudioManager.playSound('click');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DifficultySelectionScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),  // Espace réduit

                      // Mode Multijoueur
                      _buildModeButton(
                        context,
                        title: 'MODE MULTIJOUEUR',
                        subtitle: 'Jouez à deux',
                        icon: Icons.people,
                        onPressed: () {
                          AudioManager.playSound('click');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TeamSelectionScreen(isSoloMode: false),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildModeButton(
                        context,
                        title: 'MODE TOURNOI',
                        subtitle: 'Tentez de gagner le Tournoi Happy',
                        icon: Icons.emoji_events,
                        onPressed: () {
                          AudioManager.playSound('click');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TournamentModeScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 30),  // Espace réduit

                      TextButton.icon(
                        onPressed: () {
                          AudioManager.playSound('click');
                          // Remplacer Navigator.pop par pushAndRemoveUntil pour retourner à l'accueil
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                                (route) => false, // Supprimer toutes les routes précédentes
                          );
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

  Widget _buildModeButton(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required VoidCallback onPressed,
      }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth > 400 ? screenWidth * 0.8 : screenWidth - 32;  // Responsive width

    return SizedBox(
      width: buttonWidth,
      height: 100,  // Hauteur réduite
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),  // Padding réduit
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          shadowColor: AppColors.primary.withOpacity(0.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.white),  // Icône plus petite
            const SizedBox(width: 12),  // Espace réduit
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,  // Taille réduite
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                    overflow: TextOverflow.ellipsis,  // Empêche le débordement du texte
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,  // Taille réduite
                      color: Colors.white.withOpacity(0.9),
                    ),
                    overflow: TextOverflow.ellipsis,  // Empêche le débordement du texte
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),  // Icône plus petite
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../constants.dart';
import 'home_screen.dart';
import 'team_selection_screen.dart';
import '../utils/audio_manager.dart';
import 'mode_selection_screen.dart';

class DifficultyLevel {
  final String name;
  final String description;
  final double intelligence;
  final Color color;
  final IconData icon;
  final LinearGradient gradient;

  const DifficultyLevel({
    required this.name,
    required this.description,
    required this.intelligence,
    required this.color,
    required this.icon,
    required this.gradient,
  });
}

class DifficultySelectionScreen extends StatefulWidget {
  const DifficultySelectionScreen({Key? key}) : super(key: key);

  @override
  _DifficultySelectionScreenState createState() => _DifficultySelectionScreenState();
}

class _DifficultySelectionScreenState extends State<DifficultySelectionScreen> {
  final List<DifficultyLevel> difficulties = [
    DifficultyLevel(
      name: 'FACILE',
      description: 'IA prévisible, idéal pour débuter',
      intelligence: 0.3,
      color: Colors.green,
      icon: Icons.sentiment_very_satisfied,
      gradient: const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
      ),
    ),
    DifficultyLevel(
      name: 'NORMAL',
      description: 'IA équilibrée, pour un défi modéré',
      intelligence: 0.6,
      color: Colors.amber,
      icon: Icons.sentiment_satisfied,
      gradient: const LinearGradient(
        colors: [Color(0xFFFFC107), Color(0xFFFF8F00)],
      ),
    ),
    DifficultyLevel(
      name: 'DIFFICILE',
      description: 'IA intelligente, pour les experts',
      intelligence: 0.85,
      color: Colors.orange,
      icon: Icons.sentiment_dissatisfied,
      gradient: const LinearGradient(
        colors: [Color(0xFFFF9800), Color(0xFFE65100)],
      ),
    ),
    DifficultyLevel(
      name: 'EXPERT',
      description: 'IA professionnelle, très difficile',
      intelligence: 0.98,
      color: Colors.red,
      icon: Icons.sentiment_very_dissatisfied,
      gradient: const LinearGradient(
        colors: [Color(0xFFF44336), Color(0xFFB71C1C)],
      ),
    ),
    DifficultyLevel(
      name: 'LÉGENDAIRE',
      description: 'Presque impossible à battre',
      intelligence: 0.995,
      color: Colors.deepPurple,
      icon: Icons.local_fire_department,
      gradient: const LinearGradient(
        colors: [Color(0xFF673AB7), Color(0xFF311B92)],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Arrière-plan dégradé moderne
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D4A2D),  // Vert foncé
                  Color(0xFF1B6B3A),  // Vert moyen
                  Color(0xFF2E8B4B),  // Vert clair
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Particules flottantes
          ...List.generate(12, (index) {
            return Positioned(
              left: (index * 35.0) % screenWidth,
              top: (index * 50.0) % screenHeight,
              child: FloatingParticle(
                size: 2.0 + (index % 3),
                color: Colors.white.withOpacity(0.1 + (index % 3) * 0.1),
                duration: Duration(seconds: 4 + (index % 3)),
              ),
            );
          }),

          // Lignes de terrain stylisées
          CustomPaint(
            size: Size(screenWidth, screenHeight),
            painter: FieldLinesPainter(),
          ),

          // Contenu principal
          SafeArea(
            child: Column(
              children: [
                // Header moderne
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animation du titre
                        TweenAnimationBuilder(
                          duration: const Duration(milliseconds: 800),
                          tween: Tween<double>(begin: 0, end: 1),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 30 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Color(0xFFE0E0E0),
                                      Colors.white,
                                    ],
                                  ).createShader(bounds),
                                  child: const Text(
                                    'Choisir la difficulté',
                                    style: TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 2,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(0, 0),
                                          blurRadius: 20,
                                          color: Colors.white,
                                        ),
                                        Shadow(
                                          offset: Offset(0, 5),
                                          blurRadius: 15,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // Sous-titre moderne
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Quel est votre niveau ?',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Section des difficultés
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ListView.builder(
                      itemCount: difficulties.length,
                      itemBuilder: (context, index) {
                        return TweenAnimationBuilder(
                          duration: Duration(milliseconds: 600 + (index * 150)),
                          tween: Tween<double>(begin: 0, end: 1),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(50 * (1 - value), 0),
                              child: Opacity(
                                opacity: value,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: _buildModernDifficultyCard(
                                    context,
                                    difficulties[index],
                                    index,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                // Bouton retour moderne
                Expanded(
                  flex: 1,
                  child: Center(
                    child: TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 1200),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  AudioManager.playSound('click');
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.15),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    side: BorderSide(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  elevation: 0,
                                ),
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                label: const Text(
                                  'Retour',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDifficultyCard(
      BuildContext context,
      DifficultyLevel difficulty,
      int index,
      ) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () {
            AudioManager.playSound('click');
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    TeamSelectionScreen(
                      isSoloMode: true,
                      aiIntelligence: difficulty.intelligence,
                    ),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: const Offset(0.0, 0.0),
                    ).animate(animation),
                    child: child,
                  );
                },
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: difficulty.gradient,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  // Icône avec effet de lueur
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Icon(
                      difficulty.icon,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Textes et barre de progression
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          difficulty.name,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          difficulty.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Barre de progression de l'intelligence
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: Colors.white.withOpacity(0.3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: difficulty.intelligence,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.5),
                                    blurRadius: 4,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Flèche avec animation
                  TweenAnimationBuilder(
                    duration: const Duration(seconds: 2),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(5 * value, 0),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
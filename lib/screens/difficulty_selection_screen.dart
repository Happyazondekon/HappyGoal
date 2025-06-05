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

class DifficultySelectionScreen extends StatefulWidget {
  const DifficultySelectionScreen({Key? key}) : super(key: key);

  @override
  _DifficultySelectionScreenState createState() => _DifficultySelectionScreenState();
}

class _DifficultySelectionScreenState extends State<DifficultySelectionScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.6);
  int _currentPage = 0;
  double _angle = 0.0;

  final List<DifficultyLevel> difficulties = [
    DifficultyLevel(
      name: 'FACILE',
      description: 'IA prévisible',
      intelligence: 0.3,
      color: Colors.green,
      icon: Icons.sentiment_very_satisfied,
    ),
    DifficultyLevel(
      name: 'NORMAL',
      description: 'IA équilibrée',
      intelligence: 0.6,
      color: Colors.yellow,
      icon: Icons.sentiment_satisfied,
    ),
    DifficultyLevel(
      name: 'DIFFICILE',
      description: 'IA intelligente',
      intelligence: 0.85,
      color: Colors.orange,
      icon: Icons.sentiment_dissatisfied,
    ),
    DifficultyLevel(
      name: 'EXPERT',
      description: 'IA professionnelle',
      intelligence: 0.98,
      color: Colors.red,
      icon: Icons.sentiment_very_dissatisfied,
    ),
    DifficultyLevel(
      name: 'LÉGENDAIRE',
      description: 'Presque impossible',
      intelligence: 0.995,
      color: Colors.deepPurple,
      icon: Icons.local_fire_department,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _angle = _pageController.page! * (2 * 3.14159 / difficulties.length);
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
                fit: BoxFit.fill,
              ),
            ),
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),

          // Contenu principal
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Choisir la difficulté',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
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
                  'Tournez pour sélectionner',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    shadows: [
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 2.0,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Carousel circulaire
                Expanded(
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      _pageController.jumpTo(_pageController.offset - details.delta.dy);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Effet de cercle de fond


                        // Éléments du carousel
                        SizedBox(
                          height: 400,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: difficulties.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                              AudioManager.playSound('click');
                            },
                            itemBuilder: (context, index) {
                              final diff = difficulties[index];
                              final angle = index * (2 * 3.14159 / difficulties.length) - _angle;
                              final distance = (1 - (angle.abs() / 3.14159)).clamp(0.3, 1.0);

                              return GestureDetector(
                                onTap: () {
                                  AudioManager.playSound('click');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TeamSelectionScreen(
                                        isSoloMode: true,
                                        aiIntelligence: difficulties[index].intelligence,
                                      ),
                                    ),
                                  );
                                },
                                child: Transform.translate(
                                  offset: Offset(0, -100 * distance),
                                  child: Transform.scale(
                                    scale: 0.5 + 0.5 * distance,
                                    child: Opacity(
                                      opacity: distance,
                                      child: _buildDifficultyCard(diff),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Indicateur de sélection
                        Positioned(
                          bottom: 120,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: difficulties[_currentPage].color.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              difficulties[_currentPage].name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bouton Retour
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: TextButton(
                    onPressed: () {
                      AudioManager.playSound('click');
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Retour',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        decoration: TextDecoration.underline,
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

  Widget _buildDifficultyCard(DifficultyLevel difficulty) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Card(
        color: difficulty.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(difficulty.icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                difficulty.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                difficulty.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
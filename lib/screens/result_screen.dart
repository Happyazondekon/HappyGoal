import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../constants.dart';
import '../models/team.dart';
import 'home_screen.dart';

class ResultScreen extends StatefulWidget {
  final Team winner;
  final Team loser;
  final List<bool> winnerResults;
  final List<bool> loserResults;
  final bool isSoloMode; // Nouveau paramètre pour indiquer le mode de jeu
  final bool isUserWinner; // Nouveau paramètre pour indiquer si l'utilisateur a gagné

  const ResultScreen({
    Key? key,
    required this.winner,
    required this.loser,
    required this.winnerResults,
    required this.loserResults,
    this.isSoloMode = false, // Par défaut, on considère que ce n'est pas le mode solo
    this.isUserWinner = true, // Par défaut, on considère que l'utilisateur a gagné
  }) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  // Maximum number of shots to display
  final int _maxShotsToDisplay = 5;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();

    // Ne joue les confettis que si l'utilisateur a gagné en mode solo ou en mode multijoueur
    if (!widget.isSoloMode || widget.isUserWinner) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Method to get the last N shots from a results list
  List<bool> _getLastShots(List<bool> results) {
    if (results.length <= _maxShotsToDisplay) {
      return results;
    }
    return results.sublist(results.length - _maxShotsToDisplay);
  }

  @override
  Widget build(BuildContext context) {
    // Déterminer si on est dans un cas de défaite en mode solo
    final bool isDefeat = widget.isSoloMode && !widget.isUserWinner;

    // Couleur de fond en fonction du résultat
    final Color backgroundColor = isDefeat
        ? Colors.grey[800]! // Couleur sombre pour la défaite
        : widget.winner.color;

    // Titre à afficher en fonction du résultat
    final String resultTitle = isDefeat ? 'DÉFAITE...' : 'VICTOIRE!';

    return Scaffold(
      body: Stack(
        children: [
          // Arrière-plan avec dégradé animé
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  backgroundColor.withOpacity(0.8),
                  AppColors.background.withOpacity(0.9),
                ],
                stops: const [0.1, 1.0],
              ),
            ),
          ),

          // Effets de particules
          Positioned.fill(
            child: CustomPaint(
              painter: _ParticlePainter(),
            ),
          ),

          // Contenu principal
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Titre "VICTOIRE" ou "DÉFAITE" avec animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: Text(
                        resultTitle,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2.0,
                          shadows: [
                            Shadow(
                              offset: Offset(3.0, 3.0),
                              blurRadius: 6.0,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Drapeau de l'équipe gagnante avec effet de brillance
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 220,
                        height: 140,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: widget.winner.color.withOpacity(0.6),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      Image.asset(
                        widget.winner.flagImage,
                        width: 200,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Nom de l'équipe gagnante
                  Text(
                    widget.winner.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      shadows: [
                        const Shadow(
                          offset: Offset(2.0, 2.0),
                          blurRadius: 4.0,
                          color: Colors.black54,
                        ),
                      ],
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 1
                        ..color = widget.winner.color.withOpacity(0.8),
                    ),
                  ),

                  // Message spécial pour la défaite en mode solo
                  if (isDefeat)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Text(
                        "L'IA a remporté cette séance de tirs au but !",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),

                  // Carte des scores
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Score
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildTeamCard(widget.winner, true),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.redAccent.withOpacity(0.8),
                                          Colors.orange.withOpacity(0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.redAccent.withOpacity(0.4),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '${widget.winner.score} - ${widget.loser.score}',
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                _buildTeamCard(widget.loser, false),
                              ],
                            ),

                            const SizedBox(height: 30),

                            // Statistiques des tirs
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildShotStats(widget.winner, widget.winnerResults),
                                _buildShotStats(widget.loser, widget.loserResults),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Message d'encouragement en cas de défaite
                  if (isDefeat)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        "Ne vous découragez pas, réessayez !",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  // Bouton de retour
                  AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(seconds: 1),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                              (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                        shadowColor: widget.winner.color.withOpacity(0.5),
                      ),
                      child: Text(
                        isDefeat ? 'REVANCHE' : 'RETOUR AU MENU',
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confettis - uniquement pour les victoires
          if (!isDefeat)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.05,
                numberOfParticles: 30,
                maxBlastForce: 30,
                minBlastForce: 15,
                gravity: 0.1,
                colors: const [
                  Colors.red,
                  Colors.green,
                  Colors.blue,
                  Colors.yellow,
                  Colors.purple,
                  Colors.orange,
                  Colors.white,
                ],
                shouldLoop: true,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(Team team, bool isWinner) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: isWinner ? team.color.withOpacity(0.6) : Colors.grey.withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
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
            fontSize: 14,
            color: Colors.white,
            fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
            shadows: [
              const Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 2.0,
                color: Colors.black45,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShotStats(Team team, List<bool> results) {
    final goals = results.where((r) => r).length;
    final total = results.length;
    final displayResults = _getLastShots(results);
    final hasMoreShots = results.length > _maxShotsToDisplay;

    return Column(
      children: [
        Text(
          'TIRS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: team.color,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '$goals / $total',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: [
            if (hasMoreShots)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  '(Derniers $_maxShotsToDisplay tirs)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: displayResults.map((isGoal) => _buildShotIndicator(isGoal)).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShotIndicator(bool isGoal) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isGoal ? Colors.green : Colors.red,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 3,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          isGoal ? Icons.check : Icons.close,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final random = Random(DateTime.now().millisecond);

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 3 + 1;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
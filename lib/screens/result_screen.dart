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
  final bool isSoloMode;
  final bool isUserWinner;

  const ResultScreen({
    Key? key,
    required this.winner,
    required this.loser,
    required this.winnerResults,
    required this.loserResults,
    this.isSoloMode = false,
    this.isUserWinner = true,
  }) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
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

  List<bool> _getLastShots(List<bool> results) {
    if (results.length <= _maxShotsToDisplay) return results;
    return results.sublist(results.length - _maxShotsToDisplay);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDefeat = widget.isSoloMode && !widget.isUserWinner;
    final Color primaryColor = isDefeat ? Colors.grey[800]! : widget.winner.color;
    final String resultTitle = isDefeat ? 'DÉFAITE' : 'VICTOIRE';

    return Scaffold(
      body: Stack(
        children: [
          // Arrière-plan dégradé moderne
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withOpacity(0.9),
                  primaryColor.withOpacity(0.7),
                  AppColors.background.withOpacity(0.9),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Particules flottantes
          ...List.generate(12, (index) {
            return Positioned(
              left: (index * 35.0) % MediaQuery.of(context).size.width,
              top: (index * 50.0) % MediaQuery.of(context).size.height,
              child: FloatingParticle(
                size: 2.0 + (index % 3),
                color: Colors.white.withOpacity(0.1 + (index % 3) * 0.1),
                duration: Duration(seconds: 4 + (index % 3)),
              ),
            );
          }),

          // Contenu principal
          SafeArea(
            child: Column(
              children: [
                // Header avec titre
                Expanded(
                  flex: 2,
                  child: Center(
                    child: TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  Colors.white,
                                  Color(0xFFE0E0E0),
                                  Colors.white,
                                ],
                              ).createShader(bounds),
                              child: Text(
                                resultTitle,
                                style: TextStyle(
                                  fontSize: 48,
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
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Contenu central
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Drapeau de l'équipe gagnante
                        TweenAnimationBuilder(
                          duration: Duration(milliseconds: 600),
                          tween: Tween<double>(begin: 0, end: 1),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(50 * (1 - value), 0),
                              child: Opacity(
                                opacity: value,
                                child: Stack(
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
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // Nom de l'équipe gagnante
                        Text(
                          widget.winner.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 1
                              ..color = widget.winner.color.withOpacity(0.8),
                            shadows: [
                              Shadow(
                                offset: Offset(2.0, 2.0),
                                blurRadius: 4.0,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),

                        // Message spécial pour la défaite
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
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(25),
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
                      ],
                    ),
                  ),
                ),

                // Boutons
                Expanded(
                  flex: 1,
                  child: Center(
                    child: TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 1000),
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
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                                        (route) => false,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.15),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    side: BorderSide(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  isDefeat ? 'REVANCHE' : 'RETOUR AU MENU',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
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

          // Confettis
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
                shouldLoop: false,
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

class FloatingParticle extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const FloatingParticle({
    Key? key,
    required this.size,
    required this.color,
    required this.duration,
  }) : super(key: key);

  @override
  _FloatingParticleState createState() => _FloatingParticleState();
}

class _FloatingParticleState extends State<FloatingParticle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
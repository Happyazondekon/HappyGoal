import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../constants.dart';
import '../models/team.dart';
import 'mode_selection_screen.dart';
import 'team_selection_screen.dart';

class ResultScreen extends StatefulWidget {
  final Team winner;
  final Team loser;
  final List<bool> winnerResults;
  final List<bool> loserResults;
  final bool isSoloMode;
  final bool isUserWinner;
  final bool isTournamentMode;
  final double? aiIntelligence;

  const ResultScreen({
    Key? key,
    required this.winner,
    required this.loser,
    required this.winnerResults,
    required this.loserResults,
    this.isSoloMode = false,
    this.isUserWinner = true,
    this.isTournamentMode = false,
    this.aiIntelligence,
  }) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _buttonController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _buttonAnimation;

  final int _maxShotsToDisplay = 5;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));

    // Animations
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.bounceOut,
    ));

    _buttonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeOutBack,
    ));

    // Start animations
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _scaleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      _buttonController.forward();
    });

    // Start confetti for victory
    if (!widget.isSoloMode || widget.isUserWinner) {
      Future.delayed(const Duration(milliseconds: 600), () {
        _confettiController.play();
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  List<bool> _getLastShots(List<bool> results) {
    if (results.length <= _maxShotsToDisplay) return results;
    return results.sublist(results.length - _maxShotsToDisplay);
  }

  void _navigateToModeSelection() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const ModeSelectionScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
      ),
          (route) => false,
    );
  }

  void _navigateToTeamSelection() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => TeamSelectionScreen(
          isSoloMode: widget.isSoloMode,
          isTournamentMode: widget.isTournamentMode,
          aiIntelligence: widget.aiIntelligence,
        ),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final bool isDefeat = widget.isSoloMode && !widget.isUserWinner;
    final Color primaryColor = isDefeat ? const Color(0xFF424242) : widget.winner.color;
    final String resultTitle = isDefeat ? 'DÉFAITE' : 'VICTOIRE';

    // Gradient colors based on result
    final List<Color> gradientColors = isDefeat
        ? [
      const Color(0xFF212121),
      const Color(0xFF424242),
      const Color(0xFF616161),
    ]
        : [
      primaryColor.withOpacity(0.9),
      primaryColor.withOpacity(0.7),
      primaryColor.withOpacity(0.5),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedContainer(
            duration: const Duration(milliseconds: 1000),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5,
                colors: gradientColors,
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),

          // Animated floating particles
          ...List.generate(15, (index) {
            return Positioned(
              left: (index * 40.0) % MediaQuery.of(context).size.width,
              top: (index * 60.0) % MediaQuery.of(context).size.height,
              child: FloatingParticle(
                size: 3.0 + (index % 4),
                color: Colors.white.withOpacity(0.05 + (index % 4) * 0.05),
                duration: Duration(seconds: 3 + (index % 4)),
              ),
            );
          }),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              // Ajout de Center pour centrer le contenu verticalement si l'Ã©cran est grand
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600), // Limite la largeur pour les grands Ã©crans
                  child: Column(
                    children: [
                      // Animated title section
                      SlideTransition(
                        position: _slideAnimation,
                        child: Center(
                          child: Padding(
                            // RÃ©duction des padding pour moins de marge
                            padding: const EdgeInsets.only(top: 20, bottom: 15),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Glow effect behind title
                                Container(
                                  // RÃ©duction des padding
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDefeat
                                            ? Colors.grey.withOpacity(0.3)
                                            : primaryColor.withOpacity(0.4),
                                        blurRadius: 20, // RÃ©duction du flou
                                        spreadRadius: 10, // RÃ©duction de l'Ã©talement
                                      ),
                                    ],
                                  ),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: isDefeat
                                          ? [Colors.grey.shade300, Colors.white, Colors.grey.shade300]
                                          : [Colors.white, primaryColor.withOpacity(0.8), Colors.white],
                                      stops: const [0.0, 0.5, 1.0],
                                    ).createShader(bounds),
                                    child: Text(
                                      resultTitle,
                                      style: const TextStyle(
                                        fontSize: 42, // Taille du titre rÃ©duite
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 3,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10), // Espace rÃ©duit

                                // Subtitle with context
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Padding rÃ©duit
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20), // Rayon rÃ©duit
                                    color: Colors.black.withOpacity(0.2),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    isDefeat
                                        ? "L'IA a remporté cette séance"
                                        : "Félicitations pour cette victoire !",
                                    style: TextStyle(
                                      fontSize: 14, // Taille du texte rÃ©duite
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Team and score section
                      Padding(
                        // RÃ©duction du padding
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Winner flag with enhanced glow
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.6),
                                      blurRadius: 25, // RÃ©duction du flou
                                      spreadRadius: 10, // RÃ©duction de l'Ã©talement
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 15, // RÃ©duction du flou
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    widget.winner.flagImage,
                                    width: 180, // Taille de l'image rÃ©duite
                                    height: 120, // Taille de l'image rÃ©duite
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 15), // Espace rÃ©duit

                              // Winner name with style
                              Container(
                                // Padding rÃ©duit
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.3),
                                      Colors.black.withOpacity(0.1),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  widget.winner.name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 24, // Taille du texte rÃ©duite
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(2, 2),
                                        blurRadius: 6,
                                        color: Colors.black.withOpacity(0.7),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              const SizedBox(height: 20), // Espace rÃ©duit

                              // Enhanced score card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(15), // Padding rÃ©duit
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20), // Rayon rÃ©duit
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.black.withOpacity(0.3),
                                      Colors.black.withOpacity(0.1),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 15, // RÃ©duction du flou
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    // Main score display
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _buildEnhancedTeamCard(widget.winner, true),

                                        // Score display with glow
                                        Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 10), // Marge rÃ©duite
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Padding rÃ©duit
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15), // Rayon rÃ©duit
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFFF6B35).withOpacity(0.5),
                                                blurRadius: 10, // RÃ©duction du flou
                                                spreadRadius: 3, // RÃ©duction de l'Ã©talement
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            '${widget.winner.score} - ${widget.loser.score}',
                                            style: const TextStyle(
                                              fontSize: 32, // Taille du texte rÃ©duite
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                              shadows: [
                                                Shadow(
                                                  offset: Offset(2, 2),
                                                  blurRadius: 4,
                                                  color: Colors.black54,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        _buildEnhancedTeamCard(widget.loser, false),
                                      ],
                                    ),

                                    const SizedBox(height: 15), // Espace rÃ©duit

                                    // Shot statistics
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildEnhancedShotStats(widget.winner, widget.winnerResults),
                                        _buildEnhancedShotStats(widget.loser, widget.loserResults),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Enhanced button section
                      AnimatedBuilder(
                        animation: _buttonController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _buttonAnimation.value,
                            child: Padding(
                              // Padding rÃ©duit
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isDefeat) ...[
                                    // Defeat buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildActionButton(
                                            text: 'REVANCHE',
                                            icon: Icons.refresh,
                                            color: const Color(0xFF4CAF50),
                                            onPressed: _navigateToTeamSelection,
                                          ),
                                        ),
                                        const SizedBox(width: 10), // Espace rÃ©duit
                                        Expanded(
                                          child: _buildActionButton(
                                            text: 'RETOUR AU MENU',
                                            icon: Icons.home,
                                            color: const Color(0xFF757575),
                                            onPressed: _navigateToModeSelection,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ] else ...[
                                    // Victory buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildActionButton(
                                            text: 'CHANGER ÉQUIPE',
                                            icon: Icons.swap_horiz,
                                            color: primaryColor,
                                            onPressed: _navigateToTeamSelection,
                                          ),
                                        ),
                                        const SizedBox(width: 10), // Espace rÃ©duit
                                        Expanded(
                                          child: _buildActionButton(
                                            text: 'RETOUR AU MENU',
                                            icon: Icons.home,
                                            color: const Color(0xFF757575),
                                            onPressed: _navigateToModeSelection,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
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

          // Confetti for victory
          if (!isDefeat)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.03,
                numberOfParticles: 40,
                maxBlastForce: 40,
                minBlastForce: 20,
                gravity: 0.08,
                colors: const [
                  Colors.red,
                  Colors.green,
                  Colors.blue,
                  Colors.yellow,
                  Colors.purple,
                  Colors.orange,
                  Colors.white,
                  Colors.pink,
                ],
                shouldLoop: false,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 50, // Hauteur du bouton rÃ©duite
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25), // Rayon rÃ©duit
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10, // RÃ©duction du flou
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25), // Rayon rÃ©duit
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12), // Padding rÃ©duit
        ),
        icon: Icon(icon, size: 20), // Taille de l'icÃ´ne rÃ©duite
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 10, // Taille du texte rÃ©duite
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedTeamCard(Team team, bool isWinner) {
    return Flexible(
      child: Column(
        children: [
          Container(
            width: 70, // Taille rÃ©duite
            height: 50, // Taille rÃ©duite
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), // Rayon rÃ©duit
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: isWinner
                      ? team.color.withOpacity(0.6)
                      : Colors.grey.withOpacity(0.4),
                  blurRadius: 10, // RÃ©duction du flou
                  spreadRadius: 2, // RÃ©duction de l'Ã©talement
                ),
                const BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6, // RÃ©duction du flou
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10), // Rayon rÃ©duit
              child: Image.asset(
                team.flagImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8), // Espace rÃ©duit
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // Padding rÃ©duit
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), // Rayon rÃ©duit
              color: Colors.black.withOpacity(0.2),
            ),
            child: Text(
              team.name,
              style: TextStyle(
                fontSize: 12, // Taille du texte rÃ©duite
                color: Colors.white,
                fontWeight: isWinner ? FontWeight.bold : FontWeight.w500,
                shadows: const [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 2,
                    color: Colors.black45,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedShotStats(Team team, List<bool> results) {
    final goals = results.where((r) => r).length;
    final total = results.length;
    final displayResults = _getLastShots(results);
    final hasMoreShots = results.length > _maxShotsToDisplay;

    return Flexible(
      child: Container(
        padding: const EdgeInsets.all(10), // Padding rÃ©duit
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.black.withOpacity(0.2),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              'TIRS AU BUT',
              style: TextStyle(
                fontSize: 12, // Taille du texte rÃ©duite
                fontWeight: FontWeight.bold,
                color: team.color,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6), // Espace rÃ©duit
            Text(
              '$goals / $total',
              style: const TextStyle(
                fontSize: 18, // Taille du texte rÃ©duite
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 2,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10), // Espace rÃ©duit
            if (hasMoreShots)
              Padding(
                padding: const EdgeInsets.only(bottom: 6), // Padding rÃ©duit
                child: Text(
                  '(Derniers $_maxShotsToDisplay tirs)',
                  style: TextStyle(
                    fontSize: 10, // Taille du texte rÃ©duite
                    color: Colors.white.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            Wrap(
              spacing: 4, // Espace rÃ©duit
              runSpacing: 4, // Espace rÃ©duit
              alignment: WrapAlignment.center,
              children: displayResults.map((isGoal) => _buildEnhancedShotIndicator(isGoal)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedShotIndicator(bool isGoal) {
    return Container(
      width: 22, // Taille rÃ©duite
      height: 22, // Taille rÃ©duite
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGoal
              ? [const Color(0xFF4CAF50), const Color(0xFF2E7D32)]
              : [const Color(0xFFE53935), const Color(0xFFC62828)],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5), // Ã‰paisseur rÃ©duite
        boxShadow: [
          BoxShadow(
            color: (isGoal ? Colors.green : Colors.red).withOpacity(0.4),
            blurRadius: 4, // RÃ©duction du flou
            spreadRadius: 1, // RÃ©duction de l'Ã©talement
          ),
        ],
      ),
      child: Center(
        child: Icon(
          isGoal ? Icons.check : Icons.close,
          color: Colors.white,
          size: 14, // Taille de l'icÃ´ne rÃ©duite
          shadows: const [
            Shadow(
              offset: Offset(1, 1),
              blurRadius: 2,
              color: Colors.black54,
            ),
          ],
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

class _FloatingParticleState extends State<FloatingParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -15, end: 15).animate(
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
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.5),
                  blurRadius: widget.size,
                  spreadRadius: widget.size / 4,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
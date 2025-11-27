// result_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../constants.dart';
import '../models/team.dart';
import 'mode_selection_screen.dart';
import 'team_selection_screen.dart';
import '../utils/ad_controller.dart';
import '../services/achievement_service.dart'; // ⭐ Import Service
import '../models/achievement.dart'; // ⭐ Import Modèle

class ResultScreen extends StatefulWidget {
  final Team winner;
  final Team loser;
  final List<bool> winnerResults;
  final List<bool> loserResults;
  final bool isSoloMode;
  final bool isUserWinner;
  final bool isTournamentMode;
  final double? aiIntelligence;

  // Nouveaux paramètres pour les stats détaillées (optionnels)
  // Si vous ne les passez pas depuis GameController, ils seront 0
  final int goalsCurve;
  final int goalsLob;
  final int goalsKnuckle;

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
    this.goalsCurve = 0,
    this.goalsLob = 0,
    this.goalsKnuckle = 0,
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
  bool _coinsAwarded = false;
  bool _achievementsRecorded = false; // ⭐ Pour éviter les doublons

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

    // 🎁 GESTION DES RÉCOMPENSES (Coins + Achievements)
    // On enregistre les stats même en cas de défaite (pour les séries brisées etc)
    if (!_achievementsRecorded && widget.isSoloMode) {
      _processMatchResult();
    }
  }

  void _processMatchResult() async {
    // 1. Si le joueur gagne
    if (widget.isUserWinner) {
      if (!_coinsAwarded) {
        _awardVictoryCoins();
      }
      _recordWinAchievements();
    }
    // 2. Si le joueur perd (IMPORTANT: pour casser les séries de victoires)
    else {
      _recordLossStats();
    }
    _achievementsRecorded = true;
  }

  // 🎁 Donner les coins
  void _awardVictoryCoins() async {
    await AdController.instance.addCoins(1);
    _coinsAwarded = true;

    // Petit délai pour ne pas spammer les snackbars si un achievement pop aussi
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.monetization_on, color: Colors.white, size: 24),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'VICTOIRE! +1 COIN GAGNÉS!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFFFD700),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // ⭐ Enregistrer les succès (Victoire)
  Future<void> _recordWinAchievements() async {
    // Calcul des stats du match
    final goalsScored = widget.winnerResults.where((r) => r).length;
    final shotsTaken = widget.winnerResults.length;
    final rewindsUsed = AdController.instance.getUsedRewindCount();

    final newAchievements = await AchievementService().recordMatchWin(
      userScore: widget.winner.score,
      opponentScore: widget.loser.score,
      goalsScored: goalsScored,
      shotsTaken: shotsTaken,
      rewindsUsed: rewindsUsed,
      // Nouveaux paramètres (assurez-vous que GameController les passe, sinon 0 par défaut)
      goalsCurve: widget.goalsCurve,
      goalsLob: widget.goalsLob,
      goalsKnuckle: widget.goalsKnuckle,
    );

    // Afficher les nouveaux achievements débloqués
    if (newAchievements.isNotEmpty && mounted) {
      // Petit délai pour laisser l'animation de victoire se jouer
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        _showNewAchievementsDialog(newAchievements);
      }
    }
  }

  // ⭐ Enregistrer la défaite (Pour casser la série)
  Future<void> _recordLossStats() async {
    final rewindsUsed = AdController.instance.getUsedRewindCount();
    await AchievementService().recordMatchLoss(rewindsUsed: rewindsUsed);
  }

  // ⭐ Dialog pour les succès débloqués
  void _showNewAchievementsDialog(List<Achievement> newAchievements) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F3622),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.emoji_events, color: Color(0xFFFFD700)),
            SizedBox(width: 10),
            Text('Succès Débloqués !', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: newAchievements.map((achievement) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: achievement.color.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Icon(achievement.icon, color: achievement.color, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '+${achievement.rewardCoins} Coins',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)),
            child: const Text('GÉNIAL !', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
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
        ? [const Color(0xFF212121), const Color(0xFF424242), const Color(0xFF616161)]
        : [primaryColor.withOpacity(0.9), primaryColor.withOpacity(0.7), primaryColor.withOpacity(0.5)];

    return Scaffold(
      body: Stack(
        children: [
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
          SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      SlideTransition(
                        position: _slideAnimation,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 15),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDefeat ? Colors.grey.withOpacity(0.3) : primaryColor.withOpacity(0.4),
                                        blurRadius: 20,
                                        spreadRadius: 10,
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
                                        fontSize: 42,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 3,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.black.withOpacity(0.2),
                                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                                  ),
                                  child: Text(
                                    isDefeat ? "L'IA a remporté cette séance" : "Félicitations pour cette victoire !",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                if (!isDefeat) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFD700).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 16),
                                        SizedBox(width: 6),
                                        Text(
                                          '+1 COIN',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFFD700),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.6),
                                      blurRadius: 25,
                                      spreadRadius: 10,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    widget.winner.flagImage,
                                    width: 180,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  gradient: LinearGradient(
                                    colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.1)],
                                  ),
                                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                                ),
                                child: Text(
                                  widget.winner.name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                    shadows: [
                                      Shadow(offset: const Offset(2, 2), blurRadius: 6, color: Colors.black.withOpacity(0.7)),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.1)],
                                  ),
                                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 10)),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _buildEnhancedTeamCard(widget.winner, true),
                                        Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 10),
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFFF6B35).withOpacity(0.5),
                                                blurRadius: 10,
                                                spreadRadius: 3,
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            '${widget.winner.score} - ${widget.loser.score}',
                                            style: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                              shadows: [Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black54)],
                                            ),
                                          ),
                                        ),
                                        _buildEnhancedTeamCard(widget.loser, false),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
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
                      AnimatedBuilder(
                        animation: _buttonController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _buttonAnimation.value,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isDefeat) ...[
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
                                        const SizedBox(width: 10),
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
                                        const SizedBox(width: 10),
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
                colors: const [Colors.red, Colors.green, Colors.blue, Colors.yellow, Colors.purple, Colors.orange, Colors.white, Colors.pink],
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
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          text,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
        ),
      ),
    );
  }

  Widget _buildEnhancedTeamCard(Team team, bool isWinner) {
    return Flexible(
      child: Column(
        children: [
          Container(
            width: 70,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: isWinner ? team.color.withOpacity(0.6) : Colors.grey.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
                const BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(team.flagImage, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black.withOpacity(0.2),
            ),
            child: Text(
              team.name,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: isWinner ? FontWeight.bold : FontWeight.w500,
                shadows: const [Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black45)],
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.black.withOpacity(0.2),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Text(
              'TIRS AU BUT',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: team.color, letterSpacing: 1.2),
            ),
            const SizedBox(height: 6),
            Text(
              '$goals / $total',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black54)],
              ),
            ),
            const SizedBox(height: 10),
            if (hasMoreShots)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '(Derniers $_maxShotsToDisplay tirs)',
                  style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.7), fontStyle: FontStyle.italic),
                ),
              ),
            Wrap(
              spacing: 4,
              runSpacing: 4,
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
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGoal ? [const Color(0xFF4CAF50), const Color(0xFF2E7D32)] : [const Color(0xFFE53935), const Color(0xFFC62828)],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: (isGoal ? Colors.green : Colors.red).withOpacity(0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          isGoal ? Icons.check : Icons.close,
          color: Colors.white,
          size: 14,
          shadows: const [Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black54)],
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
    _controller = AnimationController(duration: widget.duration, vsync: this)..repeat(reverse: true);
    _animation = Tween<double>(begin: -15, end: 15).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
                BoxShadow(color: widget.color.withOpacity(0.5), blurRadius: widget.size, spreadRadius: widget.size / 4),
              ],
            ),
          ),
        );
      },
    );
  }
}
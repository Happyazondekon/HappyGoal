// result_screen.dart
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:happygoal/constants.dart';
import 'package:happygoal/l10n/app_localizations.dart';
import 'package:happygoal/utils/responsive_helper.dart';
import 'package:happygoal/models/team.dart';
import 'mode_selection_screen.dart';
import 'team_selection_screen.dart';
import 'package:happygoal/utils/ad_controller.dart';
import 'package:happygoal/services/achievement_service.dart';
import 'package:happygoal/models/achievement.dart';

class ResultScreen extends StatefulWidget {
  final Team winner;
  final Team loser;
  final List<bool> winnerResults;
  final List<bool> loserResults;
  final bool isSoloMode;
  final bool isUserWinner;
  final bool isTournamentMode;
  final double? aiIntelligence;
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
  late AnimationController _headerController;
  late AnimationController _scaleController;
  late AnimationController _statsController;
  late AnimationController _buttonController;
  late AnimationController _glowController;

  late Animation<double> _headerScale;
  late Animation<double> _glowAnim;

  final int _maxShotsToDisplay = 5;
  bool _coinsAwarded = false;
  bool _achievementsRecorded = false;

  bool get _isVictory => !widget.isSoloMode || widget.isUserWinner;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _statsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _headerScale = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutBack,
    );

    _glowAnim = Tween<double>(begin: 0.5, end: 1.0).animate(_glowController);

    _runAnimationSequence();

    if (!_achievementsRecorded && widget.isSoloMode) {
      _processMatchResult();
    }
  }

  void _runAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _headerController.forward();

    if (_isVictory) {
      await Future.delayed(const Duration(milliseconds: 300));
      _confettiController.play();
    }

    await Future.delayed(const Duration(milliseconds: 500));
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _statsController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _buttonController.forward();
  }

  void _processMatchResult() async {
    if (widget.isUserWinner) {
      if (!_coinsAwarded) {
        _awardVictoryCoins();
      }
      _recordWinAchievements();
    } else {
      _recordLossStats();
    }
    _achievementsRecorded = true;
  }

  void _awardVictoryCoins() async {
    await AdController.instance.addCoins(1);
    _coinsAwarded = true;

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
                  'VICTORY! +1 COIN EARNED!',
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

  Future<void> _recordWinAchievements() async {
    final goalsScored = widget.winnerResults.where((r) => r).length;
    final shotsTaken = widget.winnerResults.length;
    final rewindsUsed = AdController.instance.getUsedRewindCount();

    final newAchievements = await AchievementService().recordMatchWin(
      userScore: widget.winner.score,
      opponentScore: widget.loser.score,
      goalsScored: goalsScored,
      shotsTaken: shotsTaken,
      rewindsUsed: rewindsUsed,
      goalsCurve: widget.goalsCurve,
      goalsLob: widget.goalsLob,
      goalsKnuckle: widget.goalsKnuckle,
    );

    if (newAchievements.isNotEmpty && mounted) {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        _showNewAchievementsDialog(newAchievements);
      }
    }
  }

  Future<void> _recordLossStats() async {
    final rewindsUsed = AdController.instance.getUsedRewindCount();
    await AchievementService().recordMatchLoss(rewindsUsed: rewindsUsed);
  }

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
            Text('Achievements Unlocked!', style: TextStyle(color: Colors.white)),
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
            child: const Text('AWESOME!', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _headerController.dispose();
    _scaleController.dispose();
    _statsController.dispose();
    _buttonController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Premium gradient background
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.8,
                colors: _isVictory
                    ? [
                  const Color(0xFF1A3A22),
                  const Color(0xFF0A1A0F),
                  const Color(0xFF050D07),
                ]
                    : [
                  const Color(0xFF2A1A1A),
                  const Color(0xFF150A0A),
                  const Color(0xFF0D0505),
                ],
              ),
            ),
          ),

          // Animated glow
          if (_isVictory)
            AnimatedBuilder(
              animation: _glowAnim,
              builder: (context, _) {
                return Center(
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFFFD700)
                              .withOpacity(0.06 * _glowAnim.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  )
                );
                },
            ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  ScaleTransition(
                    scale: _headerScale,
                    child: _buildResultHeader(),
                  ),

                  const SizedBox(height: 32),

                  FadeTransition(
                    opacity: _scaleController,
                    child: _buildTeamsFaceoff(),
                  ),

                  const SizedBox(height: 24),

                  FadeTransition(
                    opacity: _statsController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(_statsController),
                      child: _buildShotsCard(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _buttonController,
                      curve: Curves.easeOutBack,
                    ),
                    child: _buildActionButtons(),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Confetti
          if (_isVictory)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                numberOfParticles: 30,
                colors: const [
                  Color(0xFFFFD700),
                  Colors.white,
                  Color(0xFF4CAF50),
                  Color(0xFF2196F3),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultHeader() {
    final resultTitle = _isVictory
        ? AppLocalizations.of(context)!.resultVictory
        : AppLocalizations.of(context)!.resultDefeat;
    final resultSubtitle = _isVictory
        ? AppLocalizations.of(context)!.resultVictorySubtitle
        : AppLocalizations.of(context)!.resultDefeatSubtitle;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Text(
            _isVictory ? 'VICTORY MATCH' : 'DEFEAT MATCH',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white54,
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: _isVictory
                ? [
              const Color(0xFFFFD700),
              Colors.white,
              const Color(0xFFFFD700)
            ]
                : [
              Colors.grey.shade400,
              Colors.white70,
              Colors.grey.shade400
            ],
          ).createShader(bounds),
          child: Text(
            resultTitle,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 3,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          resultSubtitle,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamsFaceoff() {
    final int goalsScored = widget.winnerResults.where((s) => s).length;
    final int goalsConceded = widget.loserResults.where((s) => s).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTeamCard(widget.winner, true),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDC143C), Color(0xFF8B0000)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDC143C).withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    '$goalsScored - $goalsConceded',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'FINAL SCORE',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            _buildTeamCard(widget.loser, false),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCard(Team team, bool isWinner) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: isWinner
                    ? const Color(0xFFFFD700).withOpacity(0.3)
                    : Colors.black.withOpacity(0.3),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              team.flagImage,
              width: 90,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Text(
            team.name,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isWinner ? FontWeight.w900 : FontWeight.w600,
              fontSize: 12,
              letterSpacing: 1,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildShotsCard() {
    final winnerGoals = widget.winnerResults.where((r) => r).length;
    final winnerTotal = widget.winnerResults.length;
    final loserGoals = widget.loserResults.where((r) => r).length;
    final loserTotal = widget.loserResults.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sports_soccer, color: Color(0xFFFFD700), size: 16),
                const SizedBox(width: 8),
                Text(
                  'SHOT STATISTICS',
                  style: TextStyle(
                    color: const Color(0xFFFFD700),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildShotStatRow(
              widget.winner.name,
              '$winnerGoals / $winnerTotal',
              _getLastShots(widget.winnerResults),
              true,
            ),
            const SizedBox(height: 16),
            _buildShotStatRow(
              widget.loser.name,
              '$loserGoals / $loserTotal',
              _getLastShots(widget.loserResults),
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShotStatRow(
    String teamName,
    String score,
    List<bool> results,
    bool isWinner,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                teamName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isWinner
                        ? [const Color(0xFFFFD700), const Color(0xFFF57F17)]
                        : [Colors.grey.shade600, Colors.grey.shade700],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  score,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: results.map((isGoal) {
              return Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isGoal
                        ? [const Color(0xFF4CAF50), const Color(0xFF2E7D32)]
                        : [const Color(0xFFE53935), const Color(0xFFC62828)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: (isGoal ? Colors.green : Colors.red)
                          .withOpacity(0.3),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  isGoal ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 14,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<bool> _getLastShots(List<bool> results) {
    if (results.length <= _maxShotsToDisplay) return results;
    return results.sublist(results.length - _maxShotsToDisplay);
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _navigateToTeamSelection,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFF57F17)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        _isVictory ? 'NEXT MATCH' : 'RETRY',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _navigateToModeSelection,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.home_rounded,
                          color: Colors.white, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'MAIN MENU',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
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

  void _navigateToModeSelection() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ModeSelectionScreen(),
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
        pageBuilder: (context, animation, secondaryAnimation) =>
            TeamSelectionScreen(
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
}

// tournament_result_screen.dart
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:happygoal/screens/tournament_mode_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:happygoal/models/game_state.dart';
import 'package:happygoal/models/team.dart';
import 'package:happygoal/notification_service.dart';
import 'home_screen.dart';
import 'package:happygoal/constants.dart';
import 'package:happygoal/utils/responsive_helper.dart';
import 'package:happygoal/utils/ad_controller.dart';
import 'package:happygoal/services/achievement_service.dart';
import 'package:happygoal/models/achievement.dart';
import 'package:happygoal/l10n/app_localizations.dart';

class TournamentResultScreen extends StatefulWidget {
  final Team userTeam;
  final int userWins;
  final int aiWins;
  final bool isWinner;
  final TournamentStats tournamentStats;
  final VoidCallback saveStatsCallback;
  final int totalRewindCount;
  final int totalGoalsScored;
  final int totalShotsTaken;
  final int totalMatchesWon;

  const TournamentResultScreen({
    Key? key,
    required this.userTeam,
    required this.userWins,
    required this.aiWins,
    required this.isWinner,
    required this.tournamentStats,
    required this.saveStatsCallback,
    required this.totalRewindCount,
    required this.totalGoalsScored,
    required this.totalShotsTaken,
    required this.totalMatchesWon,
  }) : super(key: key);

  @override
  _TournamentResultScreenState createState() => _TournamentResultScreenState();
}

class _TournamentResultScreenState extends State<TournamentResultScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _headerController;
  late AnimationController _trophyController;
  late AnimationController _statsController;
  late AnimationController _buttonController;
  late AnimationController _glowController;

  late Animation<double> _headerScale;
  late Animation<double> _glowAnim;

  bool _coinsAwarded = false;
  bool _achievementsRecorded = false;

  bool get _isChampion => widget.userWins == 4;

  @override
  void initState() {
    super.initState();
    _recordTournamentResult();

    _confettiController = ConfettiController(duration: const Duration(seconds: 5));

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _trophyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
    _saveUserTeamForNotifications();

    if (_isChampion && !_coinsAwarded) {
      _awardTournamentCoins();
    }

    if (_isChampion && !_achievementsRecorded) {
      _recordTournamentAchievements();
    }
  }

  void _runAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _headerController.forward();

    if (_isChampion) {
      await Future.delayed(const Duration(milliseconds: 300));
      _confettiController.play();
      await Future.delayed(const Duration(milliseconds: 200));
      _trophyController.forward();
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
      _trophyController.forward();
    }

    await Future.delayed(const Duration(milliseconds: 500));
    _statsController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _buttonController.forward();
  }

  // Implémentation de la méthode demandée
  void _recordTournamentResult() {
    final stats = widget.tournamentStats;
    final rewindCount = widget.totalRewindCount;
    final goalsScored = widget.totalGoalsScored;
    final shotsTaken = widget.totalShotsTaken;
    final matchesWon = widget.totalMatchesWon;
    final bool won = widget.isWinner;

    if (won) {
      stats.recordTournamentWin(rewindCount, goalsScored, shotsTaken, matchesWon);
    } else {
      stats.recordTournamentLoss(rewindCount, goalsScored, shotsTaken, matchesWon);
    }

    widget.saveStatsCallback();
  }

  void _awardTournamentCoins() async {
    await AdController.instance.addCoins(25);
    _coinsAwarded = true;

    if (_isChampion) {
      _handleTournamentWin();
    }

    await Future.delayed(const Duration(milliseconds: 2000));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.monetization_on, color: Colors.white, size: 24),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'CHAMPION! +25 COINS EARNED!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFFFD700),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(20),
        ),
      );
    }
  }

  Future<void> _recordTournamentAchievements() async {
    final newAchievements = await AchievementService().recordTournamentWin();
    _achievementsRecorded = true;

    if (newAchievements.isNotEmpty && mounted) {
      await Future.delayed(const Duration(milliseconds: 2500));
      if (mounted) {
        _showNewAchievementsDialog(newAchievements);
      }
    }
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

  void _handleTournamentWin() async {
    try {
      await NotificationService().saveUserTeam(widget.userTeam.name);
      await NotificationService().incrementTournamentWins();
      await NotificationService().sendTournamentWinNotification(context);
      await NotificationService().scheduleRecurringNotifications(context: context);
    } catch (e) {
      print('❌ Error handling tournament win: $e');
    }
  }

  void _saveUserTeamForNotifications() async {
    try {
      await NotificationService().saveUserTeam(widget.userTeam.name);
    } catch (e) {
      print('❌ Error saving user team: $e');
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _headerController.dispose();
    _trophyController.dispose();
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
                colors: _isChampion
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
          if (_isChampion)
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
                          const Color(0xFFFFD700).withOpacity(0.06 * _glowAnim.value),
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
                    opacity: _trophyController,
                    child: _buildTrophySection(),
                  ),

                  const SizedBox(height: 24),

                  FadeTransition(
                    opacity: _statsController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(_statsController),
                      child: _buildStatsCard(),
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
          if (_isChampion)
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
    final resultTitle = _isChampion
        ? 'TOURNAMENT CHAMPION'
        : widget.userWins > widget.aiWins
        ? 'GOOD PERFORMANCE'
        : 'TOURNAMENT DEFEAT';
    
    final resultSubtitle = _isChampion
        ? 'You Won The Tournament!'
        : widget.userWins > widget.aiWins
        ? 'You Were Eliminated'
        : 'End Of Your Journey';

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
            _isChampion ? 'CHAMPION' : 'TOURNAMENT RESULT',
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
            colors: _isChampion
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
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
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

  Widget _buildTrophySection() {
    return Container(
      child: Center(
        child: _isChampion
            ? SizedBox(
          height: 200,
          child: Lottie.asset(
            'assets/animations/trophy.json',
            repeat: false,
          ),
        )
            : Icon(
          Icons.emoji_events_outlined,
          size: 80,
          color: Colors.grey.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
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
                  'TOURNAMENT STATS',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatBadge(
                  'WINS',
                  widget.userWins.toString(),
                  const Color(0xFF4CAF50),
                ),
                _buildStatBadge(
                  'LOSSES',
                  widget.aiWins.toString(),
                  const Color(0xFFE53935),
                ),
                _buildStatBadge(
                  'TOTAL',
                  '${widget.userWins + widget.aiWins}',
                  const Color(0xFF2196F3),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailStat('Goals Scored', widget.totalGoalsScored.toString()),
            const SizedBox(height: 8),
            _buildDetailStat('Shots Taken', widget.totalShotsTaken.toString()),
            const SizedBox(height: 8),
            _buildDetailStat('Matches Won', widget.totalMatchesWon.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStat(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
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
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const HomeScreen(),
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
              },
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
                    children: const [
                      Icon(Icons.home_rounded, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'HOME',
                        style: TextStyle(
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
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const TournamentModeScreen(),
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
              },
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
                    children: const [
                      Icon(Icons.refresh_rounded, color: Colors.white, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'NEW TOURNAMENT',
                        style: TextStyle(
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
}
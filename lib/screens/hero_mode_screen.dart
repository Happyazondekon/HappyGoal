import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:happygoal/constants.dart';
import 'package:happygoal/models/game_state.dart';
import 'package:happygoal/models/team.dart';
import 'package:happygoal/screens/game_screen.dart';
import 'package:happygoal/screens/hero_result_screen.dart';
import 'package:happygoal/screens/hero_transition_screen.dart';
import 'package:happygoal/utils/ad_controller.dart';
import '../models/hero_progression.dart';
import 'hero_team_selection_screen.dart';

class HeroModeScreen extends StatefulWidget {
  @override
  State<HeroModeScreen> createState() => _HeroModeScreenState();
}

class _HeroModeScreenState extends State<HeroModeScreen>
    with TickerProviderStateMixin {
  HeroProgression? progression;
  String? selectedCountryCode;
  Map<String, dynamic>? _pendingResult;

  late ScrollController _scrollController;
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _pendingResult = null;
    _scrollController = ScrollController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 1.0, end: 1.15).animate(_pulseController);
    _floatAnimation =
        Tween<double>(begin: -6, end: 6).animate(_floatController);
    _loadProgression();
  }

  Future<void> _loadProgression() async {
    final loaded = await HeroProgression.load();
    if (loaded != null) {
      setState(() {
        progression = loaded;
        selectedCountryCode = loaded.selectedCountryCode;
      });
      // Scroll to current level after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentLevel();
      });
    }
  }

  void _scrollToCurrentLevel() {
    if (progression == null) return;
    final level = progression!.currentLevel;
    final totalLevels = progression!.maxLevel;
    // Levels are rendered bottom-to-top
    final position = (totalLevels - level) / totalLevels;
    final maxScroll = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      maxScroll * position,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _launchLevel(int level, Team myTeam, Team opponent) {
    final double aiDifficulty = 0.5 + 0.005 * (level - 1);
    Team myTeamCopy = myTeam.copyWith(score: 0);
    Team opponentCopy = opponent.copyWith(score: 0);
    final int stars = progression?.starsPerLevel[level] ?? 0;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HeroTransitionScreen(
          myTeam: myTeamCopy,
          opponent: opponentCopy,
          level: level,
          stars: stars,
          onContinue: () async {
            Navigator.pop(context);
            final gameState = GameState(
              team1: myTeamCopy,
              team2: opponentCopy,
              isSoloMode: true,
              isHeroMode: true,
              heroLevel: level,
              aiIntelligenceLevel: aiDifficulty.clamp(0.5, 1.0),
              isTournamentMode: false,
              currentPhase: GamePhase.playerShooting,
            );
            final result = await Navigator.push<Map<String, dynamic>>(
              context,
              MaterialPageRoute(
                builder: (_) => GameScreen(gameState: gameState),
              ),
            );
            if (result != null && result.containsKey('stars')) {
              await progression!.completeLevel(level, result['stars']);
              setState(() {
                _pendingResult = {
                  "level": level,
                  "stars": result['stars'],
                  "myTeam": myTeamCopy,
                  "opponent": opponentCopy,
                  // On passe le GameState complet pour que HeroResultScreen
                  // puisse évaluer les challenges depuis les vrais événements.
                  "gameState": gameState,
                };
              });
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_pendingResult != null && progression != null) {
      final int level = _pendingResult!["level"];
      final int stars = _pendingResult!["stars"];
      final Team myTeam = _pendingResult!["myTeam"];
      final Team opponent = _pendingResult!["opponent"];
      final GameState gameState = _pendingResult!["gameState"];
      return HeroResultScreen(
        myTeam: myTeam,
        opponent: opponent,
        level: level,
        starsWon: stars,
        gameState: gameState,
        onReplay: () {
          setState(() => _pendingResult = null);
          _launchLevel(level, myTeam, opponent);
        },
        onNextLevel: () {
          setState(() {
            _pendingResult = null;
            if (stars == 0 && progression!.currentLevel == level + 1) {
              progression!.currentLevel = level;
              progression!.save();
            }
          });
        },
      );
    }

    if (progression == null) {
      return HeroTeamSelectionScreen(
        selectedCountryCode: selectedCountryCode,
        onCountrySelected: (countryCode) {
          setState(() {
            selectedCountryCode = countryCode;
            progression = HeroProgression(selectedCountryCode: countryCode);
          });
        },
      );
    }

    return _buildMapScreen();
  }

  Widget _buildMapScreen() {
    int totalStars = 0;
    for (var s in progression!.starsPerLevel.values) {
      totalStars += s;
    }
    final int maxStars = progression!.maxLevel * 3;
    final int currentLevel = progression!.currentLevel;

    return Scaffold(
      body: Stack(
        children: [
          // Grass background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary, AppColors.fieldGreen, Color(0xFF0F4A2D)],
                stops: [0.0, 0.5, 1.0],

              ),
            ),
          ),

          // Grass texture stripes
          CustomPaint(
            size: Size.infinite,
            painter: _GrassStripePainter(),
          ),

          // Top snowy/cloudy decorative border
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBorder(),
          ),

          // Bottom decorative border
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBorder(),
          ),

          // Main scrollable level map
          Positioned.fill(
            top: 80,
            bottom: 80,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: _buildLevelPath(currentLevel),
            ),
          ),

          // Top HUD
          SafeArea(
            child: _buildHUD(totalStars, maxStars, currentLevel),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBorder() {
    return Container(
      height: 30,
      decoration: const BoxDecoration(
        color: Color(0xFFF5E6C8),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          12,
              (i) => Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: i % 2 == 0
                  ? const Color(0xFFE8D5A3)
                  : const Color(0xFFF0E4C0),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBorder() {
    return Container(
      height: 30,
      decoration: const BoxDecoration(
        color: Color(0xFF8B4513),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
    );
  }

  Widget _buildHUD(int totalStars, int maxStars, int currentLevel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
            ),
          ),

          // Title
          Column(
            children: [
              const Text(
                'MODE HERO',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFFD700), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$totalStars / $maxStars',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Reset button
          GestureDetector(
            onTap: _showResetDialog,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child:
              const Icon(Icons.flag, color: Color(0xFFFFD700), size: 22),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B2A1E),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Changer de pays ?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Vous perdrez votre progression. Voulez-vous recommencer ?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                progression = null;
                selectedCountryCode = null;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700)),
            child: const Text('Recommencer',
                style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardAdCard(int level) {
    return GestureDetector(
      onTap: () {
        AdController.instance.showRewardDialog(
          context: context,
          title: 'Récompense niveau $level',
          description: 'Regardez une vidéo pour gagner ${AdController.instance.rewardCoins} coins !',
          rewardType: 'coins',
          rewardAmount: AdController.instance.rewardCoins,
          onRewardEarned: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(children: [
                  const Icon(Icons.card_giftcard, color: Colors.white),
                  const SizedBox(width: 10),
                  Text('+${AdController.instance.rewardCoins} coins ajoutés !'),
                ]),
                backgroundColor: Colors.green,
              ),
            );
          },
          onAdFailed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Publicité indisponible ou erreur de chargement.'),
                backgroundColor: Colors.red,
              ),
            );
          },
        );
      },
      child: Card(
        color: const Color(0xFFFFF8E1),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: const [
              Icon(Icons.card_giftcard, color: Color(0xFFFFA000), size: 22),
              SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelPath(int currentLevel) {
    final int totalLevels = progression!.maxLevel;
    final List<Widget> items = [];

    // Build from level 100 down to 1 (so scroll reveals lower levels at bottom)
    // Goal at top
    items.add(_buildGoalNode());
    items.add(const SizedBox(height: 8));

    for (int level = totalLevels; level >= 1; level--) {
      final int stars = progression!.starsPerLevel[level] ?? 0;
      final bool isCompleted = stars > 0;
      final bool isCurrent = level == currentLevel;
      final bool isLocked = level > currentLevel;

      // Determine position offset (zigzag)
      final double xOffset = _getZigzagOffset(level, totalLevels);

      Widget node = _buildLevelNode(
        level: level,
        stars: stars,
        isCompleted: isCompleted,
        isCurrent: isCurrent,
        isLocked: isLocked,
        xOffset: xOffset,
      );

      // Ajoute une carte Reward Ad à côté de certains niveaux (ex: tous les 5 niveaux)
      if (level % 5 == 0) {
        node = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            node,
            const SizedBox(width: 12),
            _buildRewardAdCard(level),
          ],
        );
      }

      items.add(node);

      if (level > 1) {
        items.add(_buildDottedConnector(level, totalLevels));
      }
    }

    // Start flag at bottom
    items.add(const SizedBox(height: 8));
    items.add(_buildStartNode());
    items.add(const SizedBox(height: 40));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
      child: Column(
        children: items,
      ),
    );
  }

  double _getZigzagOffset(int level, int totalLevels) {
    // Creates a Score Hero-like winding path
    final int segment = (level - 1) ~/ 3;
    final bool goRight = segment % 2 == 0;
    final int posInSegment = (level - 1) % 3;

    if (posInSegment == 0) return 0; // center
    if (posInSegment == 1) return goRight ? 90.0 : -90.0;
    return goRight ? 120.0 : -120.0;
  }

  Widget _buildGoalNode() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          // Goal post icon
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 4))
              ],
            ),
            child: const Icon(Icons.sports_soccer,
                size: 36, color: Color(0xFF1B6B3A)),
          ),
          const SizedBox(height: 6),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'FIN',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartNode() {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 5)
            ],
          ),
          child: const Icon(Icons.flag, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 6),
        const Text(
          'DÉBUT',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildLevelNode({
    required int level,
    required int stars,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLocked,
    required double xOffset,
  }) {
    final bool canTap = !isLocked;

    // Node colors matching Score Hero style
    Color nodeColor;
    Color borderColor;
    if (isLocked) {
      nodeColor = const Color(0xFF8B6914);
      borderColor = const Color(0xFFA07820);
    } else if (isCurrent) {
      nodeColor = const Color(0xFF4169E1);
      borderColor = Colors.white;
    } else if (isCompleted) {
      nodeColor = const Color(0xFFDC143C);
      borderColor = const Color(0xFFFF6B6B);
    } else {
      nodeColor = const Color(0xFF4169E1);
      borderColor = Colors.white70;
    }

    Widget node = GestureDetector(
      onTap: canTap
          ? () {
        final allTeams = Team.getPredefinedTeams();
        final myTeam = allTeams.firstWhere(
                (t) => t.name == progression!.selectedCountryCode);
        final possibleOpponents =
        allTeams.where((t) => t.name != myTeam.name).toList();
        possibleOpponents.shuffle();
        final opponent = possibleOpponents.first;
        _launchLevel(level, myTeam, opponent);
      }
          : null,
      child: Column(
        children: [
          // Stars above node
          if (!isLocked)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  3,
                      (i) => Icon(
                    i < stars ? Icons.star : Icons.star_border,
                    color: i < stars
                        ? const Color(0xFFFFD700)
                        : Colors.white38,
                    size: 16,
                  ),
                ),
              ),
            ),
          // Circle node
          AnimatedBuilder(
            animation: isCurrent ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
            builder: (context, child) {
              return Transform.scale(
                scale: isCurrent ? _pulseAnimation.value : 1.0,
                child: child,
              );
            },
            child: Container(
              width: isCurrent ? 62 : 54,
              height: isCurrent ? 62 : 54,
              decoration: BoxDecoration(
                color: nodeColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: isCurrent ? 3 : 2),
                boxShadow: [
                  BoxShadow(
                    color: nodeColor.withOpacity(0.5),
                    blurRadius: isCurrent ? 20 : 8,
                    spreadRadius: isCurrent ? 4 : 2,
                  ),
                  const BoxShadow(
                    color: Colors.black38,
                    blurRadius: 4,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: isLocked
                  ? const Icon(Icons.lock, color: Colors.white70, size: 22)
                  : Center(
                child: Text(
                  '$level',
                  style: TextStyle(
                    fontSize: isCurrent ? 20 : 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: const [
                      Shadow(color: Colors.black45, blurRadius: 4)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Transform.translate(
      offset: Offset(xOffset, 0),
      child: node,
    );
  }

  Widget _buildDottedConnector(int level, int totalLevels) {
    // Direction of connector based on zigzag
    final double currentOffset = _getZigzagOffset(level, totalLevels);
    final double nextOffset = _getZigzagOffset(level - 1, totalLevels);
    final double dx = nextOffset - currentOffset;

    return SizedBox(
      height: 40,
      child: CustomPaint(
        painter: _DottedPathPainter(dx: dx),
        size: const Size(double.infinity, 40),
      ),
    );
  }
}

class _GrassStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final stripeHeight = size.height / 10;
    for (int i = 0; i < 10; i++) {
      paint.color = i % 2 == 0
          ? Colors.black.withOpacity(0.04)
          : Colors.transparent;
      canvas.drawRect(
        Rect.fromLTWH(0, i * stripeHeight, size.width, stripeHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DottedPathPainter extends CustomPainter {
  final double dx;
  _DottedPathPainter({required this.dx});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = size.width / 2;
    final startX = center;
    final endX = center + dx;

    final path = Path();
    path.moveTo(startX, 0);
    path.quadraticBezierTo(
      (startX + endX) / 2,
      size.height / 2,
      endX,
      size.height,
    );

    // Draw dashes along the path
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0;
      const dashLength = 5.0;
      const gapLength = 5.0;
      bool drawing = true;
      while (distance < metric.length) {
        final next = distance + (drawing ? dashLength : gapLength);
        if (drawing) {
          final extractedPath =
          metric.extractPath(distance, math.min(next, metric.length));
          canvas.drawPath(extractedPath, paint);
        }
        distance = next;
        drawing = !drawing;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
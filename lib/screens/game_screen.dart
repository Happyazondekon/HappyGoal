// game_screen.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:happygoal/constants.dart' hide ShotDirection;
import 'package:happygoal/models/game_state.dart';
import 'package:happygoal/screens/game_controller.dart';
import 'package:happygoal/services/hero_challenge_evaluator.dart';
import 'package:happygoal/widgets/goal_post_widget.dart';
import 'package:happygoal/widgets/goalkeeper_controller_widget.dart';
import 'package:happygoal/widgets/score_board_widget.dart';
import 'package:happygoal/widgets/shot_controller_widget.dart';
import 'package:happygoal/utils/audio_manager.dart';
import 'package:happygoal/utils/ad_controller.dart';
import 'package:happygoal/widgets/tutorial_mixin.dart';
import 'package:happygoal/widgets/tutorial_overlay.dart';

import 'game_helpers.dart';
import 'package:happygoal/widgets/rewind_reward_widget.dart';
import 'package:happygoal/models/hero_challenge.dart';

class GameScreen extends StatefulWidget {
  final GameState gameState;

  const GameScreen({
    Key? key,
    required this.gameState,
  }) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin, TutorialMixin {
  bool _hasPoppedHeroResult = false;
  late GameController _controller;

  // Clés globales pour les éléments du tutoriel
  final GlobalKey _goalPostKey = GlobalKey();
  final GlobalKey _shotControllerKey = GlobalKey();
  final GlobalKey _scoreBoardKey = GlobalKey();
  final GlobalKey _playerKey = GlobalKey();
  final GlobalKey _rewindKey = GlobalKey();
  final GlobalKey _goalkeeperControllerKey = GlobalKey();

  // Supporters animation
  late AnimationController _supportersController;
  late Animation<double> _supportersAnim;

  // ── Calcul du résultat Hero ──────────────────────────────────────────────
  Map<String, dynamic> _calculateHeroResult() {
    if (!widget.gameState.isHeroMode) {
      return {'stars': 0, 'completedChallenges': <bool>[]};
    }
    final int level = widget.gameState.heroLevel ?? 1;
    final List<bool> completed =
    HeroChallengeEvaluator.evaluateAll(level, _controller.gameState);
    if (completed.isEmpty || !completed[0]) {
      return {'stars': 0, 'completedChallenges': completed};
    }
    final int stars = completed.where((b) => b).length;
    return {'stars': stars, 'completedChallenges': completed};
  }

  int _calculateHeroStars() => (_calculateHeroResult()['stars'] as int);

  @override
  void initState() {
    super.initState();
    AudioManager.playSound('whistle');
    AdController.instance.onGameStarted();

    _supportersController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _supportersAnim = CurvedAnimation(
      parent: _supportersController,
      curve: Curves.easeInOut,
    );

    _controller = GameController(
      gameState: widget.gameState,
      vsync: this,
      context: context,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
      onNavigate: (Widget screen) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        }
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (widget.gameState.isSoloMode ||
            widget.gameState.isTournamentMode ||
            widget.gameState.isHeroMode) {
          showTutorialIfNeeded(
              'game_screen_solo', _createGameplayTutorialSteps());
          if (_controller.gameState.currentTeam ==
              _controller.gameState.team2) {
            _controller.handleAITurn();
          }
        } else {
          showTutorialIfNeeded(
              'game_screen_multi', _createMultiplayerTutorialSteps());
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _supportersController.dispose();
    AdController.instance.onGameCompleted(context);
    super.dispose();
  }

  // ── Tutoriel ─────────────────────────────────────────────────────────────
  List<TutorialStep> _createGameplayTutorialSteps() {
    return [
      TutorialStep(
        title: 'Bienvenue sur le terrain !',
        description:
        'Glisse depuis le ballon vers le haut pour tirer ! La vitesse = la puissance.',
        targetKey: _goalPostKey,
        position: TutorialPosition.bottom,
        customContent: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.swipe_up, color: Colors.green, size: 30),
                SizedBox(width: 10),
                Text(
                  'Swipe pour marquer !',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
      TutorialStep(
        title: 'Rembobiner et Récompense ↩️',
        description:
        'Si vous ratez un tir, utilisez un **Rembobinage** pour revenir en arrière.',
        targetKey: _rewindKey,
        position: TutorialPosition.bottom,
        customContent: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTipRow(Icons.ad_units, 'Gagnez plus en regardant une pub.'),
            _buildTipRow(Icons.history, 'Utilisez-le judicieusement.'),
          ],
        ),
      ),
      TutorialStep(
        title: 'Le tableau de score',
        description: 'Suivez ici les scores des deux équipes.',
        targetKey: _scoreBoardKey,
        position: TutorialPosition.bottom,
      ),
      TutorialStep(
        title: 'Choisir l\'effet',
        description:
        'Normal, Effet (curve), Lob ou Knuckle — sélectionnez avant de tirer.',
        targetKey: _shotControllerKey,
        position: TutorialPosition.top,
        customContent: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTipRow(Icons.sports_soccer, 'Normal : tir classique'),
            _buildTipRow(Icons.rotate_right, 'Effet : trajectoire courbée'),
            _buildTipRow(Icons.arrow_upward, 'Lob : par-dessus le gardien'),
            _buildTipRow(Icons.bolt, 'Knuckle : trajectoire imprévisible'),
          ],
        ),
      ),
    ];
  }

  List<TutorialStep> _createMultiplayerTutorialSteps() {
    return [
      TutorialStep(
        title: 'Mode Multijoueur !',
        description: 'Vous jouez contre un ami ! Chacun votre tour.',
        targetKey: _scoreBoardKey,
        position: TutorialPosition.bottom,
      ),
      TutorialStep(
        title: 'Glissez pour tirer',
        description:
        'Swipez depuis le ballon vers le haut — direction et vitesse comptent !',
        targetKey: _shotControllerKey,
        position: TutorialPosition.top,
      ),
      TutorialStep(
        title: 'Rembobiner ↩️',
        description: 'Utilisez un **Rembobinage** pour annuler un tir raté.',
        targetKey: _rewindKey,
        position: TutorialPosition.bottom,
      ),
    ];
  }

  Widget _buildTipRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  // ── Animation de la balle ────────────────────────────────────────────────
  Widget _buildBallAnimation(
      BuildContext context, BoxConstraints gameFieldConstraints) {
    final screenWidth = MediaQuery.of(context).size.width;
    double baseBallSize = screenWidth * 0.08;
    if (baseBallSize > 40) baseBallSize = 40;
    if (baseBallSize < 25) baseBallSize = 25;

    return AnimatedBuilder(
      animation: _controller.ballAnimationController,
      builder: (context, child) {
        if (!_controller.isShooting) return Container();

        double currentBallSize = baseBallSize;
        double rotation = 0.0;
        List<Widget> effectWidgets = [];

        if (_controller.gameState.shotPower > 70) {
          currentBallSize = baseBallSize * 1.1;
        }

        if (_controller.gameState.shotEffect == 'curve') {
          rotation =
              _controller.ballAnimationController.value * 2 * pi;
        }

        if (_controller.gameState.shotEffect == 'knuckle' &&
            _controller.ballAnimationController.value > 0.2) {
          double offsetX =
              sin(_controller.ballAnimationController.value * 10) *
                  (screenWidth * 0.01);
          double offsetY =
              cos(_controller.ballAnimationController.value * 8) *
                  (screenWidth * 0.01);

          for (int i = 1; i <= 3; i++) {
            double opacity = (1 - i * 0.25).clamp(0.1, 0.7);
            effectWidgets.add(
              Positioned(
                left: _controller.ballXAnimation.value -
                    (currentBallSize / 2) -
                    offsetX * i * 0.5,
                top: _controller.ballYAnimation.value -
                    (currentBallSize / 2) -
                    offsetY * i * 0.5,
                child: Opacity(
                  opacity: opacity,
                  child: Image.asset(
                    'assets/images/ball.png',
                    width: currentBallSize - i * (baseBallSize * 0.05),
                    height: currentBallSize - i * (baseBallSize * 0.05),
                  ),
                ),
              ),
            );
          }
        }

        if (_controller.gameState.shotEffect == 'lob') {
          effectWidgets.add(
            Positioned(
              left: _controller.ballXAnimation.value -
                  (screenWidth * 0.04),
              bottom: gameFieldConstraints.maxHeight * 0.15,
              child: Opacity(
                opacity: (1 - _controller.ballAnimationController.value)
                    .clamp(0.0, 0.5),
                child: Container(
                  width: screenWidth * 0.08,
                  height: screenWidth * 0.025,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius:
                    BorderRadius.circular(screenWidth * 0.04),
                  ),
                ),
              ),
            ),
          );
        }

        if (_controller.gameState.shotPower > 80) {
          for (int i = 1; i <= 5; i++) {
            double opacity = (1 - i * 0.15).clamp(0.1, 0.7);
            double trailOffsetX =
                (_controller.ballXAnimation.value -
                    (gameFieldConstraints.maxWidth / 2)) /
                    10;

            effectWidgets.add(
              Positioned(
                left: _controller.ballXAnimation.value -
                    (currentBallSize - i * (baseBallSize * 0.075)) / 2 -
                    trailOffsetX * i,
                top: _controller.ballYAnimation.value -
                    (currentBallSize - i * (baseBallSize * 0.075)) / 2 +
                    (baseBallSize * 0.05) * i,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: currentBallSize - i * (baseBallSize * 0.075),
                    height: currentBallSize - i * (baseBallSize * 0.075),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.orangeAccent.withOpacity(0.8),
                          Colors.red.withOpacity(0.4),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        }

        effectWidgets.add(
          Positioned(
            left: _controller.ballXAnimation.value - currentBallSize / 2,
            top: _controller.ballYAnimation.value - currentBallSize / 2,
            child: Transform.rotate(
              angle: rotation,
              child: Image.asset(
                'assets/images/ball.png',
                width: currentBallSize,
                height: currentBallSize,
              ),
            ),
          ),
        );

        return Stack(children: effectWidgets);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Détection automatique de fin de match Hero
    if (!_hasPoppedHeroResult &&
        widget.gameState.isHeroMode &&
        _controller.gameState.checkWinner()) {
      _hasPoppedHeroResult = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context, _calculateHeroResult());
        }
      });
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double responsiveFontSize(double baseSize) =>
        baseSize * (screenWidth / 375.0).clamp(0.8, 1.5);
    double responsivePadding(double basePadding) =>
        basePadding * (screenWidth / 375.0).clamp(0.8, 1.5);

    final TextStyle titleStyle = TextStyle(
      fontSize: responsiveFontSize(18),
      fontWeight: FontWeight.bold,
      color: Colors.white,
      shadows: const [
        Shadow(offset: Offset(1, 1), blurRadius: 3, color: Colors.black54)
      ],
    );
    final TextStyle subtitleStyle = TextStyle(
      fontSize: responsiveFontSize(16),
      fontWeight: FontWeight.bold,
      color: Colors.white,
      shadows: const [
        Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black54)
      ],
    );
    final TextStyle goalTextStyle = TextStyle(
      fontSize: responsiveFontSize(48),
      fontWeight: FontWeight.bold,
      color: Colors.white,
      shadows: [
        Shadow(
          color: _controller.gameState.currentTeam?.color ?? AppColors.primary,
          blurRadius: 15,
          offset: const Offset(0, 0),
        ),
        const Shadow(color: Colors.black, blurRadius: 5, offset: Offset(2, 2))
      ],
    );

    final double topSectionMaxHeight = screenHeight * 0.28;
    // ── La zone de swipe est intégrée dans le terrain, pas dans le bas ──
    final double bottomSectionMaxHeight = screenHeight * 0.20;

    return WillPopScope(
      onWillPop: () async {
        if (widget.gameState.isHeroMode) {
          Navigator.pop(context, _calculateHeroResult());
          return false;
        }
        AudioManager.playSound('whistle');
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // ── Fond dégradé gazon ──────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary,
                    AppColors.fieldGreen,
                    Color(0xFF0F4A2D),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // ── Rayures gazon ───────────────────────────────────────────
            CustomPaint(
              size: Size.infinite,
              painter: _GrassStripePainter(),
            ),

            // ── Supporters ───────────────────────────────────────────────
            AnimatedBuilder(
              animation: _supportersAnim,
              builder: (context, _) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _SupportersPainter(
                    jumpProgress: _supportersAnim.value,
                    team1Color: widget.gameState.team1?.color ??
                        const Color(0xFF2196F3),
                    team2Color: widget.gameState.team2?.color ??
                        const Color(0xFFE53935),
                  ),
                );
              },
            ),

            // ── Contenu du jeu ───────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  // ── TOP : Score, phase, rewind ───────────────────────
                  ConstrainedBox(
                    constraints:
                    BoxConstraints(maxHeight: topSectionMaxHeight),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: responsivePadding(10)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: responsivePadding(5)),
                          if (_controller.gameState.isTournamentMode &&
                              _controller.gameState.tournamentState != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: responsivePadding(15),
                                vertical: responsivePadding(8),
                              ),
                              margin: EdgeInsets.only(
                                  top: responsivePadding(5),
                                  bottom: responsivePadding(5)),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(
                                    responsivePadding(20)),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 1),
                              ),
                              child: Text(
                                _controller.gameState.tournamentState!
                                    .getPhaseName(),
                                style: titleStyle.copyWith(
                                    fontSize: responsiveFontSize(16)),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          RewindRewardWidget(
                            key: _rewindKey,
                            gameState: _controller.gameState,
                            onStateChanged: () => setState(() {}),
                            gameController: _controller,
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: responsivePadding(5)),
                            child: ScoreBoardWidget(
                              key: _scoreBoardKey,
                              team1: _controller.gameState.team1!,
                              team2: _controller.gameState.team2!,
                              currentTeam:
                              _controller.gameState.currentTeam!,
                              team1Results:
                              _controller.gameState.team1Results,
                              team2Results:
                              _controller.gameState.team2Results,
                              shotsPerTeam: PenaltySettings.shotsPerTeam,
                            ),
                          ),

                          if (_controller.gameState.isSuddenDeathPhase())
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: responsivePadding(15),
                                  vertical: responsivePadding(5)),
                              margin: EdgeInsets.only(
                                  bottom: responsivePadding(5)),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(
                                    responsivePadding(15)),
                              ),
                              child: Text(
                                'MORT SUBITE',
                                style: subtitleStyle.copyWith(
                                    fontSize: responsiveFontSize(14),
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),

                          Padding(
                            padding:
                            EdgeInsets.only(bottom: responsivePadding(5)),
                            child: Text(
                              GameHelpers.getRoundText(
                                  _controller.gameState),
                              style: subtitleStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: responsivePadding(5)),
                        ],
                      ),
                    ),
                  ),

                  // ── TERRAIN : gardien, balle, swipe intégré ──────────
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double gameAreaHeight = constraints.maxHeight;
                        final double gameAreaWidth = constraints.maxWidth;
                        final double goalkeeperTopPosition =
                            gameAreaHeight * 0.23;
                        final double goalkeeperSize =
                        min(gameAreaWidth * 0.25, gameAreaHeight * 0.25);
                        final double playerBottomPosition =
                            gameAreaHeight * 0.05;
                        final double playerSize =
                        min(gameAreaWidth * 0.2, gameAreaHeight * 0.22);
                        final double goalTextTop = gameAreaHeight * 0.40;

                        // ── La zone de swipe couvre le bas du terrain ──
                        // Elle est superposée par-dessus le terrain pour
                        // que le glissement parte visuellement du joueur.
                        final bool showSwipe =
                        GameHelpers.shouldShowShotControls(
                            _controller.gameState);

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // ── Poteaux ──────────────────────────────
                            Positioned(
                              top: 0,
                              child:
                              GoalPostWidget(key: _goalPostKey),
                            ),

                            // ── Gardien ───────────────────────────────
                            Positioned(
                              top: goalkeeperTopPosition,
                              child: SlideTransition(
                                position:
                                _controller.goalkeeperAnimation,
                                child: Container(
                                  width: goalkeeperSize,
                                  height: goalkeeperSize * 1.2,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: GameHelpers
                                            .getOpponentTeamColor(
                                            _controller.gameState)
                                            .withOpacity(0.6),
                                        blurRadius: 25,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    'assets/images/players/goalkeeper.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),

                            // ── Balle animée ──────────────────────────
                            _buildBallAnimation(context, constraints),

                            // ── Joueur (affiché séparément si pas de swipe) ─
                            if (!showSwipe)
                              Positioned(
                                bottom: playerBottomPosition,
                                child: Container(
                                  key: _playerKey,
                                  width: playerSize,
                                  height: playerSize * 1.25,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (_controller.gameState
                                            .currentTeam?.color ??
                                            AppColors.primary)
                                            .withOpacity(0.6),
                                        blurRadius: 25,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    'assets/images/players/striker.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                            // ── Zone de swipe + joueur intégrés ───────
                            if (showSwipe)
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Image du joueur au-dessus de la zone swipe
                                    Container(
                                      key: _playerKey,
                                      width: playerSize,
                                      height: playerSize * 1.25,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: (_controller
                                                .gameState
                                                .currentTeam
                                                ?.color ??
                                                AppColors.primary)
                                                .withOpacity(0.6),
                                            blurRadius: 25,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: Image.asset(
                                        'assets/images/players/striker.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    // Widget de swipe (effet + zone de glissement)
                                    ShotControllerWidget(
                                      key: _shotControllerKey,
                                      onShoot: (direction, power, effect) =>
                                          _controller.shoot(
                                              direction, power, effect),
                                    ),
                                  ],
                                ),
                              ),

                            // ── Texte BUUT / ARRÊT ────────────────────
                            if (_controller.showGoalText &&
                                _controller.gameState.isGoalScored)
                              Positioned(
                                top: goalTextTop,
                                child: SlideTransition(
                                  position: _controller.goalTextAnimation,
                                  child: Text(
                                    _controller.getResultText(),
                                    style: goalTextStyle,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),

                  // ── BAS : Résultats / Contrôles gardien / IA ─────────
                  ConstrainedBox(
                    constraints:
                    BoxConstraints(maxHeight: bottomSectionMaxHeight),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: responsivePadding(10)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: responsivePadding(8)),

                          // ── Contrôles gardien (humain contre IA) ────
                          if (GameHelpers.shouldShowGoalkeeperControls(
                              _controller.gameState))
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: responsivePadding(10)),
                              child: GoalkeeperControllerWidget(
                                key: _goalkeeperControllerKey,
                                onDive: (direction) => _controller
                                    .setGoalkeeperDirection(direction),
                              ),
                            ),

                          // ── Indicateur tour IA ───────────────────────
                          if (GameHelpers.shouldShowAIIndicator(
                              _controller.gameState))
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: responsivePadding(10)),
                              child: Text(
                                _controller.gameState.currentPhase ==
                                    GamePhase.humanGoalkeeping
                                    ? "L'IA va tirer - Choisissez votre plongée !"
                                    : "Tour de l'IA - Patientez...",
                                style: titleStyle.copyWith(
                                    fontSize: responsiveFontSize(16)),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          // ── Résultat du tir ──────────────────────────
                          if (_controller.gameState.currentPhase ==
                              GamePhase.goalScored ||
                              _controller.gameState.currentPhase ==
                                  GamePhase.goalSaved)
                            Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: responsivePadding(10)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: responsivePadding(30),
                                  vertical: responsivePadding(15)),
                              decoration: BoxDecoration(
                                color: (_controller.gameState.isGoalScored
                                    ? AppColors.primary
                                    : Colors.redAccent)
                                    .withOpacity(0.85),
                                borderRadius: BorderRadius.circular(
                                    responsivePadding(20)),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.7),
                                    width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                              child: Text(
                                _controller.getResultText(),
                                style: titleStyle.copyWith(
                                    fontSize: responsiveFontSize(22)),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          if (kDebugMode)
                            FloatingActionButton.small(
                              onPressed: () {
                                if (widget.gameState.isSoloMode ||
                                    widget.gameState.isTournamentMode) {
                                  forceTutorial('game_screen_solo',
                                      _createGameplayTutorialSteps());
                                } else {
                                  forceTutorial('game_screen_multi',
                                      _createMultiplayerTutorialSteps());
                                }
                              },
                              child: const Icon(Icons.help),
                            ),

                          SizedBox(height: responsivePadding(10)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Painters identiques à l'original ─────────────────────────────────────────

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
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SupportersPainter extends CustomPainter {
  final double jumpProgress;
  final Color team1Color;
  final Color team2Color;

  _SupportersPainter({
    required this.jumpProgress,
    required this.team1Color,
    required this.team2Color,
  });

  static const double _supporterW = 14.0;
  static const double _supporterH = 20.0;
  static const double _rowThickness = 28.0;
  static const double _maxJump = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    _drawRow(
      canvas: canvas,
      size: size,
      side: _Side.top,
      baseColor: team2Color,
      altColor: team2Color.withOpacity(0.6),
    );
    _drawRow(
      canvas: canvas,
      size: size,
      side: _Side.left,
      baseColor: team1Color,
      altColor: team1Color.withOpacity(0.6),
    );
    _drawRow(
      canvas: canvas,
      size: size,
      side: _Side.right,
      baseColor: team1Color,
      altColor: team1Color.withOpacity(0.6),
    );
  }

  void _drawRow({
    required Canvas canvas,
    required Size size,
    required _Side side,
    required Color baseColor,
    required Color altColor,
  }) {
    final bool isVertical =
        side == _Side.left || side == _Side.right;
    final int count = isVertical
        ? (size.height / (_supporterW + 4)).floor()
        : (size.width / (_supporterW + 4)).floor();

    for (int i = 0; i < count; i++) {
      final double phase = (i / count + jumpProgress) % 1.0;
      final double jump = _maxJump * _jumpCurve(phase);
      final Color color = i % 3 == 0 ? altColor : baseColor;

      double cx, cy;
      switch (side) {
        case _Side.top:
          cx = i * (_supporterW + 4) + _supporterW / 2 + 2;
          cy = _rowThickness / 2 - jump;
          break;
        case _Side.left:
          cx = _rowThickness / 2;
          cy = i * (_supporterW + 4) + _supporterW / 2 + 2 - jump;
          break;
        case _Side.right:
          cx = size.width - _rowThickness / 2;
          cy = i * (_supporterW + 4) + _supporterW / 2 + 2 - jump;
          break;
      }

      _drawSupporter(canvas, cx, cy, color, side);
    }
  }

  double _jumpCurve(double t) {
    if (t < 0.5) return 4 * t * (0.5 - t) * 2;
    return 0.0;
  }

  void _drawSupporter(
      Canvas canvas, double cx, double cy, Color color, _Side side) {
    final paint = Paint()..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, cy + _supporterH * 0.55),
          width: _supporterW * 0.8,
          height: 4),
      shadowPaint,
    );

    paint.color = color;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(cx, cy + _supporterH * 0.3),
          width: _supporterW * 0.75,
          height: _supporterH * 0.55),
      const Radius.circular(4),
    );
    canvas.drawRRect(bodyRect, paint);

    final armPaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(cx - _supporterW * 0.37, cy + _supporterH * 0.1),
      Offset(cx - _supporterW * 0.62, cy - _supporterH * 0.12),
      armPaint,
    );
    canvas.drawLine(
      Offset(cx + _supporterW * 0.37, cy + _supporterH * 0.1),
      Offset(cx + _supporterW * 0.62, cy - _supporterH * 0.12),
      armPaint,
    );

    paint.color = const Color(0xFFFFDBAC);
    canvas.drawCircle(
        Offset(cx, cy - _supporterH * 0.08), _supporterW * 0.28, paint);

    paint.color = color.withOpacity(0.85);
    canvas.drawRect(
      Rect.fromCenter(
          center: Offset(cx, cy + _supporterH * 0.07),
          width: _supporterW * 0.6,
          height: 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SupportersPainter old) =>
      old.jumpProgress != jumpProgress;
}

enum _Side { top, left, right }
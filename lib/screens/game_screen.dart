import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/foundation.dart'; // Importez kDebugMode
import '../constants.dart' hide ShotDirection;
import '../models/game_state.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/goal_post_widget.dart';
import '../widgets/goalkeeper_controller_widget.dart';
import '../widgets/score_board_widget.dart';
import '../widgets/shot_controller_widget.dart';
import '../utils/audio_manager.dart';
import '../utils/ad_controller.dart';
import '../widgets/tutorial_mixin.dart';
import '../widgets/tutorial_overlay.dart';
import 'game_controller.dart';
import 'game_helpers.dart';
import '../widgets/rewind_reward_widget.dart';

// --- CLASSE POUR GÉRER LA NEIGE (OPTIMISÉE) ---
class SnowFlake {
  double x;
  double y;
  double radius;
  double speed;
  double opacity;

  SnowFlake({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
  });
}

class SnowPainter extends CustomPainter {
  final List<SnowFlake> flakes;

  SnowPainter(this.flakes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (var flake in flakes) {
      paint.color = Colors.white.withOpacity(flake.opacity);
      canvas.drawCircle(Offset(flake.x * size.width, flake.y * size.height), flake.radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// ---------------------------------------------------------------------------

class GameScreen extends StatefulWidget {
  final GameState gameState;

  const GameScreen({
    Key? key,
    required this.gameState,
  }) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin, TutorialMixin {
  late GameController _controller;

  // Clés globales pour les éléments du tutoriel
  final GlobalKey _goalPostKey = GlobalKey();
  final GlobalKey _shotControllerKey = GlobalKey();
  final GlobalKey _scoreBoardKey = GlobalKey();
  final GlobalKey _playerKey = GlobalKey();
  final GlobalKey _rewindKey = GlobalKey();
  final GlobalKey _goalkeeperControllerKey = GlobalKey();

  // --- VARIABLES NEIGE ---
  late AnimationController _snowController;
  final List<SnowFlake> _snowFlakes = [];
  final Random _random = Random();
  final int _numberOfFlakes = 50; // Nombre raisonnable pour la performance

  @override
  void initState() {
    super.initState();
    AudioManager.playSound('whistle');
    AdController.instance.onGameStarted();

    // Initialisation de la neige
    _initSnow();
    _snowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // La durée importe peu, on boucle
    )..repeat();

    _snowController.addListener(_updateSnow);


    _controller = GameController(
      gameState: widget.gameState,
      vsync: this,
      context: context,
      onStateChanged: () {
        if (mounted) {
          setState(() {});
        }
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
        if (widget.gameState.isSoloMode || widget.gameState.isTournamentMode) {
          showTutorialIfNeeded('game_screen_solo', _createGameplayTutorialSteps());
          if (_controller.gameState.currentTeam == _controller.gameState.team2) {
            _controller.handleAITurn();
          }
        } else {
          showTutorialIfNeeded('game_screen_multi', _createMultiplayerTutorialSteps());
        }
      }
    });
  }

  void _initSnow() {
    for (int i = 0; i < _numberOfFlakes; i++) {
      _snowFlakes.add(SnowFlake(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        radius: _random.nextDouble() * 2 + 1, // Taille entre 1 et 3
        speed: _random.nextDouble() * 0.005 + 0.002, // Vitesse variable
        opacity: _random.nextDouble() * 0.5 + 0.3, // Opacité entre 0.3 et 0.8
      ));
    }
  }

  void _updateSnow() {
    setState(() {
      for (var flake in _snowFlakes) {
        flake.y += flake.speed;
        if (flake.y > 1.0) {
          // Reset en haut quand il sort de l'écran
          flake.y = -0.05;
          flake.x = _random.nextDouble();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _snowController.dispose(); // Ne pas oublier de dispose
    AdController.instance.onGameCompleted(context);
    super.dispose();
  }

  // --- TUTORIEL STEPS ---
  List<TutorialStep> _createGameplayTutorialSteps() {
    return [
      TutorialStep(
        title: 'Bienvenue sur le terrain !',
        description: 'C\'est ici que la magie opère ! Découvrons comment marquer des buts spectaculaires.',
        targetKey: _goalPostKey,
        position: TutorialPosition.bottom,
        customContent: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.sports_soccer, color: Colors.green, size: 30),
                SizedBox(width: 10),
                Text(
                  'Votre objectif : marquer !',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
      TutorialStep(
        title: 'Rembobiner et Récompense ↩️',
        description: 'C\'est votre filet de sécurité ! Si vous ratez un tir, utilisez un **Rembobinage** pour revenir en arrière.',
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
        title: 'Votre joueur',
        description: 'C\'est votre tireur !',
        targetKey: _playerKey,
        position: TutorialPosition.top,
      ),
      TutorialStep(
        title: 'Contrôles de tir',
        description: 'Utilisez ces boutons pour choisir direction, puissance et effet.',
        targetKey: _shotControllerKey,
        position: TutorialPosition.top,
        customContent: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTipRow(Icons.gps_fixed, 'Direction : Gauche, Centre, Droite'),
            _buildTipRow(Icons.flash_on, 'Puissance : Attention au dosage'),
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
        title: 'Tour par tour',
        description: 'Regardez le tableau de score pour savoir qui tire.',
        targetKey: _scoreBoardKey,
        position: TutorialPosition.bottom,
      ),
      TutorialStep(
        title: 'Stratégie',
        description: 'Bluffez votre adversaire !',
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
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }


  Widget _buildBallAnimation(BuildContext context, BoxConstraints gameFieldConstraints) {
    if (_controller.ballXAnimation == null || _controller.ballYAnimation == null) {
      return Container();
    }

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
          rotation = _controller.ballAnimationController.value * 2 * pi;
        }

        if (_controller.gameState.shotEffect == 'knuckle' && _controller.ballAnimationController.value > 0.2) {
          double offsetX = sin(_controller.ballAnimationController.value * 10) * (screenWidth * 0.01);
          double offsetY = cos(_controller.ballAnimationController.value * 8) * (screenWidth * 0.01);

          for (int i = 1; i <= 3; i++) {
            double opacity = (1 - i * 0.25).clamp(0.1, 0.7);
            effectWidgets.add(
              Positioned(
                left: _controller.ballXAnimation!.value - (currentBallSize / 2) - offsetX * i * 0.5,
                top: _controller.ballYAnimation!.value - (currentBallSize / 2) - offsetY * i * 0.5,
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
              left: _controller.ballXAnimation!.value - (screenWidth * 0.04),
              bottom: gameFieldConstraints.maxHeight * 0.15,
              child: Opacity(
                opacity: (1 - _controller.ballAnimationController.value).clamp(0.0, 0.5),
                child: Container(
                  width: screenWidth * 0.08,
                  height: screenWidth * 0.025,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                ),
              ),
            ),
          );
        }

        if (_controller.gameState.shotPower > 80) {
          for (int i = 1; i <= 5; i++) {
            double opacity = (1 - i * 0.15).clamp(0.1, 0.7);
            double trailOffsetX = (_controller.ballXAnimation!.value - (gameFieldConstraints.maxWidth / 2)) / 10;

            effectWidgets.add(
              Positioned(
                left: _controller.ballXAnimation!.value - (currentBallSize - i * (baseBallSize*0.075))/2 - trailOffsetX * i,
                top: _controller.ballYAnimation!.value - (currentBallSize - i * (baseBallSize*0.075))/2 + (baseBallSize*0.05) * i,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: currentBallSize - i * (baseBallSize*0.075),
                    height: currentBallSize - i * (baseBallSize*0.075),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                          colors: [
                            Colors.orangeAccent.withOpacity(0.8),
                            Colors.red.withOpacity(0.4),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0]
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
            left: _controller.ballXAnimation!.value - currentBallSize / 2,
            top: _controller.ballYAnimation!.value - currentBallSize / 2,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double responsiveFontSize(double baseSize) => baseSize * (screenWidth / 375.0).clamp(0.8, 1.5);
    double responsivePadding(double basePadding) => basePadding * (screenWidth / 375.0).clamp(0.8, 1.5);

    final TextStyle titleStyle = TextStyle(
      fontSize: responsiveFontSize(18),
      fontWeight: FontWeight.bold,
      color: Colors.white,
      shadows: const [Shadow(offset: Offset(1, 1), blurRadius: 3, color: Colors.black54)],
    );
    final TextStyle subtitleStyle = TextStyle(
      fontSize: responsiveFontSize(16),
      fontWeight: FontWeight.bold,
      color: Colors.white,
      shadows: const [Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black54)],
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
        const Shadow(
            color: Colors.black,
            blurRadius: 5,
            offset: Offset(2,2)
        )
      ],
    );

    final double topSectionMaxHeight = screenHeight * 0.30;
    final double bottomSectionMaxHeight = screenHeight * 0.25;


    return WillPopScope(
      onWillPop: () async {
        AudioManager.playSound('whistle');
        return true;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/field_background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Stack( // Utiliser un Stack global pour la neige
              children: [
                Column(
                  children: [
                    // --- TOP INFO SECTION ---
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: topSectionMaxHeight,
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: responsivePadding(10)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: responsivePadding(5)),
                            if (_controller.gameState.isTournamentMode && _controller.gameState.tournamentState != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: responsivePadding(15),
                                  vertical: responsivePadding(8),
                                ),
                                margin: EdgeInsets.only(top: responsivePadding(5), bottom: responsivePadding(5)),
                                decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(responsivePadding(20)),
                                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 1)
                                ),
                                child: Text(
                                  _controller.gameState.tournamentState!.getPhaseName(),
                                  style: titleStyle.copyWith(fontSize: responsiveFontSize(16)),
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
                              padding: EdgeInsets.symmetric(vertical: responsivePadding(5)),
                              child: ScoreBoardWidget(
                                key: _scoreBoardKey,
                                team1: _controller.gameState.team1!,
                                team2: _controller.gameState.team2!,
                                currentTeam: _controller.gameState.currentTeam!,
                                team1Results: _controller.gameState.team1Results,
                                team2Results: _controller.gameState.team2Results,
                                shotsPerTeam: PenaltySettings.shotsPerTeam,
                              ),
                            ),
                            if (_controller.gameState.isSuddenDeathPhase())
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: responsivePadding(15), vertical: responsivePadding(5)),
                                margin: EdgeInsets.only(bottom: responsivePadding(5)),
                                decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.85),
                                    borderRadius: BorderRadius.circular(responsivePadding(15)),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                          offset: const Offset(0, 2))
                                    ]
                                ),
                                child: Text(
                                  'MORT SUBITE',
                                  style: subtitleStyle.copyWith(fontSize: responsiveFontSize(14), color: Colors.white, fontWeight: FontWeight.w900),
                                ),
                              ),

                            Padding(
                              padding: EdgeInsets.only(bottom: responsivePadding(5)),
                              child: Text(
                                GameHelpers.getRoundText(_controller.gameState),
                                style: subtitleStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: responsivePadding(5)),
                          ],
                        ),
                      ),
                    ),

                    // --- GAME FIELD SECTION ---
                    Expanded(
                      child: LayoutBuilder(
                          builder: (context, gameFieldConstraints) {
                            final double gameAreaHeight = gameFieldConstraints.maxHeight;
                            final double gameAreaWidth = gameFieldConstraints.maxWidth;
                            final double goalPostTopPosition = gameAreaHeight * 0.0;
                            final double goalkeeperTopPosition = gameAreaHeight * 0.23;
                            final double goalkeeperSize = min(gameAreaWidth * 0.25, gameAreaHeight * 0.25);
                            final double playerBottomPosition = gameAreaHeight * 0.05;
                            final double playerSize = min(gameAreaWidth * 0.2, gameAreaHeight * 0.22);
                            final double goalTextTop = gameAreaHeight * 0.40;

                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  top: goalPostTopPosition,
                                  child: GoalPostWidget(key: _goalPostKey),
                                ),
                                Positioned(
                                  top: goalkeeperTopPosition,
                                  child: SlideTransition(
                                    position: _controller.goalkeeperAnimation,
                                    child: Container(
                                      width: goalkeeperSize,
                                      height: goalkeeperSize * 1.2,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: GameHelpers.getOpponentTeamColor(_controller.gameState).withOpacity(0.6),
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
                                _buildBallAnimation(context, gameFieldConstraints),
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
                                          color: (_controller.gameState.currentTeam?.color ?? AppColors.primary).withOpacity(0.6),
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
                                if (_controller.showGoalText && _controller.gameState.isGoalScored)
                                  Positioned(
                                    top: goalTextTop,
                                    child: SlideTransition(
                                      position: _controller.goalTextAnimation,
                                      child: Text(
                                        'GOALLL..!',
                                        style: goalTextStyle,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }
                      ),
                    ),

                    // --- BOTTOM INFO / CONTROLS SECTION ---
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: bottomSectionMaxHeight,
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: responsivePadding(10)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: responsivePadding(10)),
                            if (GameHelpers.shouldShowGoalkeeperControls(_controller.gameState))
                              Padding(
                                padding: EdgeInsets.only(bottom: responsivePadding(10)),
                                child: GoalkeeperControllerWidget(
                                  key: _goalkeeperControllerKey,
                                  onDive: (direction) => _controller.setGoalkeeperDirection(direction),
                                ),
                              ),

                            if (GameHelpers.shouldShowAIIndicator(_controller.gameState))
                              Padding(
                                padding: EdgeInsets.only(bottom: responsivePadding(10)),
                                child: Text(
                                  _controller.gameState.currentPhase == GamePhase.humanGoalkeeping
                                      ? "L'IA va tirer - Choisissez votre plongée !"
                                      : "Tour de l'IA - Patientez...",
                                  style: titleStyle.copyWith(fontSize: responsiveFontSize(16)),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            if (_controller.gameState.currentPhase == GamePhase.playerShooting &&
                                (_controller.gameState.currentTeam == _controller.gameState.team1 ||
                                    (!_controller.gameState.isSoloMode && !_controller.gameState.isTournamentMode)))
                              Padding(
                                padding: EdgeInsets.only(bottom: responsivePadding(10)),
                                child: ShotControllerWidget(
                                  key: _shotControllerKey,
                                  onShoot: (direction, power, effect) => _controller.shoot(direction, power, effect),
                                ),
                              ),
                            if (_controller.gameState.currentPhase == GamePhase.goalScored ||
                                _controller.gameState.currentPhase == GamePhase.goalSaved)
                              Container(
                                margin: EdgeInsets.symmetric(vertical: responsivePadding(10)),
                                padding: EdgeInsets.symmetric(horizontal: responsivePadding(30), vertical: responsivePadding(15)),
                                decoration: BoxDecoration(
                                    color: (_controller.gameState.isGoalScored ? AppColors.primary : Colors.redAccent).withOpacity(0.85),
                                    borderRadius: BorderRadius.circular(responsivePadding(20)),
                                    border: Border.all(color: Colors.white.withOpacity(0.7), width:1.5),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.4),
                                          spreadRadius: 2,
                                          blurRadius: 8,
                                          offset: const Offset(0, 3))
                                    ]
                                ),
                                child: Text(
                                  _controller.getResultText(),
                                  style: titleStyle.copyWith(fontSize: responsiveFontSize(22)),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                            if (kDebugMode)
                              FloatingActionButton.small(
                                onPressed: () {
                                  if (widget.gameState.isSoloMode || widget.gameState.isTournamentMode) {
                                    forceTutorial('game_screen_solo', _createGameplayTutorialSteps());
                                  } else {
                                    forceTutorial('game_screen_multi', _createMultiplayerTutorialSteps());
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
                // ⚠️ AJOUT DE LA NEIGE PAR-DESSUS TOUT (POUR L'AMBIANCE)
                IgnorePointer(
                  child: CustomPaint(
                    painter: SnowPainter(_snowFlakes),
                    child: Container(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
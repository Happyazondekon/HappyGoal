import 'package:flutter/material.dart';
import 'dart:math';
import '../constants.dart' hide ShotDirection;
import '../models/game_state.dart';
import '../widgets/goal_post_widget.dart';
import '../widgets/score_board_widget.dart';
import '../widgets/shot_controller_widget.dart';
import '../utils/audio_manager.dart';

import 'game_controller.dart';
import 'game_helpers.dart';

class GameScreen extends StatefulWidget {
  final GameState gameState;

  const GameScreen({
    Key? key,
    required this.gameState,
  }) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameController _controller;

  @override
  void initState() {
    super.initState();
    AudioManager.playSound('whistle'); //

    _controller = GameController( //
      gameState: widget.gameState, //
      vsync: this, //
      context: context, //
      onStateChanged: () { //
        if (mounted) { //
          setState(() {}); //
        }
      },
      onNavigate: (Widget screen) { //
        if (mounted) { //
          Navigator.pushReplacement( //
            context,
            MaterialPageRoute(builder: (_) => screen), //
          );
        }
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && (_controller.gameState.isSoloMode || _controller.gameState.isTournamentMode) && //
          _controller.gameState.currentTeam == _controller.gameState.team2) { //
        _controller.handleAITurn(); //
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); //
    super.dispose();
  }
  Widget _buildBallAnimation(BuildContext context, BoxConstraints gameFieldConstraints) {
    if (_controller.ballXAnimation == null || _controller.ballYAnimation == null) { //
      return Container(); //
    }

    final screenWidth = MediaQuery.of(context).size.width; // Peut être utilisé pour des effets globaux
    // final gameAreaWidth = gameFieldConstraints.maxWidth; // Plus spécifique à la zone de jeu
    // final gameAreaHeight = gameFieldConstraints.maxHeight; // Plus spécifique à la zone de jeu


    // Base ball size, can be made responsive to gameAreaWidth or screenWidth
    double baseBallSize = screenWidth * 0.08; // Ajusté pour être un peu plus petit
    if (baseBallSize > 40) baseBallSize = 40; // Max size
    if (baseBallSize < 25) baseBallSize = 25; // Min size

    return AnimatedBuilder(
      animation: _controller.ballAnimationController, //
      builder: (context, child) {
        if (!_controller.isShooting) return Container(); //

        double currentBallSize = baseBallSize;
        double rotation = 0.0; //
        List<Widget> effectWidgets = []; //

        if (_controller.gameState.shotPower > 70) { //
          currentBallSize = baseBallSize * 1.1;
        }

        if (_controller.gameState.shotEffect == 'curve') { //
          rotation = _controller.ballAnimationController.value * 2 * pi; //
        }

        // Effet visuel pour knuckle (oscillation aléatoire)
        if (_controller.gameState.shotEffect == 'knuckle' && _controller.ballAnimationController.value > 0.2) { //
          double offsetX = sin(_controller.ballAnimationController.value * 10) * (screenWidth * 0.01); //
          double offsetY = cos(_controller.ballAnimationController.value * 8) * (screenWidth * 0.01); //

          for (int i = 1; i <= 3; i++) { //
            double opacity = (1 - i * 0.25).clamp(0.1, 0.7); //
            effectWidgets.add( //
              Positioned( //
                left: _controller.ballXAnimation!.value - (currentBallSize / 2) - offsetX * i * 0.5, //
                top: _controller.ballYAnimation!.value - (currentBallSize / 2) - offsetY * i * 0.5, //
                child: Opacity( //
                  opacity: opacity, //
                  child: Image.asset( //
                    'assets/images/ball.png', //
                    width: currentBallSize - i * (baseBallSize * 0.05), //
                    height: currentBallSize - i * (baseBallSize * 0.05), //
                  ),
                ),
              ),
            );
          }
        }

        // Effet visuel pour lob (trajectoire plus haute)
        if (_controller.gameState.shotEffect == 'lob') { //
          effectWidgets.add( //
            Positioned( //
              left: _controller.ballXAnimation!.value - (screenWidth * 0.04), //
              // Position de l'ombre relative au bas de la zone de jeu effective, pas écran total
              // Ceci pourrait nécessiter gameFieldConstraints.maxHeight si la zone de jeu ne commence pas à 0
              bottom: gameFieldConstraints.maxHeight * 0.15, // Ajuster cette valeur au besoin
              child: Opacity( //
                opacity: (1 - _controller.ballAnimationController.value).clamp(0.0, 0.5), //
                child: Container( //
                  width: screenWidth * 0.08, //
                  height: screenWidth * 0.025, //
                  decoration: BoxDecoration( //
                    color: Colors.black.withOpacity(0.5), //
                    borderRadius: BorderRadius.circular(screenWidth * 0.04), //
                  ),
                ),
              ),
            ),
          );
        }

        // Effet visuel pour tir puissant (trainée de feu)
        if (_controller.gameState.shotPower > 80) { //
          for (int i = 1; i <= 5; i++) { //
            double opacity = (1 - i * 0.15).clamp(0.1, 0.7); //
            double trailOffsetX = (_controller.ballXAnimation!.value - (gameFieldConstraints.maxWidth / 2)) / 10; //

            effectWidgets.add( //
              Positioned( //
                left: _controller.ballXAnimation!.value - (currentBallSize - i * (baseBallSize*0.075))/2 - trailOffsetX * i, //
                top: _controller.ballYAnimation!.value - (currentBallSize - i * (baseBallSize*0.075))/2 + (baseBallSize*0.05) * i, //
                child: Opacity( //
                  opacity: opacity, //
                  child: Container( //
                    width: currentBallSize - i * (baseBallSize*0.075), //
                    height: currentBallSize - i * (baseBallSize*0.075), //
                    decoration: BoxDecoration( //
                      shape: BoxShape.circle, //
                      gradient: RadialGradient( //
                          colors: [ //
                            Colors.orangeAccent.withOpacity(0.8),
                            Colors.red.withOpacity(0.4),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0] //
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        }

        effectWidgets.add( //
          Positioned( //
            left: _controller.ballXAnimation!.value - currentBallSize / 2, //
            top: _controller.ballYAnimation!.value - currentBallSize / 2, //
            child: Transform.rotate( //
              angle: rotation, //
              child: Image.asset( //
                'assets/images/ball.png', //
                width: currentBallSize, //
                height: currentBallSize, //
              ),
            ),
          ),
        );

        return Stack(children: effectWidgets); //
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; //
    final screenHeight = MediaQuery.of(context).size.height; //

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
      color: Colors.yellowAccent,
      shadows: [
        Shadow(
          color: _controller.gameState.currentTeam?.color ?? AppColors.primary, //
          blurRadius: 15,
          offset: const Offset(0, 0),
        ),
        const Shadow( //
            color: Colors.black, //
            blurRadius: 5, //
            offset: Offset(2,2) //
        )
      ],
    );

    final double topSectionMaxHeight = screenHeight * 0.30;
    final double bottomSectionMaxHeight = screenHeight * 0.25;


    return WillPopScope(
      onWillPop: () async { //
        AudioManager.playSound('whistle'); //
        return true; //
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration( //
            image: DecorationImage( //
              image: AssetImage('assets/images/field_background.jpg'), //
              fit: BoxFit.cover, //
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // --- TOP INFO SECTION ---
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: topSectionMaxHeight,
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: responsivePadding(10)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Important pour que la Column ne prenne que la hauteur nécessaire
                      children: [
                        SizedBox(height: responsivePadding(5)),
                        if (_controller.gameState.isTournamentMode && _controller.gameState.tournamentState != null) //
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
                              _controller.gameState.tournamentState!.getPhaseName(), //
                              style: titleStyle.copyWith(fontSize: responsiveFontSize(16)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: responsivePadding(5)),
                          child: ScoreBoardWidget( //
                            team1: _controller.gameState.team1!, //
                            team2: _controller.gameState.team2!, //
                            currentTeam: _controller.gameState.currentTeam!, //
                            team1Results: _controller.gameState.team1Results, //
                            team2Results: _controller.gameState.team2Results, //
                            shotsPerTeam: PenaltySettings.shotsPerTeam, //
                          ),
                        ),
                        if (_controller.gameState.isSuddenDeathPhase()) //
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
                              'MORT SUBITE', //
                              style: subtitleStyle.copyWith(fontSize: responsiveFontSize(14), color: Colors.white, fontWeight: FontWeight.w900),
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.only(bottom: responsivePadding(5)),
                          child: Text(
                            GameHelpers.getRoundText(_controller.gameState), //
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

                        // Abaisser le but : Augmenter cette valeur pour faire descendre le but.
                        // Exemple : le haut du but est maintenant à 10% du haut de la zone de jeu.
                        final double goalPostTopPosition = gameAreaHeight * 0.0; // Auparavant 0.03

                        // Positionner le gardien par rapport au but abaissé.
                        // Légèrement en dessous du haut du but pour que sa tête soit près de la barre transversale.
                        final double goalkeeperTopPosition = gameAreaHeight * 0.23; // Auparavant 0.28

                        final double goalkeeperSize = min(gameAreaWidth * 0.25, gameAreaHeight * 0.25);
                        final double playerBottomPosition = gameAreaHeight * 0.05;
                        final double playerSize = min(gameAreaWidth * 0.2, gameAreaHeight * 0.22);

                        final double goalTextTop = gameAreaHeight * 0.40;

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned( //
                              top: goalPostTopPosition, //
                              child: const GoalPostWidget(), //
                            ),
                            Positioned( //
                              top: goalkeeperTopPosition, //
                              child: SlideTransition( //
                                position: _controller.goalkeeperAnimation, //
                                child: Container( //
                                  width: goalkeeperSize, //
                                  height: goalkeeperSize * 1.2, //
                                  decoration: BoxDecoration( //
                                    shape: BoxShape.circle, //
                                    boxShadow: [ //
                                      BoxShadow( //
                                        color: GameHelpers.getOpponentTeamColor(_controller.gameState).withOpacity(0.6), //
                                        blurRadius: 25, //
                                        spreadRadius: 5, //
                                      ),
                                    ],
                                  ),
                                  child: Image.asset( //
                                    'assets/images/players/goalkeeper.png', //
                                    fit: BoxFit.contain, //
                                  ),
                                ),
                              ),
                            ),
                            _buildBallAnimation(context, gameFieldConstraints), // Passer les contraintes
                            Positioned( //
                              bottom: playerBottomPosition, //
                              child: Container( //
                                width: playerSize, //
                                height: playerSize * 1.25, //
                                decoration: BoxDecoration( //
                                  shape: BoxShape.circle, //
                                  boxShadow: [ //
                                    BoxShadow( //
                                      color: (_controller.gameState.currentTeam?.color ?? AppColors.primary).withOpacity(0.6), //
                                      blurRadius: 25, //
                                      spreadRadius: 5, //
                                    ),
                                  ],
                                ),
                                child: Image.asset( //
                                  'assets/images/players/striker.png', //
                                  fit: BoxFit.contain, //
                                ),
                              ),
                            ),
                            if (_controller.showGoalText && _controller.gameState.isGoalScored) //
                              Positioned( //
                                top: goalTextTop, //
                                child: SlideTransition( //
                                  position: _controller.goalTextAnimation, //
                                  child: Text( //
                                    'GOALLL..!', //
                                    style: goalTextStyle, //
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
                        if ((_controller.gameState.isSoloMode || _controller.gameState.isTournamentMode) && //
                            _controller.gameState.currentTeam == _controller.gameState.team2 && //
                            _controller.gameState.currentPhase == GamePhase.playerShooting) //
                          Padding(
                            padding: EdgeInsets.only(bottom: responsivePadding(10)),
                            child: Text(
                              "Tour de l'IA - Patientez...", //
                              style: titleStyle.copyWith(fontSize: responsiveFontSize(16)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        if (_controller.gameState.currentPhase == GamePhase.playerShooting && //
                            (_controller.gameState.currentTeam == _controller.gameState.team1 || //
                                (!_controller.gameState.isSoloMode && !_controller.gameState.isTournamentMode))) //
                          Padding(
                            padding: EdgeInsets.only(bottom: responsivePadding(10)),
                            child: ShotControllerWidget( //
                              onShoot: (direction, power, effect) => _controller.shoot(direction, power, effect), //
                            ),
                          ),
                        if (_controller.gameState.currentPhase == GamePhase.goalScored || //
                            _controller.gameState.currentPhase == GamePhase.goalSaved) //
                          Container(
                            margin: EdgeInsets.symmetric(vertical: responsivePadding(10)),
                            padding: EdgeInsets.symmetric(horizontal: responsivePadding(30), vertical: responsivePadding(15)),
                            decoration: BoxDecoration(
                                color: (_controller.gameState.isGoalScored ? AppColors.primary : Colors.redAccent).withOpacity(0.85), //
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
                              _controller.getResultText(), //
                              style: titleStyle.copyWith(fontSize: responsiveFontSize(22)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        SizedBox(height: responsivePadding(10)), // Espace final en bas
                      ],
                    ),
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
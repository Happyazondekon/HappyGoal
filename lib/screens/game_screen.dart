import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../constants.dart';
import '../models/game_state.dart';
import '../models/team.dart';
import '../widgets/goal_post_widget.dart';
import '../widgets/score_board_widget.dart';
import '../widgets/shot_controller_widget.dart';
import '../utils/audio_manager.dart';
import 'result_screen.dart';

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
  late GameState _gameState;
  late AnimationController _ballAnimationController;
  late Animation<double> _ballXAnimation;
  late Animation<double> _ballYAnimation;
  late AnimationController _goalkeeperController;
  late Animation<Offset> _goalkeeperAnimation;
  late AnimationController _goalTextController;
  late Animation<Offset> _goalTextAnimation;
  bool _isShooting = false;
  bool _showGoalText = false;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _gameState = widget.gameState;
    AudioManager.playSound('whistle');

    // Contrôleur pour l'animation du ballon
    _ballAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Contrôleur pour l'animation du gardien
    _goalkeeperController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Contrôleur pour l'animation du texte "GOALLL..!"
    _goalTextController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _setupAnimations();
    _setupListeners();
  }

  void _setupAnimations() {
    _setupGoalkeeperAnimation(ShotDirection.center);
    _setupBallAnimation();
    _setupGoalTextAnimation();
  }

  void _setupListeners() {
    _ballAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleShotResult();
      }
    });

    _goalTextController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showGoalText = false;
        });
        _goalTextController.reset();
      }
    });
  }

  void _setupGoalkeeperAnimation(int direction) {
    Offset goalkeeperEndOffset;
    switch (direction) {
      case ShotDirection.left:
        goalkeeperEndOffset = const Offset(-0.8, -0.3);
        break;
      case ShotDirection.right:
        goalkeeperEndOffset = const Offset(0.8, -0.3);
        break;
      default:
        goalkeeperEndOffset = const Offset(0.0, -0.5);
    }

    _goalkeeperAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: goalkeeperEndOffset,
    ).animate(CurvedAnimation(
      parent: _goalkeeperController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupBallAnimation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Size screenSize = MediaQuery.of(context).size;
      double startX = screenSize.width / 2;
      double startY = screenSize.height - 150;

      double endX;
      switch (_gameState.selectedDirection) {
        case ShotDirection.left:
          endX = screenSize.width / 3 - 20;
          break;
        case ShotDirection.right:
          endX = screenSize.width * 2 / 3 + 20;
          break;
        default:
          endX = screenSize.width / 2;
      }
      double endY = 100;

      setState(() {
        _ballXAnimation = Tween<double>(
          begin: startX,
          end: endX,
        ).animate(_ballAnimationController);

        _ballYAnimation = Tween<double>(
          begin: startY,
          end: endY,
        ).animate(
          CurvedAnimation(
            parent: _ballAnimationController,
            curve: Curves.easeOut,
          ),
        );
      });
    });
  }

  void _setupGoalTextAnimation() {
    _goalTextAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0.0),
      end: const Offset(1.5, 0.0),
    ).animate(CurvedAnimation(
      parent: _goalTextController,
      curve: Curves.linear,
    ));
  }

  void _shoot(int direction) {
    if (_isShooting) return;

    setState(() {
      _isShooting = true;
      _gameState.selectedDirection = direction;
      _gameState.currentPhase = GamePhase.goalkeeeperSaving;
      _gameState.goalkeepeerDirection = _random.nextInt(3);
    });

    _setupGoalkeeperAnimation(_gameState.goalkeepeerDirection);
    _setupBallAnimation();

    AudioManager.playSound('kick');
    _goalkeeperController.forward();
    _ballAnimationController.forward(from: 0.0);
  }

  void _handleShotResult() {
    if (!mounted) return;

    final bool isGoalScored = _gameState.selectedDirection != _gameState.goalkeepeerDirection;

    setState(() {
      _gameState.isGoalScored = isGoalScored;
      _gameState.currentPhase = isGoalScored ? GamePhase.goalScored : GamePhase.goalSaved;
      _gameState.recordShotResult(isGoalScored);

      if (isGoalScored) {
        _showGoalText = true;
        _goalTextController.forward(from: 0.0);
        AudioManager.playSound('goal');
        Timer(const Duration(milliseconds: 300), () {
          AudioManager.playSound('crowd_cheer');
        });
      } else {
        AudioManager.playSound('goalkeeper_save');
      }
    });

    if (_gameState.checkWinner()) {
      Timer(const Duration(milliseconds: 1000), () {
        AudioManager.playSound('whistle');
      });

      Timer(const Duration(milliseconds: 1500), () {
        Team winner = _gameState.getWinner()!;
        Team loser = winner == _gameState.team1! ? _gameState.team2! : _gameState.team1!;

        List<bool> winnerResults = [];
        List<bool> loserResults = [];

        if (winner == _gameState.team1!) {
          winnerResults.addAll(_gameState.team1Results);
          winnerResults.addAll(_gameState.team1SuddenDeathResults);
          loserResults.addAll(_gameState.team2Results);
          loserResults.addAll(_gameState.team2SuddenDeathResults);
        } else {
          winnerResults.addAll(_gameState.team2Results);
          winnerResults.addAll(_gameState.team2SuddenDeathResults);
          loserResults.addAll(_gameState.team1Results);
          loserResults.addAll(_gameState.team1SuddenDeathResults);
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              winner: winner,
              loser: loser,
              winnerResults: winnerResults,
              loserResults: loserResults,
            ),
          ),
        );
      });
    } else {
      Timer(const Duration(milliseconds: 1500), () {
        setState(() {
          _resetRound();
        });
      });
    }
  }

  void _resetRound() {
    _ballAnimationController.reset();
    _goalkeeperController.reset();
    _gameState.shouldStartNewRound();
    _gameState.switchTeam();
    _gameState.currentPhase = GamePhase.playerShooting;
    _gameState.isGoalScored = false;
    _isShooting = false;
    AudioManager.playSound('whistle');
  }

  // Méthode pour obtenir la couleur de l'équipe adverse
  Color _getOpponentTeamColor() {
    if (_gameState.currentTeam == _gameState.team1) {
      return _gameState.team2!.color;
    } else {
      return _gameState.team1!.color;
    }
  }

  @override
  void dispose() {
    _ballAnimationController.dispose();
    _goalkeeperController.dispose();
    _goalTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              children: [
                // Score Board
                ScoreBoardWidget(
                  team1: _gameState.team1!,
                  team2: _gameState.team2!,
                  currentTeam: _gameState.currentTeam!,
                  team1Results: _gameState.team1Results,
                  team2Results: _gameState.team2Results,
                  shotsPerTeam: PenaltySettings.shotsPerTeam,
                ),

                // Game Status
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    _getStatusText(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(offset: Offset(1, 1), blurRadius: 3, color: Colors.black),
                      ],
                    ),
                  ),
                ),

                // Round indicator
                if (_gameState.isSuddenDeathPhase())
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      'MORT SUBITE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    _gameState.isSuddenDeathPhase()
                        ? 'Tour de départage ${_gameState.roundNumber - PenaltySettings.shotsPerTeam}'
                        : 'Tour ${_gameState.roundNumber}/${PenaltySettings.shotsPerTeam}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black),
                      ],
                    ),
                  ),
                ),

                // Game Field
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Goal Post
                      Positioned(
                        top: 0,
                        left: MediaQuery.of(context).size.width * 0.05, // Center it with 5% padding on each side
                        child: const GoalPostWidget(),
                      ),
                      // Goalkeeper with aura
                      Positioned(
                        top: 120,
                        child: SlideTransition(
                          position: _goalkeeperAnimation,
                          child: Container(
                            width: 100,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _getOpponentTeamColor().withOpacity(0.7),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/players/goalkeeper.png',
                              width: 100,
                              height: 120,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),

                      // Ball
                      if (_ballXAnimation != null && _ballYAnimation != null)
                        AnimatedBuilder(
                          animation: _ballAnimationController,
                          builder: (context, child) {
                            return _isShooting
                                ? Positioned(
                              left: _ballXAnimation.value - 20,
                              top: _ballYAnimation.value - 20,
                              child: Image.asset(
                                'assets/images/ball.png',
                                width: 40,
                                height: 40,
                              ),
                            )
                                : Container();
                          },
                        ),

                      // Player with aura
                      Positioned(
                        bottom: 20,
                        child: Container(
                          width: 80,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _gameState.currentTeam!.color.withOpacity(0.7),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/players/striker.png',
                            width: 80,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      // GOALLL..! Text Animation
                      if (_showGoalText && _gameState.isGoalScored)
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.3,
                          child: SlideTransition(
                            position: _goalTextAnimation,
                            child: Text(
                              'GOALLL..!',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: _gameState.currentTeam!.color,
                                    blurRadius: 10,
                                    offset: const Offset(0, 0),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Shot Controls
                if (_gameState.currentPhase == GamePhase.playerShooting)
                  ShotControllerWidget(onShoot: _shoot),

                // Result Text
                if (_gameState.currentPhase == GamePhase.goalScored ||
                    _gameState.currentPhase == GamePhase.goalSaved)
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    decoration: BoxDecoration(
                      color: _gameState.isGoalScored ? AppColors.primary : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _gameState.isGoalScored ? 'BUUUUT!' : 'ARRÊT DU GARDIEN!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

  String _getStatusText() {
    switch (_gameState.currentPhase) {
      case GamePhase.playerShooting:
        return "Au tour de ${_gameState.currentTeam!.name} - Choisissez une direction";
      case GamePhase.goalkeeeperSaving:
        return "Le gardien plonge...";
      case GamePhase.goalScored:
        return "But pour ${_gameState.currentTeam!.name}!";
      case GamePhase.goalSaved:
        return "Arrêt du gardien!";
      default:
        return "";
    }
  }
}
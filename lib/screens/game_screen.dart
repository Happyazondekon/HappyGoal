import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../constants.dart';
import '../models/game_state.dart';
import '../widgets/goal_post_widget.dart';
import '../widgets/goalkeeper_widget.dart';
import '../widgets/player_widget.dart';
import '../widgets/score_board_widget.dart';
import '../widgets/shot_controller_widget.dart';
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
  late AnimationController _ballController;
  late Animation<Offset> _ballAnimation;
  late AnimationController _goalkeeperController;
  late Animation<Offset> _goalkeeperAnimation;

  final Random _random = Random();

  // Ball position
  double _ballX = 0.0;
  double _ballY = 0.0;

  @override
  void initState() {
    super.initState();
    _gameState = widget.gameState;

    _ballController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _goalkeeperController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _setupAnimations(ShotDirection.center);
  }

  void _setupAnimations(int direction) {
    // Setup goalkeeper animation
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

    // Setup ball animation
    double endX;
    switch (_gameState.selectedDirection) {
      case ShotDirection.left:
        endX = -0.7;
        break;
      case ShotDirection.right:
        endX = 0.7;
        break;
      default:
        endX = 0.0;
    }

    _ballAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: Offset(endX, -1.5),
    ).animate(CurvedAnimation(
      parent: _ballController,
      curve: Curves.easeOut,
    ));
  }

  void _shoot(int direction) {
    setState(() {
      _gameState.selectedDirection = direction;
      _gameState.currentPhase = GamePhase.goalkeeeperSaving;

      // Simulate goalkeeper prediction
      _gameState.goalkeepeerDirection = _random.nextInt(3);

      // Setup animations with selected direction
      _setupAnimations(direction);
    });

    // Play animations
    _goalkeeperController.forward();
    _ballController.forward().then((_) {
      // Determine if goal is scored
      final bool isGoalScored = _gameState.selectedDirection != _gameState.goalkeepeerDirection;

      setState(() {
        _gameState.isGoalScored = isGoalScored;
        _gameState.currentPhase = isGoalScored ? GamePhase.goalScored : GamePhase.goalSaved;

        if (isGoalScored) {
          _gameState.currentTeam!.incrementScore();
        }
      });

      // Check if game is over
      if (_gameState.checkWinner()) {
        Timer(const Duration(milliseconds: 1500), () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ResultScreen(winner: _gameState.getWinner()!),
            ),
          );
        });
      } else {
        // Continue to next round
        Timer(const Duration(milliseconds: 1500), () {
          setState(() {
            _resetRound();
          });
        });
      }
    });
  }

  void _resetRound() {
    _ballController.reset();
    _goalkeeperController.reset();

    _gameState.switchTeam();
    _gameState.roundCount++;
    _gameState.currentPhase = GamePhase.playerShooting;
    _gameState.isGoalScored = false;
  }

  @override
  void dispose() {
    _ballController.dispose();
    _goalkeeperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              ),

              // Game Status Text
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  _getStatusText(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 3,
                        color: Colors.black,
                      ),
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
                    const Positioned(
                      top: 0,
                      child: GoalPostWidget(),
                    ),

                    // Goalkeeper
                    Positioned(
                      top: 60,
                      child: SlideTransition(
                        position: _goalkeeperAnimation,
                        child: GoalkeeperWidget(
                          team: _gameState.currentTeam == _gameState.team1
                              ? _gameState.team2!
                              : _gameState.team1!,
                        ),
                      ),
                    ),

                    // Ball
                    Positioned(
                      bottom: 100,
                      child: SlideTransition(
                        position: _ballAnimation,
                        child: Image.asset(
                          'assets/images/ball.png',
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ),

                    // Player
                    const Positioned(
                      bottom: 20,
                      child: PlayerWidget(),
                    ),
                  ],
                ),
              ),

              // Shot Controls
              if (_gameState.currentPhase == GamePhase.playerShooting)
                ShotControllerWidget(
                  onShoot: _shoot,
                ),

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
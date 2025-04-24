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
import '../utils/game_logic.dart';
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
  bool _isShooting = false;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _gameState = widget.gameState;

    // Jouer le son du coup de sifflet au début
    AudioManager.playSound('whistle');

    _ballAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _goalkeeperController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialiser les animations
    _setupGoalkeeperAnimation(ShotDirection.center);
    _setupBallAnimation();

    _ballAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleShotResult();
      }
    });
  }

  void _setupGoalkeeperAnimation(int direction) {
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
  }

  void _setupBallAnimation() {
    // La première fois, context pourrait ne pas être disponible
    // Donc on utilise WidgetsBinding pour s'assurer que le widget est construit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Size screenSize = MediaQuery.of(context).size;

      // Position initiale du ballon (près du joueur)
      double startX = screenSize.width / 2;
      double startY = screenSize.height - 150;

      // Position finale du ballon (dans le but selon la direction)
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
      double endY = 100; // Hauteur du but

      setState(() {
        // Créer des animations pour les coordonnées X et Y
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

  void _shoot(int direction) {
    if (_isShooting) return;

    setState(() {
      _isShooting = true;
      _gameState.selectedDirection = direction;
      _gameState.currentPhase = GamePhase.goalkeeeperSaving;

      // Simulate goalkeeper prediction
      _gameState.goalkeepeerDirection = _random.nextInt(3);
    });

    // Reconfigurer les animations avec la direction sélectionnée
    _setupGoalkeeperAnimation(_gameState.goalkeepeerDirection);
    _setupBallAnimation();

    // Jouer un son de tir
    AudioManager.playSound('kick');

    // Démarrer les animations
    _goalkeeperController.forward();
    _ballAnimationController.forward(from: 0.0);
  }

  void _handleShotResult() {
    if (!mounted) return;

    // Déterminer si un but est marqué
    final bool isGoalScored = _gameState.selectedDirection != _gameState.goalkeepeerDirection;

    setState(() {
      _gameState.isGoalScored = isGoalScored;
      _gameState.currentPhase = isGoalScored ? GamePhase.goalScored : GamePhase.goalSaved;

      // Enregistrer le résultat du tir
      _gameState.recordShotResult(isGoalScored);

      if (isGoalScored) {
        AudioManager.playSound('goal');
        // Acclamations de la foule après un but
        Timer(const Duration(milliseconds: 300), () {
          AudioManager.playSound('crowd_cheer');
        });
      } else {
        AudioManager.playSound('goalkeeper_save');
      }
    });

    // Vérifier si le jeu est terminé
    if (_gameState.checkWinner()) {
      // Coup de sifflet final
      Timer(const Duration(milliseconds: 1000), () {
        AudioManager.playSound('whistle');
      });

      Timer(const Duration(milliseconds: 1500), () {
        Team winner = _gameState.getWinner()!;
        Team loser = winner == _gameState.team1! ? _gameState.team2! : _gameState.team1!;
        List<bool> winnerResults = winner == _gameState.team1! ? _gameState.team1Results : _gameState.team2Results;
        List<bool> loserResults = loser == _gameState.team1! ? _gameState.team1Results : _gameState.team2Results;

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
      // Continuer au prochain tour
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

    // Vérifier si nous devons commencer un nouveau round
    // (cas où les deux équipes ont tiré dans le round actuel)
    _gameState.shouldStartNewRound();

    _gameState.switchTeam();
    _gameState.currentPhase = GamePhase.playerShooting;
    _gameState.isGoalScored = false;
    _isShooting = false;

    // Son de sifflet pour le nouveau tour
    AudioManager.playSound('whistle');
  }

  @override
  void dispose() {
    _ballAnimationController.dispose();
    _goalkeeperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Jouer un son lorsque l'utilisateur quitte l'écran
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
                  shotsPerTeam: PenaltySettings.shotsPerTeam,  // ou PenaltySettings.shotsPerTeam selon votre solution au problème précédent
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

                // Show round number
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    _gameState.isRegularPhase()
                        ? 'Tour ${_gameState.roundNumber}/${PenaltySettings.shotsPerTeam}'
                        : 'Tour de départage ${_gameState.roundNumber - PenaltySettings.shotsPerTeam}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
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
                          child: Image.asset(
                            'assets/images/players/goalkeeper.png',
                            width: 100,
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      // Ball - displayed only when shooting
                      if (_ballXAnimation != null && _ballYAnimation != null)
                        AnimatedBuilder(
                          animation: _ballAnimationController,
                          builder: (context, child) {
                            return _isShooting
                                ? Positioned(
                              left: _ballXAnimation.value - 20, // Centrer le ballon (largeur/2)
                              top: _ballYAnimation.value - 20,  // Centrer le ballon (hauteur/2)
                              child: Image.asset(
                                'assets/images/ball.png',
                                width: 40,
                                height: 40,
                              ),
                            )
                                : Container(); // Ne pas afficher le ballon si pas de tir en cours
                          },
                        ),

                      // Player
                      Positioned(
                        bottom: 20,
                        child: Image.asset(
                          'assets/images/players/striker.png',
                          width: 80,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
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
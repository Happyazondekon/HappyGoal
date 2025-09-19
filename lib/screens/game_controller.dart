// game_controller.dart - VERSION CORRIGÉE
import 'package:flutter/material.dart';
import 'package:happygoal/screens/tournament_result_screen.dart';
import 'dart:async';
import 'dart:math';
import '../constants.dart' hide ShotDirection;
import '../models/game_state.dart';
import '../utils/audio_manager.dart';
import '../utils/ad_controller.dart';
import 'result_screen.dart';

class GameController {
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

  // Callbacks pour communiquer avec le UI
  VoidCallback? onStateChanged;
  Function(Widget)? onNavigate;
  BuildContext? context;

  GameController({
    required GameState gameState,
    required TickerProvider vsync,
    this.onStateChanged,
    this.onNavigate,
    this.context,
  }) {
    _gameState = gameState;
    _initializeAnimations(vsync);
  }

  // Getters pour l'état
  GameState get gameState => _gameState;
  bool get isShooting => _isShooting;
  bool get showGoalText => _showGoalText;
  Animation<double> get ballXAnimation => _ballXAnimation;
  Animation<double> get ballYAnimation => _ballYAnimation;
  Animation<Offset> get goalkeeperAnimation => _goalkeeperAnimation;
  Animation<Offset> get goalTextAnimation => _goalTextAnimation;
  AnimationController get ballAnimationController => _ballAnimationController;

  void _initializeAnimations(TickerProvider vsync) {
    _ballAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: vsync,
    );

    _goalkeeperController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );

    _goalTextController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: vsync,
    );

    _setupAnimations();
    _setupListeners();
  }

  void _setupAnimations() {
    _setupGoalkeeperAnimation(ShotDirection.center);
    _initializeBallAnimations();
    _setupGoalTextAnimation();
  }

  void _initializeBallAnimations() {
    _ballXAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(_ballAnimationController);

    _ballYAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(_ballAnimationController);
  }

  void _setupListeners() {
    _ballAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleShotResult();
      }
    });

    _goalTextController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _showGoalText = false;
        onStateChanged?.call();
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
    if (context == null) return;

    final Size screenSize = MediaQuery.of(context!).size;
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

    double endY = 100 - (_gameState.shotPower < 50 ? 30 : 0);
    int duration = _gameState.shotPower > 70 ? 1000 : 1500;
    _ballAnimationController.duration = Duration(milliseconds: duration);

    Curve animationCurve;
    switch (_gameState.shotEffect) {
      case 'curve':
        animationCurve = Curves.easeInOutBack;
        break;
      case 'lob':
        animationCurve = Curves.easeOutCirc;
        break;
      case 'knuckle':
        animationCurve = Curves.elasticOut;
        break;
      default:
        animationCurve = Curves.easeOut;
        break;
    }

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
        curve: animationCurve,
      ),
    );
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

  Timer? _goalkeeperTimeout;

  void handleAITurn() {
    if (_gameState.isSoloMode &&
        _gameState.currentTeam == _gameState.team2 &&
        _gameState.currentPhase == GamePhase.playerShooting) {

      _gameState.currentPhase = GamePhase.humanGoalkeeping;
      onStateChanged?.call();

      Future.delayed(const Duration(milliseconds: 1500), () {
        final aiDecision = _gameState.getAIDecision();
        _executeAIShot(aiDecision);

        _goalkeeperTimeout = Timer(const Duration(seconds: 3), () {
          if (_gameState.currentPhase == GamePhase.goalkeepeerSaving) {
            setGoalkeeperDirection(ShotDirection.center);
          }
          _goalkeeperTimeout?.cancel();
        });
      });
    }
  }

  void _executeAIShot(Map<String, dynamic> aiDecision) {
    // CORRECTION: Simplifier la sauvegarde d'état
    _saveGameStateBeforeShot();

    _isShooting = true;
    _gameState.selectedDirection = aiDecision['direction'];
    _gameState.shotPower = aiDecision['power'];
    _gameState.shotEffect = aiDecision['effect'];
    _gameState.currentPhase = GamePhase.goalkeepeerSaving;

    _setupBallAnimation();

    if (_gameState.shotPower > 70) {
      AudioManager.playSound('powerful_kick');
    } else {
      AudioManager.playSound('kick');
    }

    onStateChanged?.call();
  }

  void setGoalkeeperDirection(int direction) {
    _goalkeeperTimeout?.cancel();

    if (_gameState.currentPhase == GamePhase.humanGoalkeeping ||
        _gameState.currentPhase == GamePhase.goalkeepeerSaving) {

      _gameState.goalkeepeerDirection = direction;
      _gameState.currentPhase = GamePhase.goalkeepeerSaving;

      _setupGoalkeeperAnimation(direction);
      _goalkeeperController.forward();
      _ballAnimationController.forward(from: 0.0);

      onStateChanged?.call();
    }
  }

  void shoot(int direction, int power, String effect) {
    if (_isShooting) return;

    // CORRECTION: Simplifier la sauvegarde d'état
    _saveGameStateBeforeShot();

    _isShooting = true;
    _gameState.selectedDirection = direction;
    _gameState.shotPower = power;
    _gameState.shotEffect = effect;
    _gameState.currentPhase = GamePhase.goalkeepeerSaving;
    _gameState.goalkeepeerDirection = _random.nextInt(3);

    _setupGoalkeeperAnimation(_gameState.goalkeepeerDirection);
    _setupBallAnimation();

    if (_gameState.shotPower > 70) {
      AudioManager.playSound('powerful_kick');
    } else {
      AudioManager.playSound('kick');
    }

    _goalkeeperController.forward();
    _ballAnimationController.forward(from: 0.0);

    onStateChanged?.call();
  }

  // NOUVELLE MÉTHODE: Simplifier la sauvegarde d'état
  void _saveGameStateBeforeShot() {
    // Toujours sauvegarder l'état avant un tir pour permettre le rembobinage
    _gameState.saveStateBeforeShot();
    print("💾 État sauvegardé avant le tir");
  }

  // NOUVELLE MÉTHODE: Vérifier si le rembobinage est disponible
  bool _canShowRewindPopup() {
    // Conditions pour afficher le popup de rembobinage :
    // 1. Le tir a été raté
    // 2. L'AdController permet l'utilisation d'un rembobinage
    // 3. GameState permet le rembobinage
    return !_gameState.isGoalScored &&
        AdController.instance.canUseRewind() &&
        _gameState.canRewind;
  }

  Future<bool> rewindLastShot() async {
    print("🔄 Tentative de rembobinage...");

    // Vérifier si AdController permet le rembobinage
    if (!AdController.instance.canUseRewind()) {
      print("❌ AdController refuse le rembobinage");
      return false;
    }

    // Décrémenter le compteur de rembobinages dans AdController
    if (!(await AdController.instance.decrementRewindCount())) {
      print("❌ Impossible de décrémenter le compteur de rembobinages");
      return false;
    }

    // Restaurer l'état du jeu
    bool success = _gameState.rewindToLastShot();

    if (success) {
      print("✅ Rembobinage réussi");

      // Réinitialiser les animations
      _ballAnimationController.reset();
      _goalkeeperController.reset();
      _goalTextController.reset();

      // Réinitialiser les états d'animation
      _isShooting = false;
      _showGoalText = false;

      // Annuler tout timer en cours
      _goalkeeperTimeout?.cancel();

      // Jouer un son de rembobinage
      try {
        AudioManager.playSound('rewind');
      } catch (e) {
        AudioManager.playSound('whistle');
      }

      onStateChanged?.call();
    } else {
      print("❌ Échec du rembobinage GameState");
      // Si GameState échoue, remettre le compteur AdController
      await AdController.instance.incrementRewindCount();
    }

    return success;
  }

  // MÉTHODE SIMPLIFIÉE: Afficher popup de rembobinage
  void _showRewindPopup() {
    if (context == null || !mounted(context!)) return;

    print("🎯 Affichage du popup de rembobinage");

    showDialog(
      context: context!,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.replay, color: Colors.orange, size: 28),
            SizedBox(width: 10),
            Text(
              'Tir raté !',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sports_soccer,
              size: 50,
              color: Colors.grey[600],
            ),
            SizedBox(height: 15),
            Text(
              'Voulez-vous utiliser un rembobinage pour rejouer ce tir ?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.replay, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Rembobinages: ${AdController.instance.currentRewindCount}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _continueAfterShotResult();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
            child: Text('Continuer'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              bool success = await rewindLastShot();

              if (!mounted(context!)) return;

              if (success) {
                ScaffoldMessenger.of(context!).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 10),
                        Text('Tir rembobiné ! Vous pouvez rejouer.'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context!).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error, color: Colors.white),
                        SizedBox(width: 10),
                        Text('Impossible de rembobiner.'),
                      ],
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                _continueAfterShotResult();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.replay, size: 18),
                SizedBox(width: 5),
                Text('Rembobiner'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _continueAfterShotResult() {
    Timer(const Duration(seconds: 2), () {
      // Invalider la sauvegarde après le délai d'attente
      _gameState.invalidateSnapshot();

      if (_gameState.checkWinner()) {
        if (_gameState.isTournamentMode && _gameState.tournamentState != null) {
          _handleTournamentProgress();
        } else {
          final bool isUserWinner = !_gameState.isSoloMode || _gameState.getWinner() == _gameState.team1;

          final resultScreen = ResultScreen(
            winner: _gameState.getWinner()!,
            loser: _gameState.getWinner() == _gameState.team1 ? _gameState.team2! : _gameState.team1!,
            winnerResults: _gameState.getWinner() == _gameState.team1
                ? _gameState.team1Results
                : _gameState.team2Results,
            loserResults: _gameState.getWinner() == _gameState.team1
                ? _gameState.team2Results
                : _gameState.team1Results,
            isSoloMode: _gameState.isSoloMode,
            isUserWinner: isUserWinner,
          );

          onNavigate?.call(resultScreen);
        }
      } else {
        resetRound();
      }
    });
  }

  void _handleShotResult() {
    final bool isGoalKeepDirectionMatch = _gameState.selectedDirection == _gameState.goalkeepeerDirection;

    bool isGoalScored = !isGoalKeepDirectionMatch;

    if (isGoalKeepDirectionMatch) {
      double chanceToScore = 0.0;

      if (_gameState.shotPower > 80) chanceToScore += 0.3;

      if (_gameState.shotEffect == 'curve') chanceToScore += 0.2;
      else if (_gameState.shotEffect == 'knuckle') chanceToScore += 0.25;

      if (_random.nextDouble() < chanceToScore) {
        isGoalScored = true;
      }
    }

    if (isGoalScored && _gameState.shotPower < 20 && _random.nextDouble() < 0.3) {
      isGoalScored = false;
    }

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

    onStateChanged?.call();

    // CORRECTION PRINCIPALE: Logique simplifiée pour le popup de rembobinage
    Timer(const Duration(seconds: 1), () {
      if (!mounted(context!)) return;

      print("🎯 Vérification des conditions de rembobinage:");
      print("- Tir raté: ${!_gameState.isGoalScored}");
      print("- AdController peut rembobiner: ${AdController.instance.canUseRewind()}");
      print("- GameState peut rembobiner: ${_gameState.canRewind}");

      if (_canShowRewindPopup()) {
        print("✅ Toutes les conditions sont remplies - Affichage du popup");
        _showRewindPopup();
      } else {
        print("❌ Conditions non remplies - Continuation normale");
        _continueAfterShotResult();
      }
    });
  }

  void _handleTournamentProgress() {
    final isUserWinner = _gameState.getWinner() == _gameState.team1;
    _gameState.tournamentState!.advanceToNextRound(isUserWinner);

    if (_gameState.tournamentState!.currentPhase == TournamentPhase.finished) {
      final tournamentResultScreen = TournamentResultScreen(
        userTeam: _gameState.team1!,
        userWins: _gameState.tournamentState!.userWins,
        aiWins: _gameState.tournamentState!.aiWins,
        isWinner: _gameState.tournamentState!.userWins > _gameState.tournamentState!.aiWins,
      );

      onNavigate?.call(tournamentResultScreen);
    } else {
      _gameState.team2 = _gameState.tournamentState!.currentOpponent;
      _gameState.reset();
      resetRound();

      if (context != null) {
        ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(
            content: Text(
              'Prochain match: ${_gameState.tournamentState!.getPhaseName()}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void resetRound() {
    _ballAnimationController.reset();
    _goalkeeperController.reset();

    if (!_gameState.isTournamentMode) {
      _gameState.shouldStartNewRound();
    }

    _gameState.switchTeam();
    _gameState.currentPhase = GamePhase.playerShooting;
    _gameState.isGoalScored = false;
    _isShooting = false;

    // Invalider la sauvegarde lors du changement de tour
    _gameState.invalidateSnapshot();

    AudioManager.playSound('whistle');

    onStateChanged?.call();

    // Vérifier si c'est l'IA qui doit jouer
    if (_gameState.isSoloMode && _gameState.currentTeam == _gameState.team2) {
      handleAITurn();
    }
  }

  String getResultText() {
    if (_gameState.isGoalScored) {
      if (_gameState.shotEffect == 'lob') {
        return "BUT sur LOB 🎯";
      } else if (_gameState.shotEffect == 'curve') {
        return "BUT avec EFFET 🔥";
      } else if (_gameState.shotEffect == 'knuckle') {
        return "BUT KNUCKLE ⚡";
      } else if (_gameState.shotPower < 30) {
        return "BUT faiblement tiré 💨";
      } else {
        return "BUUUUT!";
      }
    } else {
      if (_gameState.shotPower < 20) {
        return "TIR TROP FAIBLE 😢";
      } else if (_gameState.shotEffect == 'lob') {
        return "LOB raté 😔";
      } else if (_gameState.shotEffect == 'curve') {
        return "EFFET arrêté 🛡️";
      } else if (_gameState.shotEffect == 'knuckle') {
        return "KNUCKLE arrêté ❌";
      } else {
        return "ARRÊT DU GARDIEN!";
      }
    }
  }

  bool mounted(BuildContext context) {
    return context.mounted;
  }

  void dispose() {
    _ballAnimationController.dispose();
    _goalkeeperController.dispose();
    _goalTextController.dispose();
    _goalkeeperTimeout?.cancel();
  }
}
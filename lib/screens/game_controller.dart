import 'package:flutter/material.dart';
import 'package:happygoal/screens/tournament_result_screen.dart';
import 'dart:async';
import 'dart:math';
import '../constants.dart' hide ShotDirection;
import '../models/game_state.dart';
import '../utils/audio_manager.dart';
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

  void handleAITurn() {
    if (_gameState.isSoloMode &&
        _gameState.currentTeam == _gameState.team2 &&
        _gameState.currentPhase == GamePhase.playerShooting) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        final aiDecision = _gameState.getAIDecision();

        shoot(
          aiDecision['direction'],
          aiDecision['power'],
          aiDecision['effect'],
        );
      });
    }
  }

  void shoot(int direction, int power, String effect) {
    if (_isShooting) return;

    _isShooting = true;
    _gameState.selectedDirection = direction;
    _gameState.shotPower = power;
    _gameState.shotEffect = effect;
    _gameState.currentPhase = GamePhase.goalkeeeperSaving;
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

    Timer(const Duration(seconds: 2), () {
      if (_gameState.checkWinner()) {
        if (_gameState.isTournamentMode && _gameState.tournamentState != null) {
          _handleTournamentProgress();
        } else {
          // Mode normal (existant)
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
      // Passer au prochain adversaire
      _gameState.team2 = _gameState.tournamentState!.currentOpponent;
      _gameState.reset();
      resetRound();

      // Afficher un message pour le nouveau match
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
    AudioManager.playSound('whistle');

    onStateChanged?.call();

    // Vérifier si c'est l'IA qui doit jouer
    if (_gameState.isSoloMode && _gameState.currentTeam == _gameState.team2) {
      handleAITurn();
    }
  }

  // Add the missing getResultText method
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

  void dispose() {
    _ballAnimationController.dispose();
    _goalkeeperController.dispose();
    _goalTextController.dispose();
  }
}
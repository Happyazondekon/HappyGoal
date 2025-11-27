// game_controller.dart
import 'package:flutter/material.dart';
import 'package:happygoal/screens/tournament_result_screen.dart';
import 'dart:async';
import 'dart:math';
import '../constants.dart' hide ShotDirection;
import '../models/game_state.dart';
import '../stats_service.dart';
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

  // --- STATISTIQUES POUR ACHIEVEMENTS ---
  // Compteurs pour le match en cours (pour l'équipe 1 / Joueur)
  int _matchGoalsCurve = 0;
  int _matchGoalsLob = 0;
  int _matchGoalsKnuckle = 0;

  // Compteurs accumulés pour le tournoi
  int _tournamentGoalsCurve = 0;
  int _tournamentGoalsLob = 0;
  int _tournamentGoalsKnuckle = 0;

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

      final aiDecision = _gameState.getAIDecision();

      _gameState.selectedDirection = aiDecision['direction'];
      _gameState.shotPower = aiDecision['power'];
      _gameState.shotEffect = aiDecision['effect'];

      _goalkeeperTimeout = Timer(const Duration(seconds: 3), () {
        if (_gameState.currentPhase == GamePhase.humanGoalkeeping) {
          print("⏰ Timeout du gardien - Direction par défaut: centre");
          setGoalkeeperDirection(ShotDirection.center);
        }
        _goalkeeperTimeout?.cancel();
      });
    }
  }

  void setGoalkeeperDirection(int direction) {
    _goalkeeperTimeout?.cancel();

    if (_gameState.currentPhase == GamePhase.humanGoalkeeping ||
        _gameState.currentPhase == GamePhase.goalkeepeerSaving) {

      _saveGameStateBeforeShot();

      _gameState.goalkeepeerDirection = direction;
      _gameState.currentPhase = GamePhase.goalkeepeerSaving;

      _setupGoalkeeperAnimation(direction);
      _setupBallAnimation();

      if (_gameState.shotPower > 70) {
        AudioManager.playSound('powerful_kick');
      } else {
        AudioManager.playSound('kick');
      }

      _isShooting = true;
      _goalkeeperController.forward();
      _ballAnimationController.forward(from: 0.0);

      onStateChanged?.call();
    }
  }

  void shoot(int direction, int power, String effect) {
    if (_isShooting) return;

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

  void _saveGameStateBeforeShot() {
    _gameState.saveStateBeforeShot();
  }

  bool _canShowRewindPopup() {
    if (_gameState.isSoloMode && _gameState.currentTeam == _gameState.team2) {
      return false;
    }
    if (_gameState.isTournamentMode && _gameState.currentTeam == _gameState.team2) {
      return false;
    }

    return !_gameState.isGoalScored &&
        AdController.instance.canUseRewind() &&
        _gameState.canRewind;
  }

  Future<bool> rewindLastShot() async {
    print("🔄 Tentative de rembobinage...");

    if (!AdController.instance.canUseRewind()) return false;

    if (!(await AdController.instance.decrementRewindCount())) return false;

    bool success = _gameState.rewindToLastShot();

    if (success) {
      _ballAnimationController.reset();
      _goalkeeperController.reset();
      _goalTextController.reset();
      _isShooting = false;
      _showGoalText = false;
      _goalkeeperTimeout?.cancel();

      // IMPORTANT : Annuler le comptage du tir précédent si on rembobine
      // On ne décrémente pas les stats de tir car c'est compliqué de savoir quel effet c'était exactement
      // Mais comme on rejoue le tir, le nouveau tir sera compté, donc c'est acceptable.

      try {
        AudioManager.playSound('rewind');
      } catch (e) {
        AudioManager.playSound('whistle');
      }

      onStateChanged?.call();
    } else {
      await AdController.instance.incrementRewindCount();
    }

    return success;
  }

  void _showRewindPopup() {
    if (context == null || !mounted(context!)) return;

    showDialog(
      context: context!,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1B6B3A),
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1B6B3A), Color(0xFF2E8B4B), Color(0xFF0D4A2D)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.15)),
                child: const Icon(Icons.replay, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TIR RATÉ !', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Seconde chance disponible', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sports_soccer, size: 50, color: Colors.white70),
            const SizedBox(height: 14),
            Text('Utiliser un rembobinage ?\n(Restants: ${AdController.instance.currentRewindCount})',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.9))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _continueAfterShotResult();
            },
            child: const Text('Continuer', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              bool success = await rewindLastShot();
              if (success && mounted(context!)) {
                ScaffoldMessenger.of(context!).showSnackBar(const SnackBar(content: Text('Tir rembobiné !'), backgroundColor: Colors.green));
              } else {
                _continueAfterShotResult();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Rembobiner', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _continueAfterShotResult() {
    Timer(const Duration(seconds: 2), () {
      _gameState.invalidateSnapshot();

      if (_gameState.checkWinner()) {
        if (_gameState.isTournamentMode && _gameState.tournamentState != null) {
          _handleTournamentProgress();
        } else {
          final bool isUserWinner = !_gameState.isSoloMode || _gameState.getWinner() == _gameState.team1;

          // ✅ CORRECTION ICI : On passe maintenant les compteurs au ResultScreen
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
            // 👇 VOICI LES PARAMÈTRES QUI MANQUAIENT 👇
            goalsCurve: _matchGoalsCurve,
            goalsLob: _matchGoalsLob,
            goalsKnuckle: _matchGoalsKnuckle,
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

    // ⭐ SUIVI DES STATISTIQUES POUR ACHIEVEMENTS (Seulement si c'est l'équipe du joueur)
    if (isGoalScored && _gameState.currentTeam == _gameState.team1) {
      // Debug print pour vérifier si ça passe ici
      print("🎯 BUT MARQUÉ - Effet: ${_gameState.shotEffect}");

      if (_gameState.shotEffect == 'curve') {
        _matchGoalsCurve++;
        print("📈 Courbes: $_matchGoalsCurve");
      }
      else if (_gameState.shotEffect == 'lob') {
        _matchGoalsLob++;
        print("📈 Lobs: $_matchGoalsLob");
      }
      else if (_gameState.shotEffect == 'knuckle') {
        _matchGoalsKnuckle++;
        print("📈 Knuckles: $_matchGoalsKnuckle");
      }
    }

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

    Timer(const Duration(seconds: 1), () {
      if (!mounted(context!)) return;
      if (_canShowRewindPopup()) {
        _showRewindPopup();
      } else {
        _continueAfterShotResult();
      }
    });
  }

  void _handleTournamentProgress() async {
    // 1. Accumuler les stats du match vers le tournoi
    _tournamentGoalsCurve += _matchGoalsCurve;
    _tournamentGoalsLob += _matchGoalsLob;
    _tournamentGoalsKnuckle += _matchGoalsKnuckle;

    // 2. Réinitialiser les stats du match pour le suivant
    _matchGoalsCurve = 0;
    _matchGoalsLob = 0;
    _matchGoalsKnuckle = 0;

    final isUserWinner = _gameState.getWinner() == _gameState.team1;
    _gameState.tournamentState!.advanceToNextRound(isUserWinner);

    if (_gameState.tournamentState!.currentPhase == TournamentPhase.finished) {
      final statsService = StatsService();
      final tournamentStats = await statsService.loadTournamentStats();
      final totalRewindCount = AdController.instance.getUsedRewindCount();
      final totalGoalsScored = _calculateTotalGoalsScored();
      final totalShotsTaken = _calculateTotalShotsTaken();
      final totalMatchesWon = _gameState.tournamentState!.userWins;

      final tournamentResultScreen = TournamentResultScreen(
        userTeam: _gameState.team1!,
        userWins: _gameState.tournamentState!.userWins,
        aiWins: _gameState.tournamentState!.aiWins,
        isWinner: isUserWinner,
        tournamentStats: tournamentStats,
        saveStatsCallback: () async {
          await statsService.saveTournamentStats(tournamentStats);
        },
        totalRewindCount: totalRewindCount,
        totalGoalsScored: totalGoalsScored,
        totalShotsTaken: totalShotsTaken,
        totalMatchesWon: totalMatchesWon,
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

  int _calculateTotalGoalsScored() {
    int goals = 0;
    for (var result in _gameState.team1Results) {
      if (result) goals++;
    }
    for (var result in _gameState.team1SuddenDeathResults) {
      if (result) goals++;
    }
    return goals;
  }

  int _calculateTotalShotsTaken() {
    return _gameState.team1Results.length + _gameState.team1SuddenDeathResults.length;
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

    _gameState.invalidateSnapshot();

    AudioManager.playSound('whistle');

    onStateChanged?.call();

    if (_gameState.isSoloMode && _gameState.currentTeam == _gameState.team2) {
      handleAITurn();
    }
  }

  String getResultText() {
    if (_gameState.isGoalScored) {
      if (_gameState.shotEffect == 'lob') return "BUT sur LOB 🎯";
      if (_gameState.shotEffect == 'curve') return "BUT avec EFFET 🔥";
      if (_gameState.shotEffect == 'knuckle') return "BUT KNUCKLE ⚡";
      if (_gameState.shotPower < 30) return "BUT en douceur 💨";
      return "BUUUUT!";
    } else {
      if (_gameState.shotPower < 20) return "TIR TROP FAIBLE 😢";
      return "ARRÊT DU GARDIEN!";
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
// game_controller.dart - VERSION CORRIGÉE
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

      // Obtenir la décision de l'IA immédiatement
      final aiDecision = _gameState.getAIDecision();

      // Configurer le tir de l'IA
      _gameState.selectedDirection = aiDecision['direction'];
      _gameState.shotPower = aiDecision['power'];
      _gameState.shotEffect = aiDecision['effect'];

      // MODIFICATION: Timer de 3 secondes pour que l'utilisateur choisisse la direction du gardien
      _goalkeeperTimeout = Timer(const Duration(seconds: 3), () {
        // Si l'utilisateur n'a pas choisi, le gardien reste au centre par défaut
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

      // Sauvegarder l'état avant le tir de l'IA
      _saveGameStateBeforeShot();

      _gameState.goalkeepeerDirection = direction;
      _gameState.currentPhase = GamePhase.goalkeepeerSaving;

      _setupGoalkeeperAnimation(direction);
      _setupBallAnimation();

      // Jouer le son de tir en fonction de la puissance
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
    // NOUVELLE CONDITION: Ne pas afficher le popup si c'est le tour de l'IA
    if (_gameState.isSoloMode && _gameState.currentTeam == _gameState.team2) {
      print("❌ Pas de popup de rembobinage - C'est le tour de l'IA");
      return false;
    }

    // NOUVELLE CONDITION: Ne pas afficher le popup en mode tournoi si c'est l'IA
    if (_gameState.isTournamentMode && _gameState.currentTeam == _gameState.team2) {
      print("❌ Pas de popup de rembobinage - C'est le tour de l'IA en tournoi");
      return false;
    }

    // Conditions pour afficher le popup de rembobinage :
    // 1. Le tir a été raté
    // 2. L'AdController permet l'utilisation d'un rembobinage
    // 3. GameState permet le rembobinage
    // 4. Ce n'est PAS le tour de l'IA (nouvelles conditions ajoutées ci-dessus)
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
        backgroundColor: const Color(0xFF1B6B3A),
        contentPadding: const EdgeInsets.all(0),
        titlePadding: const EdgeInsets.all(0),
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1B6B3A),  // Vert moyen
                Color(0xFF2E8B4B),  // Vert clair
                Color(0xFF0D4A2D),  // Vert foncé
              ],
              stops: [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.replay,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Colors.white,
                          Color(0xFFE0E0E0),
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        'TIR RATÉ !',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.0,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 3,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Seconde chance disponible',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône football moderne avec effet
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.sports_soccer,
                  size: 30,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(width: 14),

              // Texte principal
              Text(
                'Voulez-vous utiliser un rembobinage pour rejouer ce tir ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 14),

              // Badge des rembobinages disponibles
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4CAF50),
                      Color(0xFF2E7D32),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: const Icon(
                        Icons.replay,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rembobinages: ${AdController.instance.currentRewindCount}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                // Bouton Continuer
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        _continueAfterShotResult();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        foregroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Continuer',
                        style: TextStyle(
                          fontSize: 07,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Bouton Rembobiner
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(dialogContext).pop();

                        bool success = await rewindLastShot();

                        if (!mounted(context!)) return;

                        if (success) {
                          ScaffoldMessenger.of(context!).showSnackBar(
                            SnackBar(
                              content: Container(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: const Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Tir rembobiné ! Vous pouvez rejouer.',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              backgroundColor: const Color(0xFF4CAF50),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.all(12),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context!).showSnackBar(
                            SnackBar(
                              content: Container(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: const Row(
                                  children: [
                                    Icon(Icons.error, color: Colors.white, size: 20),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Impossible de rembobiner.',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              backgroundColor: const Color(0xFFFF5722),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.all(12),
                            ),
                          );
                          _continueAfterShotResult();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.replay, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Rembobiner',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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

  void _handleTournamentProgress() async { // Ajout de async
    final isUserWinner = _gameState.getWinner() == _gameState.team1;
    _gameState.tournamentState!.advanceToNextRound(isUserWinner);

    if (_gameState.tournamentState!.currentPhase == TournamentPhase.finished) {
      // RÉCUPÉRER LES VRAIES STATISTIQUES DEPUIS LE STOCKAGE
      final statsService = StatsService();
      final tournamentStats = await statsService.loadTournamentStats(); // await ajouté
      final totalRewindCount = AdController.instance.getUsedRewindCount();
      final totalGoalsScored = _calculateTotalGoalsScored();
      final totalShotsTaken = _calculateTotalShotsTaken();
      final totalMatchesWon = _gameState.tournamentState!.userWins;

      print('🏆 FIN DU TOURNOI - Statistiques:');
      print('- Victoire: $isUserWinner');
      print('- Rewinds utilisés: $totalRewindCount');
      print('- Buts marqués: $totalGoalsScored');
      print('- Tirs effectués: $totalShotsTaken');
      print('- Matchs gagnés: $totalMatchesWon');
      print('- Stats avant enregistrement: ${tournamentStats.tournamentsPlayed} tournois joués');

      final tournamentResultScreen = TournamentResultScreen(
        userTeam: _gameState.team1!,
        userWins: _gameState.tournamentState!.userWins,
        aiWins: _gameState.tournamentState!.aiWins,
        isWinner: isUserWinner,
        tournamentStats: tournamentStats,
        saveStatsCallback: () async {
          // Sauvegarde asynchrone avec le service
          await statsService.saveTournamentStats(tournamentStats);
          print('💾 Statistiques sauvegardées: ${tournamentStats.tournamentsPlayed} tournois');
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





// AJOUTEZ CES MÉTHODES DANS GameController POUR CALCULER LES STATISTIQUES
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
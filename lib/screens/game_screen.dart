import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../constants.dart' hide ShotDirection; // Utiliser hide pour éviter le conflit
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


      // Ajuster la position finale Y en fonction de la puissance
      // Un tir avec moins de puissance sera plus haut
      double endY = 100 - (_gameState.shotPower < 50 ? 30 : 0);

      // Durée de l'animation basée sur la puissance
      int duration = _gameState.shotPower > 70 ? 1000 : 1500;
      _ballAnimationController.duration = Duration(milliseconds: duration);

      // Animation de courbe pour les effets spéciaux
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
            curve: animationCurve,
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

  void _shoot(int direction, int power, String effect) {
    if (_isShooting) return;

    setState(() {
      _isShooting = true;
      _gameState.selectedDirection = direction;
      _gameState.shotPower = power;
      _gameState.shotEffect = effect;
      _gameState.currentPhase = GamePhase.goalkeeeperSaving;
      _gameState.goalkeepeerDirection = _random.nextInt(3);
    });

    _setupGoalkeeperAnimation(_gameState.goalkeepeerDirection);
    _setupBallAnimation();

    // Jouer un son différent selon la puissance
    if (_gameState.shotPower > 70) {
      AudioManager.playSound('powerful_kick');
    } else {
      AudioManager.playSound('kick');
    }

    _goalkeeperController.forward();
    _ballAnimationController.forward(from: 0.0);
  }

  void _handleShotResult() {
    if (!mounted) return;

    // La chance de marquer est influencée par la puissance et l'effet
    final bool isGoalKeepDirectionMatch = _gameState.selectedDirection == _gameState.goalkeepeerDirection;

    // Base: Si le gardien va dans la mauvaise direction, c'est sûr que c'est but
    bool isGoalScored = !isGoalKeepDirectionMatch;

    // Même si le gardien va dans la bonne direction, un tir spécial ou puissant peut le tromper
    if (isGoalKeepDirectionMatch) {
      double chanceToScore = 0.0;

      // Tir très puissant = 30% de chance de marquer même si le gardien va dans la bonne direction
      if (_gameState.shotPower > 80) chanceToScore += 0.3;

      // Effets spéciaux augmentent la chance de marquer
      if (_gameState.shotEffect == 'curve') chanceToScore += 0.2;
      else if (_gameState.shotEffect == 'knuckle') chanceToScore += 0.25;

      // Vérifie si le tir est marqué malgré la bonne direction du gardien
      if (_random.nextDouble() < chanceToScore) {
        isGoalScored = true;
      }
    }

    // Trop faible puissance = risque de manquer même si le gardien va dans la mauvaise direction
    if (isGoalScored && _gameState.shotPower < 20 && _random.nextDouble() < 0.3) {
      isGoalScored = false; // Tir trop faible, but manqué
    }

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

    // 🔥 AJOUT pour passer automatiquement au prochain tir après 2 secondes :
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          if (_gameState.checkWinner()) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ResultScreen(
                  winner: _gameState.getWinner()!,
                  loser: _gameState.getWinner() == _gameState.team1 ? _gameState.team2! : _gameState.team1!,
                  winnerResults: _gameState.getWinner() == _gameState.team1
                      ? _gameState.team1Results
                      : _gameState.team2Results,
                  loserResults: _gameState.getWinner() == _gameState.team1
                      ? _gameState.team2Results
                      : _gameState.team1Results,
                ),
              ),
            );

          } else {
            _resetRound();
          }
        });
      }
    });
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

  String _getStatusText() {
    switch (_gameState.currentPhase) {
      case GamePhase.playerShooting:
        return "Au tour de ${_gameState.currentTeam!.name} - Choisissez une direction";
      case GamePhase.goalkeeeperSaving:
        return "Le gardien plonge...";
      case GamePhase.goalScored:
      // 🔥 Ici, personnalisation du message selon effet et puissance
        if (_gameState.shotEffect == ShotEffect.lob) {
          return "But sur LOB ! 🎯";
        } else if (_gameState.shotEffect == ShotEffect.curve) {
          return "But avec un superbe EFFET ! 🔥";
        } else if (_gameState.shotEffect == ShotEffect.knuckle) {
          return "But spectaculaire KNUCKLE ! ⚡";
        } else if (_gameState.shotPower < 30) {
          return "But malgré une faible puissance ! 💨";
        } else {
          return "But pour ${_gameState.currentTeam!.name} !";
        }
      case GamePhase.goalSaved:
      // 🔥 Ici, on précise aussi si la balle était faible ou si c'était un lob raté
        if (_gameState.shotPower < 20) {
          return "Tir trop faible ! 😢";
        } else if (_gameState.shotEffect == ShotEffect.lob) {
          return "Lob raté, le gardien capte facilement ! 🧤";
        } else if (_gameState.shotEffect == ShotEffect.curve) {
          return "Le gardien arrête le tir à effet ! 🛡️";
        } else if (_gameState.shotEffect == ShotEffect.knuckle) {
          return "Knuckle shot arrêté par le gardien ! ❌";
        } else {
          return "Arrêt du gardien !";
        }
      default:
        return "";
    }
  }
  String _getResultText() {
    if (_gameState.isGoalScored) {
      if (_gameState.shotEffect == ShotEffect.lob) {
        return "BUT sur LOB 🎯";
      } else if (_gameState.shotEffect == ShotEffect.curve) {
        return "BUT avec EFFET 🔥";
      } else if (_gameState.shotEffect == ShotEffect.knuckle) {
        return "BUT KNUCKLE ⚡";
      } else if (_gameState.shotPower < 30) {
        return "BUT faiblement tiré 💨";
      } else {
        return "BUUUUT!";
      }
    } else {
      if (_gameState.shotPower < 20) {
        return "TIR TROP FAIBLE 😢";
      } else if (_gameState.shotEffect == ShotEffect.lob) {
        return "LOB raté 😔";
      } else if (_gameState.shotEffect == ShotEffect.curve) {
        return "EFFET arrêté 🛡️";
      } else if (_gameState.shotEffect == ShotEffect.knuckle) {
        return "KNUCKLE arrêté ❌";
      } else {
        return "ARRÊT DU GARDIEN!";
      }
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
                            if (!_isShooting) return Container();

                            // Variables pour l'animation d'effet
                            double ballSize = 40.0;
                            double rotation = 0.0;
                            List<Widget> effectWidgets = [];

                            // Adapter la taille du ballon selon la puissance
                            if (_gameState.shotPower > 70) {
                              ballSize = 45.0; // Ballon légèrement plus gros pour un tir puissant
                            }

                            // Animation de rotation pour l'effet "curve"
                            if (_gameState.shotEffect == 'curve') {
                              rotation = _ballAnimationController.value * 2 * 3.14159;
                            }

                            // Effet visuel pour knuckle (oscillation aléatoire)
                            if (_gameState.shotEffect == 'knuckle' && _ballAnimationController.value > 0.2) {
                              double offsetX = sin(_ballAnimationController.value * 10) * 5;
                              double offsetY = cos(_ballAnimationController.value * 8) * 5;

                              // Ajouter un effet de trainée pour le knuckle ball
                              for (int i = 1; i <= 3; i++) {
                                double opacity = (1 - i * 0.25).clamp(0.1, 0.7);
                                effectWidgets.add(
                                  Positioned(
                                    left: _ballXAnimation.value - 20 - offsetX * i * 0.5,
                                    top: _ballYAnimation.value - 20 - offsetY * i * 0.5,
                                    child: Opacity(
                                      opacity: opacity,
                                      child: Image.asset(
                                        'assets/images/ball.png',
                                        width: ballSize - i * 2,
                                        height: ballSize - i * 2,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            }

                            // Effet visuel pour lob (trajectoire plus haute)
                            if (_gameState.shotEffect == 'lob') {
                              // Ajouter une ombre au sol pour indiquer la trajectoire haute
                              effectWidgets.add(
                                Positioned(
                                  left: _ballXAnimation.value - 15,
                                  bottom: 100,
                                  child: Opacity(
                                    opacity: (1 - _ballAnimationController.value).clamp(0.0, 0.5),
                                    child: Container(
                                      width: 30,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }

                            // Effet visuel pour tir puissant (trainée de feu)
                            if (_gameState.shotPower > 80) {
                              for (int i = 1; i <= 5; i++) {
                                double opacity = (1 - i * 0.15).clamp(0.1, 0.7);
                                effectWidgets.add(
                                  Positioned(
                                    left: _ballXAnimation.value - 20 - ((_ballXAnimation.value -
                                        (MediaQuery.of(context).size.width / 2)) / 10) * i,
                                    top: _ballYAnimation.value - 20 + 2 * i,
                                    child: Opacity(
                                      opacity: opacity,
                                      child: Container(
                                        width: ballSize - i * 3,
                                        height: ballSize - i * 3,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              Colors.orange,
                                              Colors.red.withOpacity(0.5),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            }

                            // Ajouter le ballon principal (avec rotation si effet curve)
                            effectWidgets.add(
                              Positioned(
                                left: _ballXAnimation.value - ballSize/2,
                                top: _ballYAnimation.value - ballSize/2,
                                child: Transform.rotate(
                                  angle: rotation,
                                  child: Image.asset(
                                    'assets/images/ball.png',
                                    width: ballSize,
                                    height: ballSize,
                                  ),
                                ),
                              ),
                            );

                            return Stack(children: effectWidgets);
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
                  ShotControllerWidget(
                    onShoot: (direction, power, effect) => _shoot(direction, power, effect),
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
                      _getResultText(),
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
}
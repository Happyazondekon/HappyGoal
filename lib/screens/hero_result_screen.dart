import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:happygoal/models/game_state.dart';
import 'package:happygoal/models/team.dart';
import 'package:happygoal/models/hero_challenge.dart';
import 'package:happygoal/services/hero_challenge_evaluator.dart';

class HeroResultScreen extends StatefulWidget {
  final Team myTeam;
  final Team opponent;
  final int level;
  final int starsWon;
  final VoidCallback onReplay;
  final VoidCallback onNextLevel;

  /// Le GameState complet du match joué.
  /// On l'utilise pour évaluer chaque challenge de façon stricte
  /// à partir des vrais événements (tirs, effets, arrêts...).
  final GameState gameState;

  const HeroResultScreen({
    Key? key,
    required this.myTeam,
    required this.opponent,
    required this.level,
    required this.starsWon,
    required this.onReplay,
    required this.onNextLevel,
    required this.gameState,
  }) : super(key: key);

  @override
  State<HeroResultScreen> createState() => _HeroResultScreenState();
}

class _HeroResultScreenState extends State<HeroResultScreen>
    with TickerProviderStateMixin {
  List<HeroChallenge> _challenges = [];

  /// Résultat d'évaluation RÉEL de chaque challenge,
  /// calculé à partir du GameState (team1ShotData, team2ShotData, etc.)
  /// et non depuis starsWon.
  List<bool> _completed = [];

  late ConfettiController _confettiController;
  late AnimationController _headerController;
  late AnimationController _starsController;
  late AnimationController _cardsController;
  late AnimationController _buttonController;
  late AnimationController _glowController;

  late Animation<double> _headerScale;
  late Animation<double> _glowAnim;

  final List<AnimationController> _starControllers = [];

  bool get _isVictory => widget.starsWon > 0;

  @override
  void initState() {
    super.initState();
    _evaluateChallenges();

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _headerController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _starsController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _cardsController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _buttonController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _glowController =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);

    _headerScale = CurvedAnimation(
        parent: _headerController, curve: Curves.easeOutBack);
    _glowAnim = Tween<double>(begin: 0.5, end: 1.0).animate(_glowController);

    for (int i = 0; i < 3; i++) {
      final ctrl = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 400));
      _starControllers.add(ctrl);
    }

    _runAnimationSequence();
  }

  /// Évalue chaque challenge en interrogeant le GameState réel.
  /// C'est ici que tout est vérifié : effets des tirs, arrêts, victoire, etc.
  void _evaluateChallenges() {
    _challenges = HeroChallengeRepository.getChallenges()[widget.level] ?? [];

    // Évaluation stricte : on appelle isCompleted(gameState) pour chaque challenge.
    // isCompleted interroge team1ShotData (tirs du joueur) et team2ShotData (tirs de l'IA)
    // tels qu'ils ont réellement été enregistrés pendant le match.
    _completed =
        HeroChallengeEvaluator.evaluateAll(widget.level, widget.gameState);

    // Sanity check : si _completed est plus court que _challenges, on complète avec false.
    while (_completed.length < _challenges.length) {
      _completed.add(false);
    }
  }

  void _runAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _headerController.forward();

    if (_isVictory) {
      await Future.delayed(const Duration(milliseconds: 300));
      _confettiController.play();
    }

    await Future.delayed(const Duration(milliseconds: 500));
    _starsController.forward();

    // On anime les étoiles dans l'ordre des challenges réellement complétés
    int animatedStars = 0;
    for (int i = 0; i < _completed.length && animatedStars < 3; i++) {
      if (_completed[i]) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (animatedStars < _starControllers.length) {
          _starControllers[animatedStars].forward();
        }
        animatedStars++;
      }
    }

    await Future.delayed(const Duration(milliseconds: 300));
    _cardsController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _buttonController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _headerController.dispose();
    _starsController.dispose();
    _cardsController.dispose();
    _buttonController.dispose();
    _glowController.dispose();
    for (var ctrl in _starControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  /// Nombre réel d'étoiles gagnées, compté depuis les vrais résultats.
  int get _realStarsCount => _completed.where((b) => b).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.8,
                colors: _isVictory
                    ? [
                  const Color(0xFF1A3A22),
                  const Color(0xFF0A1A0F),
                  const Color(0xFF050D07),
                ]
                    : [
                  const Color(0xFF2A1A1A),
                  const Color(0xFF150A0A),
                  const Color(0xFF0D0505),
                ],
              ),
            ),
          ),

          // Animated glow
          if (_isVictory)
            AnimatedBuilder(
              animation: _glowAnim,
              builder: (context, _) {
                return Center(
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFFFD700)
                              .withOpacity(0.06 * _glowAnim.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  ScaleTransition(
                    scale: _headerScale,
                    child: _buildResultHeader(),
                  ),

                  const SizedBox(height: 32),

                  FadeTransition(
                    opacity: _starsController,
                    child: _buildStarsRow(),
                  ),

                  const SizedBox(height: 28),

                  FadeTransition(
                    opacity: _cardsController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(_cardsController),
                      child: _buildTeamsFaceoff(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Challenges avec résultats RÉELS
                  FadeTransition(
                    opacity: _cardsController,
                    child: _buildChallengesCard(),
                  ),

                  const SizedBox(height: 16),

                  // Stats du match
                  FadeTransition(
                    opacity: _cardsController,
                    child: _buildMatchStatsCard(),
                  ),

                  const SizedBox(height: 32),

                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _buttonController,
                      curve: Curves.easeOutBack,
                    ),
                    child: _buildActionButtons(),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Confetti
          if (_isVictory)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                numberOfParticles: 30,
                colors: const [
                  Color(0xFFFFD700),
                  Colors.white,
                  Color(0xFF4CAF50),
                  Color(0xFF2196F3),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Text(
            'CHAPITRE ${widget.level}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white54,
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: _isVictory
                ? [
              const Color(0xFFFFD700),
              Colors.white,
              const Color(0xFFFFD700)
            ]
                : [
              Colors.grey.shade400,
              Colors.white70,
              Colors.grey.shade400
            ],
          ).createShader(bounds),
          child: Text(
            _isVictory ? 'VICTOIRE !' : 'DÉFAITE',
            style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 3,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isVictory
              ? 'Excellent ! Continuez votre aventure'
              : 'Pas de panique, réessayez !',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  /// Étoiles basées sur _realStarsCount — les challenges VRAIMENT complétés.
  Widget _buildStarsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final earned = i < _realStarsCount;
        return AnimatedBuilder(
          animation: i < _starControllers.length
              ? _starControllers[i]
              : const AlwaysStoppedAnimation(1.0),
          builder: (context, _) {
            final ctrl = i < _starControllers.length
                ? _starControllers[i]
                : const AlwaysStoppedAnimation(1.0);
            final value = ctrl is AnimationController ? ctrl.value : 1.0;
            return Transform.scale(
              scale: earned ? (1.0 + 0.3 * (1.0 - value).abs()) : 1.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  earned ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: earned ? 56 : 46,
                  color: earned
                      ? const Color(0xFFFFD700)
                      : Colors.white.withOpacity(0.2),
                  shadows: earned
                      ? [
                    Shadow(
                      color: const Color(0xFFFFD700).withOpacity(0.6),
                      blurRadius: 16,
                    )
                  ]
                      : [],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildTeamsFaceoff() {
    // Score réel extrait de GameState
    final int goalsScored =
        widget.gameState.team1ShotData.where((s) => s.isGoal).length;
    final int goalsConceded =
        widget.gameState.team2ShotData.where((s) => s.isGoal).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTeamInfo(widget.myTeam, 'VOUS'),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDC143C), Color(0xFF8B0000)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$goalsScored - $goalsConceded',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Niveau ${widget.level}',
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
            _buildTeamInfo(widget.opponent, 'ADV.'),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamInfo(Team team, String label) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            team.flagImage,
            width: 80,
            height: 54,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          team.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(
                color: Colors.white54, fontSize: 10, letterSpacing: 1),
          ),
        ),
      ],
    );
  }

  /// Carte challenges avec évaluation RÉELLE.
  /// Chaque challenge affiche son titre, sa description,
  /// et son statut calculé depuis le GameState.
  Widget _buildChallengesCard() {
    if (_challenges.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.flag_outlined, color: Color(0xFFFFD700), size: 16),
                SizedBox(width: 8),
                Text(
                  'OBJECTIFS',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...List.generate(_challenges.length, (i) {
              final bool done = i < _completed.length && _completed[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      done ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: done ? const Color(0xFFFFD700) : Colors.white24,
                      size: 24,
                      shadows: done
                          ? [
                        const Shadow(
                            color: Color(0xFFFFD700), blurRadius: 8)
                      ]
                          : [],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _challenges[i].title,
                            style: TextStyle(
                              color: done ? Colors.white : Colors.white38,
                              fontSize: 14,
                              fontWeight:
                              done ? FontWeight.w600 : FontWeight.normal,
                              decoration:
                              !done ? TextDecoration.lineThrough : null,
                              decorationColor: Colors.white24,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _challenges[i].description,
                            style: TextStyle(
                              color:
                              done ? Colors.white54 : Colors.white24,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      done ? Icons.check_circle : Icons.cancel_outlined,
                      color: done
                          ? const Color(0xFF4CAF50)
                          : Colors.white24,
                      size: 18,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Stats réelles du match pour aider le joueur à comprendre ses résultats.
  Widget _buildMatchStatsCard() {
    final state = widget.gameState;
    final int totalGoals =
        state.team1ShotData.where((s) => s.isGoal).length;
    final int totalShots = state.team1ShotData.length;
    final int saves = HeroChallengeEvaluator.countSaves(state);
    final int goalsConceded =
    HeroChallengeEvaluator.countGoalsConceded(state);

    // Buts par effet — seulement ceux > 0
    final List<Widget> effectRows = [];
    for (final effect in ShotEffect.getAllEffects()) {
      final int count =
      HeroChallengeEvaluator.countGoalsWithEffect(state, effect);
      if (count > 0) {
        effectRows.add(_statRow(
          'Buts ${ShotEffect.getDisplayName(effect)}',
          '$count',
          highlight: true,
        ));
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.white38, size: 14),
                SizedBox(width: 8),
                Text(
                  'STATS DU MATCH',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _statRow('Tirs tentés', '$totalShots'),
            _statRow('Buts marqués', '$totalGoals'),
            _statRow('Arrêts réalisés', '$saves'),
            _statRow('Buts encaissés', '$goalsConceded'),
            if (effectRows.isNotEmpty) ...[
              const Divider(color: Colors.white12, height: 16),
              ...effectRows,
            ],
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: highlight ? Colors.white60 : Colors.white38,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color:
              highlight ? const Color(0xFFFFD700) : Colors.white54,
              fontSize: 12,
              fontWeight:
              highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildButton(
              label: 'REJOUER',
              icon: Icons.refresh_rounded,
              gradient: const [Color(0xFF546E7A), Color(0xFF37474F)],
              onTap: widget.onReplay,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 2,
            child: _buildButton(
              label: _isVictory ? 'NIVEAU SUIVANT' : 'RETOUR',
              icon: _isVictory
                  ? Icons.arrow_forward_rounded
                  : Icons.home_rounded,
              gradient: _isVictory
                  ? [const Color(0xFFFFD700), const Color(0xFFF57F17)]
                  : [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
              onTap: widget.onNextLevel,
              isPrimary: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: isPrimary ? 13 : 12,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
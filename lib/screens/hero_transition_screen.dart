import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:happygoal/models/team.dart';
import 'package:happygoal/models/hero_challenge.dart';

class HeroTransitionScreen extends StatefulWidget {
  final Team myTeam;
  final Team opponent;
  final int level;

  /// Liste des challenges réellement complétés lors du DERNIER passage sur ce niveau.
  /// completedChallenges[i] == true signifie que le challenge i a été validé.
  /// Liste vide = première fois sur ce niveau (aucun historique).
  final List<bool> completedChallenges;

  final VoidCallback onContinue;

  const HeroTransitionScreen({
    Key? key,
    required this.myTeam,
    required this.opponent,
    required this.level,
    required this.completedChallenges,
    required this.onContinue,
  }) : super(key: key);

  @override
  State<HeroTransitionScreen> createState() => _HeroTransitionScreenState();
}

class _HeroTransitionScreenState extends State<HeroTransitionScreen>
    with TickerProviderStateMixin {
  late AnimationController _revealController;
  late AnimationController _vsController;
  late AnimationController _challengeController;
  late AnimationController _buttonController;
  late AnimationController _glowController;

  late Animation<double> _revealAnimation;
  late Animation<double> _vsScale;
  late Animation<double> _vsRotate;
  late Animation<double> _glowAnimation;
  late Animation<Offset> _leftSlide;
  late Animation<Offset> _rightSlide;

  @override
  void initState() {
    super.initState();

    _revealController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _vsController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _challengeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _buttonController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _glowController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);

    _revealAnimation = CurvedAnimation(
        parent: _revealController, curve: Curves.easeOut);
    _vsScale = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _vsController, curve: Curves.elasticOut));
    _vsRotate = Tween<double>(begin: -0.5, end: 0.0)
        .animate(CurvedAnimation(parent: _vsController, curve: Curves.easeOut));
    _glowAnimation =
        Tween<double>(begin: 0.5, end: 1.0).animate(_glowController);
    _leftSlide = Tween<Offset>(
        begin: const Offset(-1.5, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _revealController, curve: Curves.easeOut));
    _rightSlide = Tween<Offset>(
        begin: const Offset(1.5, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _revealController, curve: Curves.easeOut));

    _startSequence();
  }

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _revealController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _vsController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _challengeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _buttonController.forward();
  }

  @override
  void dispose() {
    _revealController.dispose();
    _vsController.dispose();
    _challengeController.dispose();
    _buttonController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<HeroChallenge> challenges =
        HeroChallengeRepository.getChallenges()[widget.level] ?? [];

    return Scaffold(
      body: Stack(
        children: [
          // Deep dark background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5,
                colors: [
                  Color(0xFF1A2F1F),
                  Color(0xFF0A1A0F),
                  Color(0xFF050D07),
                ],
              ),
            ),
          ),

          // Spotlight effect
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, _) {
              return Center(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.04 * _glowAnimation.value),
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
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Chapter badge
                FadeTransition(
                  opacity: _revealAnimation,
                  child: _buildChapterBadge(),
                ),

                const SizedBox(height: 32),

                // VS Section
                Expanded(
                  child: _buildVSSection(),
                ),

                // Story text
                FadeTransition(
                  opacity: _challengeController,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(_challengeController),
                    child: _buildStorySection(),
                  ),
                ),

                const SizedBox(height: 16),

                // Affiche les objectifs seulement si le joueur a déjà joué ce niveau
                if (widget.completedChallenges.isNotEmpty && challenges.isNotEmpty)
                  FadeTransition(
                    opacity: _challengeController,
                    child: _buildChallengesSection(challenges),
                  ),

                const SizedBox(height: 24),

                // Start button
                ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _buttonController,
                    curve: Curves.easeOutBack,
                  ),
                  child: _buildStartButton(),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFF57F17)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            'CHAPITRE ${widget.level}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.star, color: Colors.white, size: 18),
        ],
      ),
    );
  }

  Widget _buildVSSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // My team
        SlideTransition(
          position: _leftSlide,
          child: _buildTeamCard(widget.myTeam, true),
        ),

        // VS badge
        ScaleTransition(
          scale: _vsScale,
          child: RotationTransition(
            turns: _vsRotate,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFDC143C), Color(0xFF8B0000)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFDC143C).withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Text(
                'VS',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),

        // Opponent
        SlideTransition(
          position: _rightSlide,
          child: _buildTeamCard(widget.opponent, false),
        ),
      ],
    );
  }

  Widget _buildTeamCard(Team team, bool isMine) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Flag with glow
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (isMine
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF2196F3))
                        .withOpacity(0.4 * _glowAnimation.value),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: child,
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              team.flagImage,
              width: 100,
              height: 66,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white24),
          ),
          child: Text(
            team.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ),
        if (isMine) ...[
          const SizedBox(height: 6),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: const Color(0xFF4CAF50).withOpacity(0.5)),
            ),
            child: const Text(
              'VOUS',
              style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStorySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Text(
          _getStory(widget.level, widget.myTeam, widget.opponent),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.5,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildChallengesSection(List<HeroChallenge> challenges) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: Color(0xFFFFD700), size: 14),
                SizedBox(width: 6),
                Text(
                  'VOTRE MEILLEUR RÉSULTAT',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...List.generate(challenges.length, (i) {
              // On lit le vrai résultat du challenge i depuis completedChallenges.
              // Si completedChallenges est plus court (ne devrait pas arriver), on considère false.
              final bool done = i < widget.completedChallenges.length
                  ? widget.completedChallenges[i]
                  : false;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      done ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: done
                          ? const Color(0xFFFFD700)
                          : Colors.white24,
                      size: 20,
                      shadows: done
                          ? [
                        const Shadow(
                            color: Color(0xFFFFD700), blurRadius: 6)
                      ]
                          : [],
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        challenges[i].title,
                        style: TextStyle(
                          color: done ? Colors.white : Colors.white38,
                          fontSize: 13,
                          fontWeight:
                          done ? FontWeight.w600 : FontWeight.normal,
                          decoration:
                          !done ? TextDecoration.lineThrough : null,
                          decorationColor: Colors.white24,
                        ),
                      ),
                    ),
                    if (done)
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Icon(Icons.check_circle,
                            color: Color(0xFF4CAF50), size: 14),
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

  Widget _buildStartButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: widget.onContinue,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18)),
            elevation: 0,
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFF57F17)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'COMMENCER LE MATCH',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getStory(int level, Team myTeam, Team opponent) {
    if (level == 1) {
      return "L'aventure commence ! Tu représentes ${myTeam.name} et ton premier adversaire est ${opponent.name}. Montre ton talent !";
    } else if (level == 100) {
      return "Le défi ultime ! Après un parcours légendaire, tu affrontes ${opponent.name} pour la gloire éternelle.";
    } else {
      return "Niveau $level : ${myTeam.name} affronte ${opponent.name} dans un duel décisif. Prouve ta valeur !";
    }
  }
}
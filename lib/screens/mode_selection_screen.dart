import 'package:flutter/material.dart';
import 'package:happygoal/l10n/app_localizations.dart';
import 'package:happygoal/screens/tournament_mode_screen.dart';
import 'package:happygoal/constants.dart';
import 'package:happygoal/utils/responsive_helper.dart';
import 'dart:math' as math;
import 'home_screen.dart';
import 'team_selection_screen.dart';
import 'package:happygoal/utils/audio_manager.dart';
import 'hero_mode_screen.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({Key? key}) : super(key: key);

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  final List<_ModeCardData> _modes = [];

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnim =
        Tween<double>(begin: 0.5, end: 1.0).animate(_glowController);
  }

  @override
  void dispose() {
    _entryController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Fond sombre cohérent avec Hero screens ───────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary, AppColors.fieldGreen, Color(0xFF0F4A2D)],
                stops: [0.0, 0.5, 1.0],

              ),
            ),
          ),

          // ── Spotlight animé ───────────────────────────────────────────
          AnimatedBuilder(
            animation: _glowAnim,
            builder: (context, _) {
              return Center(
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white
                            .withOpacity(0.03 * _glowAnim.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // ── Terrain décoratif ─────────────────────────────────────────
          CustomPaint(
            size: Size.infinite,
            painter: _ModeFieldPainter(),
          ),

          // ── Contenu ───────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── HEADER ──────────────────────────────────────────────
                _buildHeader(context),

                SizedBox(height: ResponsiveHelper.scale(context, 8)),

                // ── MODE CARDS ───────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.scale(context, 20)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAnimatedModeCard(
                          context,
                          index: 0,
                          icon: Icons.star_rounded,
                          title: AppLocalizations.of(context)!.modeHeroTitle,
                          subtitle:
                          AppLocalizations.of(context)!.modeHeroSubtitle,
                          gradientColors: const [
                            Color(0xFFFFD700),
                            Color(0xFFF57F17)
                          ],
                          accentColor: const Color(0xFFFFD700),
                          badge: AppLocalizations.of(context)!.modeHeroTitle,
                          onTap: () {
                            AudioManager.playSound('click');
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, _) =>
                                    SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(1.0, 0.0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: HeroModeScreen(),
                                    ),
                                transitionDuration:
                                const Duration(milliseconds: 300),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: ResponsiveHelper.scale(context, 14)),

                        _buildAnimatedModeCard(
                          context,
                          index: 1,
                          icon: Icons.people_rounded,
                          title: AppLocalizations.of(context)!
                              .modeMultiplayerTitle,
                          subtitle: AppLocalizations.of(context)!
                              .modeMultiplayerSubtitle,
                          gradientColors: const [
                            Color(0xFF2196F3),
                            Color(0xFF1565C0)
                          ],
                          accentColor: const Color(0xFF2196F3),
                          onTap: () {
                            AudioManager.playSound('click');
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, _) =>
                                    SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(1.0, 0.0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: const TeamSelectionScreen(
                                          isSoloMode: false),
                                    ),
                                transitionDuration:
                                const Duration(milliseconds: 300),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: ResponsiveHelper.scale(context, 14)),

                        _buildAnimatedModeCard(
                          context,
                          index: 2,
                          icon: Icons.emoji_events_rounded,
                          title: AppLocalizations.of(context)!
                              .modeTournamentTitle,
                          subtitle: AppLocalizations.of(context)!
                              .modeTournamentSubtitle,
                          gradientColors: const [
                            Color(0xFFDC143C),
                            Color(0xFF8B0000)
                          ],
                          accentColor: const Color(0xFFDC143C),
                          onTap: () {
                            AudioManager.playSound('click');
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, _) =>
                                    SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(1.0, 0.0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: const TournamentModeScreen(),
                                    ),
                                transitionDuration:
                                const Duration(milliseconds: 300),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // ── BOUTON RETOUR ────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    ResponsiveHelper.scale(context, 20),
                    ResponsiveHelper.scale(context, 8),
                    ResponsiveHelper.scale(context, 20),
                    ResponsiveHelper.scale(context, 24),
                  ),
                  child: _buildBackButton(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return FadeTransition(
      opacity:
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          ResponsiveHelper.scale(context, 20),
          ResponsiveHelper.scale(context, 20),
          ResponsiveHelper.scale(context, 20),
          0,
        ),
        child: Column(
          children: [
            // Badge chapitre style Hero
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.scale(context, 20),
                vertical: ResponsiveHelper.scale(context, 8),
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sports_soccer,
                    color: const Color(0xFF4CAF50),
                    size: ResponsiveHelper.scale(context, 16),
                  ),
                  SizedBox(width: ResponsiveHelper.scale(context, 8)),
                  Text(
                    AppLocalizations.of(context)!.modeSelectionTitle,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.textScale(context, 13),
                      color: Colors.white70,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ResponsiveHelper.scale(context, 12)),

            // Titre principal
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFFFD700), Colors.white, Color(0xFFFFD700)],
              ).createShader(bounds),
              child: Text(
                AppLocalizations.of(context)!.modeSelectionSubtitle,
                style: TextStyle(
                  fontSize: ResponsiveHelper.textScale(context, 28),
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedModeCard(
      BuildContext context, {
        required int index,
        required IconData icon,
        required String title,
        required String subtitle,
        required List<Color> gradientColors,
        required Color accentColor,
        required VoidCallback onTap,
        String? badge,
      }) {
    final delay = 200 + index * 150;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: delay + 500),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(60 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: _buildModeCard(
        context,
        icon: icon,
        title: title,
        subtitle: subtitle,
        gradientColors: gradientColors,
        accentColor: accentColor,
        badge: badge,
        onTap: onTap,
      ),
    );
  }

  Widget _buildModeCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required List<Color> gradientColors,
        required Color accentColor,
        required VoidCallback onTap,
        String? badge,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(ResponsiveHelper.scale(context, 18)),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(ResponsiveHelper.scale(context, 20)),
          border: Border.all(
              color: accentColor.withOpacity(0.25),
              width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icône dans un cercle dégradé
            Container(
              width: ResponsiveHelper.scale(context, 60),
              height: ResponsiveHelper.scale(context, 60),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: gradientColors.first.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: ResponsiveHelper.scale(context, 28),
                shadows: const [Shadow(color: Colors.black26, blurRadius: 8)],
              ),
            ),

            SizedBox(width: ResponsiveHelper.scale(context, 16)),

            // Textes
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.textScale(context, 18),
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (badge != null) ...[
                        SizedBox(width: ResponsiveHelper.scale(context, 8)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.scale(context, 6),
                            vertical: ResponsiveHelper.scale(context, 2),
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: gradientColors),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '★',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ResponsiveHelper.textScale(context, 10),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: ResponsiveHelper.scale(context, 4)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.textScale(context, 13),
                      color: Colors.white.withOpacity(0.5),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: ResponsiveHelper.scale(context, 10)),

            // Flèche
            Container(
              width: ResponsiveHelper.scale(context, 36),
              height: ResponsiveHelper.scale(context, 36),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                    color: accentColor.withOpacity(0.3), width: 1),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: accentColor,
                size: ResponsiveHelper.scale(context, 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AudioManager.playSound('click');
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, _) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: const HomeScreen(),
            ),
            transitionDuration: const Duration(milliseconds: 300),
          ),
              (route) => false,
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.scale(context, 14),
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius:
          BorderRadius.circular(ResponsiveHelper.scale(context, 16)),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_back_rounded,
              color: Colors.white60,
              size: ResponsiveHelper.scale(context, 20),
            ),
            SizedBox(width: ResponsiveHelper.scale(context, 10)),
            Text(
              AppLocalizations.of(context)!.modeBack,
              style: TextStyle(
                fontSize: ResponsiveHelper.textScale(context, 15),
                fontWeight: FontWeight.w600,
                color: Colors.white60,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Painter décoration terrain ────────────────────────────────────────────────

class _ModeFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Grand cercle en bas
    canvas.drawCircle(
        Offset(size.width / 2, size.height * 0.9), size.width * 0.28, paint);

    // Lignes diagonales légères
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(size.width * 0.2 * i, 0),
        Offset(size.width * 0.2 * i + 60, size.height * 0.3),
        paint..color = Colors.white.withOpacity(0.015),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Floating particle widget gardé pour compatibilité si utilisé ailleurs
class FloatingParticle extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const FloatingParticle({
    Key? key,
    required this.size,
    required this.color,
    required this.duration,
  }) : super(key: key);

  @override
  State<FloatingParticle> createState() => _FloatingParticleState();
}

class _FloatingParticleState extends State<FloatingParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -30),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}

class _ModeCardData {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final Color accentColor;
  final VoidCallback onTap;

  _ModeCardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.accentColor,
    required this.onTap,
  });
}
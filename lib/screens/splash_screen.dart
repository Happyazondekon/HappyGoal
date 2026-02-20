import 'package:flutter/material.dart';
import 'package:happygoal/l10n/app_localizations.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:io' show Platform;
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:happygoal/constants.dart';
import 'package:happygoal/utils/responsive_helper.dart';
import 'home_screen.dart';
import 'package:happygoal/utils/remote_config_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Contrôleurs d'animation
  late AnimationController _ballController;
  late AnimationController _titleController;
  late AnimationController _progressController;
  late AnimationController _glowController;
  late AnimationController _particleController;

  // Animations balle
  late Animation<double> _ballScale;
  late Animation<double> _ballRotate;
  late Animation<double> _ballFloat;

  // Animations titre
  late Animation<double> _titleOpacity;
  late Animation<double> _titleSlide;

  // Animations progression
  late Animation<double> _progressValue;
  late Animation<double> _progressFade;

  // Glow
  late Animation<double> _glowAnim;

  // Particules
  List<_SplashParticle> _particles = [];

  @override
  void initState() {
    super.initState();

    _ballController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // ── Animations balle ──────────────────────────────────────────────
    _ballScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ballController,
        curve: const Interval(0.0, 0.65, curve: Curves.elasticOut),
      ),
    );
    _ballRotate = Tween<double>(begin: -0.3, end: 0.0).animate(
      CurvedAnimation(
        parent: _ballController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _ballFloat = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // ── Animations titre ──────────────────────────────────────────────
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // ── Animations progression ────────────────────────────────────────
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );
    _progressFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // ── Glow ──────────────────────────────────────────────────────────
    _glowAnim = Tween<double>(begin: 0.5, end: 1.0).animate(_glowController);

    _startSequence();
    _checkAppVersion();
  }

  void _startSequence() async {
    // Génère les particules
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final size = MediaQuery.of(context).size;
        setState(() {
          _particles = List.generate(
              35, (_) => _SplashParticle(size.width, size.height));
        });
      }
    });

    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _ballController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _titleController.forward();

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    _progressController.forward();
  }

  // ── Logique Kill Switch ───────────────────────────────────────────────────

  Future<void> _checkAppVersion() async {
    await RemoteConfigService().initialize();
    bool mustUpdate = await RemoteConfigService().isUpdateRequired();
    if (mustUpdate) {
      if (mounted) _showBlockingUpdateDialog();
    } else {
      await _checkForInAppUpdate();
    }
  }

  void _showBlockingUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A3A22), Color(0xFF0A1A0F)],
              ),
              borderRadius: BorderRadius.circular(24),
              border:
              Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFF57F17)]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.4),
                          blurRadius: 20),
                    ],
                  ),
                  child: const Icon(Icons.system_update_rounded,
                      color: Colors.white, size: 32),
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.splashRequiredUpdateTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.splashRequiredUpdateContent,
                  style: const TextStyle(color: Colors.white60, fontSize: 14, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _launchStore,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFF57F17)]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          AppLocalizations.of(context)!
                              .splashRequiredUpdateButton,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
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

  void _launchStore() {
    const appId = 'com.heyhappy.happygoal';
    try {
      launchUrl(
        Uri.parse("market://details?id=$appId"),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      launchUrl(
        Uri.parse(
            "https://play.google.com/store/apps/details?id=$appId"),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Future<void> _checkForInAppUpdate() async {
    try {
      if (Platform.isAndroid) {
        AppUpdateInfo info = await InAppUpdate.checkForUpdate();
        if (info.updateAvailability == UpdateAvailability.updateAvailable) {
          await InAppUpdate.performImmediateUpdate();
        }
      }
    } catch (e) {
      print("Erreur InAppUpdate (non bloquant): $e");
    } finally {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, _) => FadeTransition(
              opacity: animation,
              child: const HomeScreen(),
            ),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _ballController.dispose();
    _titleController.dispose();
    _progressController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Fond dégradé sombre cohérent ─────────────────────────────
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

          // ── Lignes de terrain ─────────────────────────────────────────
          CustomPaint(
            size: Size(size.width, size.height),
            painter: _SplashFieldPainter(),
          ),

          // ── Particules flottantes ────────────────────────────────────
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, _) {
              return CustomPaint(
                size: Size(size.width, size.height),
                painter: _SplashParticlePainter(
                  progress: _particleController.value,
                  particles: _particles,
                ),
              );
            },
          ),

          // ── Spotlight central animé ──────────────────────────────────
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
                        const Color(0xFF4CAF50)
                            .withOpacity(0.06 * _glowAnim.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // ── Contenu central ───────────────────────────────────────────
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── BALLON ───────────────────────────────────────────────
                AnimatedBuilder(
                  animation:
                  Listenable.merge([_ballController, _glowController]),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _ballFloat.value * 0.6),
                      child: Transform.scale(
                        scale: _ballScale.value,
                        child: Transform.rotate(
                          angle: _ballRotate.value,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: AnimatedBuilder(
                    animation: _glowAnim,
                    builder: (context, child) {
                      return Container(
                        width: ResponsiveHelper.scale(context, 150),
                        height: ResponsiveHelper.scale(context, 150),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [Colors.white, Color(0xFFE8F5E9)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.35),
                              blurRadius: 30,
                              offset: const Offset(0, 18),
                            ),
                            BoxShadow(
                              color: const Color(0xFF4CAF50)
                                  .withOpacity(0.5 * _glowAnim.value),
                              blurRadius: 45 * _glowAnim.value,
                              spreadRadius: 8 * _glowAnim.value,
                            ),
                            BoxShadow(
                              color: const Color(0xFFFFD700)
                                  .withOpacity(0.2 * _glowAnim.value),
                              blurRadius: 70 * _glowAnim.value,
                              spreadRadius: 12 * _glowAnim.value,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '⚽',
                            style: TextStyle(
                                fontSize:
                                ResponsiveHelper.scale(context, 80)),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: ResponsiveHelper.scale(context, 44)),

                // ── TITRE ─────────────────────────────────────────────────
                AnimatedBuilder(
                  animation: _titleController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _titleSlide.value),
                      child: Opacity(
                        opacity: _titleOpacity.value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Colors.white,
                            Color(0xFFB9F6CA),
                            Colors.white,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          AppLocalizations.of(context)!.splashTitle,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.textScale(context, 52),
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 3,
                            shadows: const [
                              Shadow(
                                  color: Colors.black38,
                                  blurRadius: 20,
                                  offset: Offset(0, 4)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.scale(context, 14)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.scale(context, 24),
                          vertical: ResponsiveHelper.scale(context, 10),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.12)),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.splashSubtitle,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.textScale(context, 15),
                            color: Colors.white60,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: ResponsiveHelper.scale(context, 60)),

                // ── BARRE DE PROGRESSION ──────────────────────────────────
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _progressFade.value,
                      child: child,
                    );
                  },
                  child: SizedBox(
                    width: ResponsiveHelper.scale(context, 220),
                    child: Column(
                      children: [
                        // Label chargement
                        AnimatedBuilder(
                          animation: _progressValue,
                          builder: (context, _) {
                            return Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.splashLoading,
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize:
                                    ResponsiveHelper.textScale(context, 13),
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 2,
                                  ),
                                ),
                                Text(
                                  '${(_progressValue.value * 100).toInt()}%',
                                  style: TextStyle(
                                    color: const Color(0xFF4CAF50),
                                    fontSize:
                                    ResponsiveHelper.textScale(context, 13),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: ResponsiveHelper.scale(context, 10)),

                        // Barre de progression stylisée
                        AnimatedBuilder(
                          animation: _progressValue,
                          builder: (context, _) {
                            return Container(
                              height: ResponsiveHelper.scale(context, 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _progressValue.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF4CAF50),
                                        const Color(0xFFFFD700)
                                            .withOpacity(
                                            _progressValue.value),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF4CAF50)
                                            .withOpacity(0.5),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Copyright discret en bas ──────────────────────────────────
          Positioned(
            bottom: ResponsiveHelper.scale(context, 20),
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _titleController,
              builder: (context, _) {
                return Opacity(
                  opacity: _titleOpacity.value * 0.5,
                  child: Text(
                    '© HeyHappy Studio',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white30,
                      fontSize: ResponsiveHelper.textScale(context, 11),
                      letterSpacing: 2,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Particles splash ─────────────────────────────────────────────────────────

class _SplashParticle {
  late double x, y, radius, opacity, speed, angle;
  _SplashParticle(double w, double h) {
    final rng = math.Random();
    x = rng.nextDouble() * w;
    y = rng.nextDouble() * h;
    radius = 0.5 + rng.nextDouble() * 2;
    opacity = 0.06 + rng.nextDouble() * 0.18;
    speed = 0.1 + rng.nextDouble() * 0.35;
    angle = rng.nextDouble() * math.pi * 2;
  }
}

class _SplashParticlePainter extends CustomPainter {
  final double progress;
  final List<_SplashParticle> particles;

  _SplashParticlePainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      final dy = (p.y - progress * p.speed * size.height * 2) % size.height;
      final dx = p.x +
          math.sin(progress * math.pi * 2 + p.angle) * 12;
      paint.color = Colors.white.withOpacity(p.opacity);
      canvas.drawCircle(Offset(dx % size.width, dy), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_SplashParticlePainter old) =>
      old.progress != progress;
}

// ── Painter lignes terrain ────────────────────────────────────────────────────

class _SplashFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Ligne médiane
    canvas.drawLine(
        Offset(0, size.height * 0.5),
        Offset(size.width, size.height * 0.5),
        paint);

    // Cercle central
    canvas.drawCircle(
        Offset(size.width / 2, size.height * 0.5),
        size.width * 0.18,
        paint);

    // Surface de réparation haute
    final topRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.08),
          width: size.width * 0.5,
          height: 70),
      const Radius.circular(10),
    );
    canvas.drawRRect(topRect, paint);

    // Surface de réparation basse
    final bottomRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.92),
          width: size.width * 0.5,
          height: 70),
      const Radius.circular(10),
    );
    canvas.drawRRect(bottomRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
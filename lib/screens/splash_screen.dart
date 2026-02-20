import 'package:flutter/material.dart';
import 'package:happygoal/l10n/app_localizations.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:happygoal/constants.dart';
import 'package:happygoal/utils/responsive_helper.dart';
import 'home_screen.dart';
import 'package:happygoal/utils/remote_config_service.dart'; //


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _titleController;
  late AnimationController _progressController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _titleOpacityAnimation;
  late Animation<double> _titleSlideAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // --- CONFIGURATION DES ANIMATIONS (Inchangé) ---
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.3, end: 1.2).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoRotateAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _titleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _titleSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );

    // Lancer les animations
    _startAnimations();

    // ⭐ LANCER LA VÉRIFICATION DE SÉCURITÉ
    _checkAppVersion();
  }

  // --- LOGIQUE DE KILL SWITCH ---
  Future<void> _checkAppVersion() async {
    // 1. Initialiser le service
    await RemoteConfigService().initialize();

    // 2. Vérifier si update obligatoire
    bool mustUpdate = await RemoteConfigService().isUpdateRequired();

    if (mustUpdate) {
      // 🛑 STOP : Afficher le dialogue bloquant
      if (mounted) {
        _showBlockingUpdateDialog();
      }
    } else {
      // ✅ OK : Vérifier si une update Google flexible est dispo (optionnel) puis aller à l'accueil
      await _checkForInAppUpdate();
    }
  }

  // Affiche le dialogue impossible à fermer
  void _showBlockingUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false, // Désactive le bouton retour Android
        child: AlertDialog(
          backgroundColor: const Color(0xFF0F3622),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
              children: [
                const Icon(Icons.system_update, color: Color(0xFFFFD700)),
                const SizedBox(width: 10),
                Text(AppLocalizations.of(context)!.splashRequiredUpdateTitle, style: const TextStyle(color: Colors.white)),
              ],
          ),
          content: Text(
            AppLocalizations.of(context)!.splashRequiredUpdateContent,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            ElevatedButton(
              onPressed: _launchStore,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
              ),
              child: Text(AppLocalizations.of(context)!.splashRequiredUpdateButton),
            ),
          ],
        ),
      ),
    );
  }

  void _launchStore() {
    final appId = 'com.heyhappy.happygoal'; // Ton ID de package
    try {
      launchUrl(
        Uri.parse("market://details?id=$appId"),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      launchUrl(
        Uri.parse("https://play.google.com/store/apps/details?id=$appId"),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  // Vérification Google Play (Update In-App)
  Future<void> _checkForInAppUpdate() async {
    try {
      if (Platform.isAndroid) {
        AppUpdateInfo info = await InAppUpdate.checkForUpdate();
        if (info.updateAvailability == UpdateAvailability.updateAvailable) {
          // On tente une mise à jour immédiate si dispo, sinon on continue
          await InAppUpdate.performImmediateUpdate();
        }
      }
    } catch (e) {
      print("Erreur InAppUpdate (non bloquant): $e");
    } finally {
      // Quoi qu'il arrive, on va à l'accueil
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    // Petit délai pour laisser finir l'animation de la barre de progression
    Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _titleController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _progressController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _titleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.fieldGreen, Color(0xFF0F4A2D)],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          CustomPaint(
            size: Size(screenWidth, screenHeight),
            painter: FieldLinesPainter(),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Transform.rotate(
                        angle: _logoRotateAnimation.value * 0.1,
                        child: Container(
                          width: 160, height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.white, Color(0xFFF0F0F0)],
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 15)),
                              BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, -8)),
                              BoxShadow(color: const Color(0xFF4CAF50).withOpacity(0.3), blurRadius: 30, spreadRadius: 5),
                            ],
                          ),
                          child: const Center(child: Text('⚽', style: TextStyle(fontSize: 80))),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _titleController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _titleSlideAnimation.value),
                      child: Opacity(
                        opacity: _titleOpacityAnimation.value,
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(colors: [Colors.white, Color(0xFFE0E0E0), Colors.white]).createShader(bounds),
                              child: Text(
                                AppLocalizations.of(context)!.splashTitle,
                                style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 3, shadows: [Shadow(offset: Offset(0, 0), blurRadius: 20, color: Colors.white), Shadow(offset: Offset(0, 5), blurRadius: 15, color: Colors.black)]),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: Colors.white.withOpacity(0.15), border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]),
                              child: Text(
                                AppLocalizations.of(context)!.splashSubtitle,
                                style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w400, letterSpacing: 1.2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 60),
                Container(
                  width: 200,
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _progressController.value,
                            child: Text(
                              AppLocalizations.of(context)!.splashLoading,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w300, letterSpacing: 1.5),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 6,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white.withOpacity(0.2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))]),
                        child: AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return LinearProgressIndicator(value: _progressAnimation.value, backgroundColor: Colors.transparent, valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF4CAF50)), minHeight: 6);
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return Text('${(_progressAnimation.value * 100).toInt()}%', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w300));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FieldLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.08)..strokeWidth = 2..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 60, paint);
    final rect = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(size.width / 2, size.height * 0.8), width: size.width * 0.6, height: 80), const Radius.circular(20));
    canvas.drawRRect(rect, paint);
    final rect2 = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(size.width / 2, size.height * 0.2), width: size.width * 0.6, height: 80), const Radius.circular(20));
    canvas.drawRRect(rect2, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../constants.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Color?> _colorAnimation;
  final List<Offset> _particles = [];

  @override
  void initState() {
    super.initState();

    // Initialiser les particules aléatoires
    _generateParticles();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInCubic,
      ),
    );

    _colorAnimation = ColorTween(
      begin: AppColors.primary.withOpacity(0.5),
      end: AppColors.primary,
    ).animate(_controller);

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  void _generateParticles() {
    final random = Random();
    for (int i = 0; i < 20; i++) {
      _particles.add(Offset(
        random.nextDouble() * 1.5 - 0.25, // Position X (-0.25 à 1.25)
        random.nextDouble() * 1.5 - 0.25, // Position Y (-0.25 à 1.25)
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0 + (1 - _controller.value) * 0.5,
                colors: [
                  _colorAnimation.value!,
                  _colorAnimation.value!.withOpacity(0.7),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Particules de fond animées
                ..._particles.map((particle) => Positioned(
                  left: particle.dx * MediaQuery.of(context).size.width,
                  top: particle.dy * MediaQuery.of(context).size.height,
                  child: Opacity(
                    opacity: 0.3,
                    child: Transform.scale(
                      scale: 0.5 + _controller.value * 0.5,
                      child: Icon(
                        Icons.sports_soccer_rounded,
                        color: Colors.yellow.withOpacity(0.8),
                        size: 16,
                      ),
                    ),
                  ),
                )),

                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo avec animation
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 180,
                          height: 180,
                          child: Center(
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 140,
                              height: 140,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Titre avec animation de fondu
                      FadeTransition(
                        opacity: _opacityAnimation,
                        child: Column(
                          children: [
                            Text(
                              'HappyGoal',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Le défi des tirs au but..!',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 20,
                                letterSpacing: 1.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 5,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Indicateur de chargement
                      Opacity(
                        opacity: _controller.value > 0.5 ? 1.0 : 0.0,
                        child: SizedBox(
                          width: 100,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.lightGreenAccent),
                            minHeight: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
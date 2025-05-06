import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'screens/splash_screen.dart';
import 'constants.dart';
import 'utils/audio_manager.dart';
import 'utils/analytics_service.dart'; // Nous allons créer ce fichier

// Instance globale pour l'analytics
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase
  await Firebase.initializeApp();

  // Initialisation de l'analytics
  AnalyticsService.initialize(analytics);

  // Préférences d'orientation
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialiser l'audio
  await AudioManager.init();

  runApp(const HappyGoalApp());
}

class HappyGoalApp extends StatefulWidget {
  const HappyGoalApp({Key? key}) : super(key: key);

  @override
  State<HappyGoalApp> createState() => _HappyGoalAppState();
}

class _HappyGoalAppState extends State<HappyGoalApp> with WidgetsBindingObserver {
  // Observateur d'analytics
  final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  void initState() {
    super.initState();
    // Ajouter l'observateur pour détecter les changements d'état de l'application
    WidgetsBinding.instance.addObserver(this);
    // Démarrer la musique de fond
    AudioManager.playBackgroundMusic();

    // Enregistrer l'ouverture de l'application
    AnalyticsService.logAppOpen();
  }

  @override
  void dispose() {
    // Supprimer l'observateur
    WidgetsBinding.instance.removeObserver(this);
    // Libérer les ressources audio
    AudioManager.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Gérer les changements d'état de l'application
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      // Arrêter la musique quand l'app n'est pas en premier plan
        AudioManager.stopBackgroundMusic();

        // Log de l'événement d'arrière-plan
        AnalyticsService.logAppBackground();
        break;
      case AppLifecycleState.resumed:
      // Redémarrer la musique quand l'app revient au premier plan
        AudioManager.playBackgroundMusic();

        // Log de l'événement de reprise
        AnalyticsService.logAppForeground();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HappyGoal',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [observer], // Ajouter l'observateur d'analytics
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
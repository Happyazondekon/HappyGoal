import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'constants.dart';
import 'utils/audio_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  @override
  void initState() {
    super.initState();
    // Ajouter l'observateur pour détecter les changements d'état de l'application
    WidgetsBinding.instance.addObserver(this);
    // Démarrer la musique de fond
    AudioManager.playBackgroundMusic();
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
        break;
      case AppLifecycleState.resumed:
      // Redémarrer la musique quand l'app revient au premier plan
        AudioManager.playBackgroundMusic();
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
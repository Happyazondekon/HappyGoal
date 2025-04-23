import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'constants.dart';
import 'utils/audio_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Définir l'orientation portrait uniquement
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Initialiser le gestionnaire audio
  await AudioManager.init();

  runApp(const HappyGoalApp());
}

class HappyGoalApp extends StatefulWidget {
  const HappyGoalApp({Key? key}) : super(key: key);

  @override
  State<HappyGoalApp> createState() => _HappyGoalAppState();
}

class _HappyGoalAppState extends State<HappyGoalApp> {
  @override
  void initState() {
    super.initState();
    // Démarrer la musique de fond
    AudioManager.playBackgroundMusic();
  }

  @override
  void dispose() {
    // Libérer les ressources audio
    AudioManager.dispose();
    super.dispose();
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
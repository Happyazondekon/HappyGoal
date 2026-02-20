import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/splash_screen.dart';
import 'constants.dart';
import 'utils/audio_manager.dart';
import 'utils/analytics_service.dart';
import 'utils/admob_service.dart';
import 'notification_service.dart';
import 'utils/iap_service.dart'; // ⭐ NOUVEAU : Import du service IAP
import 'services/achievement_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl_standalone.dart';

// Instance globale pour l'analytics
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase
  await Firebase.initializeApp();

  // Initialisation de l'analytics
  AnalyticsService.initialize(analytics);

  // ⭐ NOUVEAU : Initialisation du service d'achats intégrés
  // Il est important de l'initialiser tôt pour écouter les transactions en attente
  await IAPService.instance.initialize();

  // Initialisation d'AdMob
  await AdMobService.initialize();

  // Initialisation du service de notifications
  await NotificationService().initialize();

  // Programmer les notifications récurrentes
  await NotificationService().scheduleRecurringNotifications();

  // Charger les publicités en arrière-plan
  await AdMobService.instance.loadInterstitialAd();
  await AdMobService.instance.loadRewardedAd();
  await AdMobService.instance.loadRewardedInterstitialAd();

  // Récupération automatique des IDs de test
  final deviceInfo = await MobileAds.instance.getRequestConfiguration();
  debugPrint('Test Device IDs actuels : ${deviceInfo.testDeviceIds}');

  // Initialiser le service d'achievements
  await AchievementService().initialize();

  // Préférences d'orientation
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialiser l'audio
  await AudioManager.init();

  // Ensure system locale is loaded
  final systemLocale = await findSystemLocale();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HappyGoal',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
    );
  }
}
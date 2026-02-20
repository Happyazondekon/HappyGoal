import 'package:flutter/material.dart';
import 'package:happygoal/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/locale_provider.dart';
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
import 'utils/iap_service.dart';
import 'services/achievement_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl_standalone.dart';


// Instance globale pour l'analytics
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  AnalyticsService.initialize(analytics);
  await IAPService.instance.initialize();
  await AdMobService.initialize();
  await NotificationService().initialize();
  await NotificationService().scheduleRecurringNotifications();
  await AdMobService.instance.loadInterstitialAd();
  await AdMobService.instance.loadRewardedAd();
  await AdMobService.instance.loadRewardedInterstitialAd();
  final deviceInfo = await MobileAds.instance.getRequestConfiguration();
  debugPrint('Test Device IDs actuels : ${deviceInfo.testDeviceIds}');
  await AchievementService().initialize();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await AudioManager.init();
  final systemLocale = await findSystemLocale();

  final localeProvider = LocaleProvider();
  await localeProvider.loadLocale();
  runApp(
    ChangeNotifierProvider.value(
      value: localeProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
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
      locale: localeProvider.locale,
      home: const SplashScreen(),
      localizationsDelegates: const [
        AppLocalizations.delegate,              // ← AJOUT (clé du fix)
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
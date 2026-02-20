// notification_service.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:happygoal/models/achievement.dart';
import 'package:happygoal/services/achievement_service.dart';
import 'package:happygoal/l10n/app_localizations.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;



class NotificationService {
    /// Notification immédiate pour succès mode Hero (avec i18n)
    Future<bool> sendHeroAchievementNotification(String achievementId, BuildContext? context) async {
      if (!await areNotificationsEnabled()) return false;

      final achievement = AchievementsList.getById(achievementId);
      if (achievement == null) return false;

      // Utiliser AppLocalizations si context fourni
      String title = "🎉 Succès Hero débloqué !";
      String subtitle = "Bravo ! ${achievement.title} : ${achievement.description}";
      
      if (context != null) {
        final l10n = AppLocalizations.of(context);
        if (l10n != null) {
          title = l10n.notificationAchievementUnlocked;
          subtitle = "${achievement.title} : ${achievement.description}";
        }
      }

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'happygoal_hero',
        'Succès Hero',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/img',
        color: Color(0xFF2196F3), // Bleu
      );

      const NotificationDetails details = NotificationDetails(android: androidDetails);

      await _flutterLocalNotificationsPlugin.show(
        Random().nextInt(10000),
        title,
        subtitle,
        details,
      );
      return true;
    }
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static const String _notificationEnabledKey = 'notifications_enabled';
  static const String _userTeamKey = 'user_team_name';
  static const String _tournamentWinsKey = 'tournament_wins_count';

  // Messages motivationnels pour les joueurs de football
  final List<String> _motivationalMessages = [
    "Prêt à marquer des buts spectaculaires ? ⚽",
    "Votre équipe favorite vous attend sur le terrain ! 🏆",
    "Nouveau défi penalty contre le Brésil ! 🇧🇷",
    "C'est l'heure de devenir un héros du football ! 🦸‍♂️",
    "Les penalties t'appellent ! Prêt à jouer ? 🎮",
    "Transforme-toi en star du football ! ⭐",
    "Une nouvelle compétition t'attend ! 🌟",
    "Viens montrer tes talents de buteur ! 💪",
    "C'est parti pour une session de tirs au but ! 🎉",
    "Tes compétences ont besoin de s'entraîner ! 🔥",
    "Les filets tremblent devant toi ! 🥅",
    "Prêt à remporter la coupe ? 🏆",
    "Il est temps de faire trembler les filets ! ⚽",
    "Viens collectionner de nouveaux trophées ! 🏅",
    "Une dose de football pour bien commencer ! ☀️",
    "Un nouveau tournoi t'attend ! 🌟",
    "Prêt pour ta session d'entraînement ? 💫",
    "Le stade est rempli, c'est à toi de jouer ! 👏",
    "Marque le but de la victoire ! 🥳",
    "Deviens la légende du penalty ! ✨"
  ];

  // Messages de félicitations pour les tournois gagnés
  final List<String> _congratulationMessages = [
    "Bravo champion ! Tu as remporté le tournoi 🏆",
    "Victoire impressionnante ! Tu domines le jeu ⭐",
    "Tournoi gagné ! Tu es un vrai professionnel 💪",
    "Félicitations pour cette performance remarquable 🎉",
    "Tu as écrasé la compétition ! Continue comme ça 🔥",
    "Chapeau l'artiste ! Ton trophée est mérité 🥇",
    "Incroyable ! Tu as tout balayé sur ton passage ⚡",
    "Maestro du penalty ! Ta coupe t'attend 🏆",
    "Génial ! Tu as montré qui était le patron 💥",
    "Performance parfaite ! Tu es imbattable 🌟"
  ];

  /// Récupérer les messages motivationnels localisés
  List<String> _getLocalizedMotivationalMessages(AppLocalizations? l10n) {
    if (l10n == null) {
      return _motivationalMessages;
    }
    return [
      l10n.notificationMotivational1,
      l10n.notificationMotivational2,
      l10n.notificationMotivational3,
      l10n.notificationMotivational4,
      l10n.notificationMotivational5,
      l10n.notificationMotivational6,
      l10n.notificationMotivational7,
      l10n.notificationMotivational8,
      l10n.notificationMotivational9,
      l10n.notificationMotivational10,
    ];
  }

  /// Récupérer les messages de félicitations localisés
  List<String> _getLocalizedCongratulationMessages(AppLocalizations? l10n) {
    if (l10n == null) {
      return _congratulationMessages;
    }
    return [
      l10n.notificationCongratulation1,
      l10n.notificationCongratulation2,
      l10n.notificationCongratulation3,
    ];
  }

  /// Initialisation du service de notifications
  Future<void> initialize() async {
    try {
      // Initialiser les fuseaux horaires
      tz_data.initializeTimeZones();

      // Configuration Android
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/img');

      // Configuration iOS
      const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
      InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Demander les permissions
      await _requestPermissions();

      print('Service de notifications initialisé avec succès');
    } catch (e) {
      print('Erreur lors de l\'initialisation du service de notifications: $e');
      // Ne pas rethrow pour éviter de bloquer l'app si les notifs échouent
    }
  }

  /// Demander les permissions nécessaires
  Future<bool> _requestPermissions() async {
    try {
      final notificationStatus = await Permission.notification.request();

      if (notificationStatus.isDenied || notificationStatus.isPermanentlyDenied) {
        return false;
      }

      if (Platform.isAndroid) {
        await Permission.scheduleExactAlarm.request();
      }

      return true;
    } catch (e) {
      print('Erreur lors de la demande de permissions: $e');
      return false;
    }
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    print('Notification tapped: ${notificationResponse.payload}');
  }

  // --- Gestion des données utilisateur ---

  Future<void> saveUserTeam(String teamName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userTeamKey, teamName);
    } catch (e) {
      print('Erreur lors de la sauvegarde de l\'équipe: $e');
    }
  }

  Future<void> incrementTournamentWins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentWins = prefs.getInt(_tournamentWinsKey) ?? 0;
      await prefs.setInt(_tournamentWinsKey, currentWins + 1);
    } catch (e) {
      print('Erreur lors de l\'incrémentation des victoires: $e');
    }
  }

  Future<int> getTournamentWins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_tournamentWinsKey) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<String?> getUserTeam() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userTeamKey);
    } catch (e) {
      return null;
    }
  }

  Future<bool> _canUseExactAlarms() async {
    if (!Platform.isAndroid) return true;
    try {
      return await Permission.scheduleExactAlarm.isGranted;
    } catch (e) {
      return false;
    }
  }

  // --- Logique principale de planification ---

  /// Programmer les notifications récurrentes intelligentes (avec i18n optionnel)
  Future<bool> scheduleRecurringNotifications({BuildContext? context}) async {
    try {
      if (!await areNotificationsEnabled()) {
        return false;
      }

      await cancelAllNotifications();

      final now = DateTime.now();
      final deviceTimeZone = _getDeviceTimeZone();

      // Récupérer les localisations si context fourni
      final l10n = context != null ? AppLocalizations.of(context) : null;
      final motivationalMessages = _getLocalizedMotivationalMessages(l10n);
      final congratulationMessages = _getLocalizedCongratulationMessages(l10n);

      // Horaires stratégiques
      final notificationTimes = [
        DateTime(now.year, now.month, now.day, 09, 0),   // Matin
        DateTime(now.year, now.month, now.day, 12, 30),  // Pause déjeuner
        DateTime(now.year, now.month, now.day, 18, 0),   // Soirée
        DateTime(now.year, now.month, now.day, 20, 30),  // Prime time
      ];

      int notificationId = 1000;
      int scheduledCount = 0;

      // Récupérer les données pour personnaliser
      final userTeam = await getUserTeam();
      final tournamentWins = await getTournamentWins();

      // ⭐ Analyser les achievements proches d'être débloqués
      final achievementService = AchievementService();
      await achievementService.initialize(); // S'assurer qu'il est chargé
      final closeAchievements = _getCloseAchievements(achievementService);

      for (int i = 0; i < notificationTimes.length; i++) {
        var scheduledDateTime = notificationTimes[i];

        if (scheduledDateTime.isBefore(now)) {
          scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
        }

        final scheduledDate = tz.TZDateTime.from(scheduledDateTime, deviceTimeZone);

        String title;
        String message;

        // --- LOGIQUE DE SÉLECTION DU MESSAGE ---
        // 1. Priorité aux achievements proches (une fois par jour max, disons à 18h)
        if (i == 2 && closeAchievements.isNotEmpty) {
          final achievement = closeAchievements.first; // Prendre le premier
          final progress = achievementService.getProgress(achievement.id);
          final remaining = achievement.targetValue - (progress?.currentValue ?? 0);

          title = "🏆 Succès '${achievement.title}' en vue !";
          message = "Plus que $remaining pour débloquer ce succès et gagner ${achievement.rewardCoins} coins !";
        }
        // 2. Message de champion si tournois gagnés (aléatoire)
        else if (tournamentWins > 0 && Random().nextDouble() < 0.3) {
          title = "Le Champion est de retour ? 🏆";
          message = congratulationMessages[Random().nextInt(congratulationMessages.length)];
        }
        // 3. Message classique motivationnel
        else {
          final opponent = _getRandomOpponent();
          title = userTeam != null ? "Match pour $userTeam ! ⚽" : "Prêt à tirer ? ⚽";
          message = "Défiez $opponent ! ${motivationalMessages[Random().nextInt(motivationalMessages.length)]}";
        }

        final success = await _scheduleSingleNotification(
          id: notificationId,
          scheduledDate: scheduledDate,
          title: title,
          message: message,
          isRepeating: true,
        );

        if (success) {
          scheduledCount++;
          notificationId++;
        }
      }

      return scheduledCount > 0;

    } catch (e) {
      print('Erreur lors de la programmation des notifications récurrentes: $e');
      return false;
    }
  }

  // ⭐ Helper pour trouver les achievements proches (à 80% complétés)
  List<Achievement> _getCloseAchievements(AchievementService service) {
    List<Achievement> closeOnes = [];
    final all = service.getAllWithProgress();

    for (var entry in all) {
      final achievement = entry.key;
      final progress = entry.value;

      if (!progress.isUnlocked && achievement.targetValue > 5) { // Ignorer les trop petits objectifs
        double percent = progress.currentValue / achievement.targetValue;
        if (percent >= 0.75) { // Si complété à 75% ou plus
          closeOnes.add(achievement);
        }
      }
    }
    return closeOnes;
  }

  Future<bool> _scheduleSingleNotification({
    required int id,
    required tz.TZDateTime scheduledDate,
    required String title,
    required String message,
    required bool isRepeating,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'happygoal_channel',
        'Rappels HappyGoal',
        channelDescription: 'Notifications de jeu et récompenses',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/img',
        color: Color(0xFF34A853), // Vert HappyGoal
        styleInformation: BigTextStyleInformation(''), // Pour afficher les longs messages
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        sound: 'default',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final canUseExact = await _canUseExactAlarms();
      final scheduleMode = canUseExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        message,
        scheduledDate,
        platformDetails,
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: isRepeating ? DateTimeComponents.time : null,
        payload: 'happygoal_reminder',
      );

      return true;
    } catch (e) {
      print('Erreur programmation notif $id: $e');
      return false;
    }
  }

  String _getRandomOpponent() {
    final opponents = [
      "le Brésil 🇧🇷", "la France 🇫🇷", "l'Allemagne 🇩🇪", "l'Argentine 🇦🇷",
      "l'Espagne 🇪🇸", "l'Italie 🇮🇹", "le Portugal 🇵🇹", "les Pays-Bas 🇳🇱",
      "le Maroc 🇲🇦", "le Sénégal 🇸🇳", "la Côte d'Ivoire 🇨🇮"
    ];
    return opponents[Random().nextInt(opponents.length)];
  }

  tz.Location _getDeviceTimeZone() {
    try {
      return tz.local;
    } catch (e) {
      return tz.local;
    }
  }

  Future<void> setNotificationsEnabled(bool enabled, {BuildContext? context}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, enabled);

    if (!enabled) {
      await cancelAllNotifications();
    } else {
      await scheduleRecurringNotifications(context: context);
    }
  }

  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationEnabledKey) ?? true;
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Notification immédiate pour victoire de championnat (avec i18n)
  Future<bool> sendTournamentWinNotification(BuildContext? context) async {
    if (!await areNotificationsEnabled()) return false;

    // Utiliser AppLocalizations si context fourni
    String title = "🏆 CHAMPIONNAT GAGNÉ !";
    String subtitle = "Félicitations ! Vous avez remporté un championnat. Reviens vite défendre ton titre !";
    
    if (context != null) {
      final l10n = AppLocalizations.of(context);
      if (l10n != null) {
        title = l10n.notificationTournamentWon;
        subtitle = l10n.notificationCongratulation1;
      }
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'happygoal_wins',
      'Victoires HappyGoal',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/img',
      color: Color(0xFFFFD700), // Or
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      Random().nextInt(10000),
      title,
      subtitle,
      details,
    );
    return true;
  }

  /// Vérifier au démarrage et reprogrammer avec i18n optionnel
  Future<void> checkAndRescheduleNotifications({BuildContext? context}) async {
    if (await areNotificationsEnabled()) {
      await scheduleRecurringNotifications(context: context);
    }
  }
}
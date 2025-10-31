import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static const String _notificationEnabledKey = 'notifications_enabled';
  static const String _customNotificationsKey = 'custom_notifications';
  static const String _lastNotificationKey = 'last_notification_time';
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

  /// Initialisation du service de notifications
  Future<void> initialize() async {
    try {
      // Initialiser les fuseaux horaires
      tz.initializeTimeZones();

      // Configuration Android
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

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
      rethrow;
    }
  }

  /// Demander les permissions nécessaires (incluant SCHEDULE_EXACT_ALARM pour Android 13+)
  Future<bool> _requestPermissions() async {
    try {
      // Permission pour les notifications
      final notificationStatus = await Permission.notification.request();

      if (notificationStatus.isDenied || notificationStatus.isPermanentlyDenied) {
        print("Permission pour les notifications refusée.");
        return false;
      }

      // Pour Android 13+ (API 33+), demander la permission pour les alarmes exactes
      if (Platform.isAndroid) {
        final scheduleExactAlarmStatus = await Permission.scheduleExactAlarm.request();

        if (scheduleExactAlarmStatus.isDenied || scheduleExactAlarmStatus.isPermanentlyDenied) {
          print("Permission pour les alarmes exactes refusée. Utilisation des alarmes inexactes.");
          // Continue quand même, on utilisera des alarmes inexactes
        } else {
          print("Permission pour les alarmes exactes accordée.");
        }
      }

      print("Permissions pour les notifications accordées.");
      return true;
    } catch (e) {
      print('Erreur lors de la demande de permissions: $e');
      return false;
    }
  }

  /// Gérer le tap sur la notification
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    print('Notification tapped: ${notificationResponse.payload}');
    // Navigation vers l'écran principal du jeu
  }

  /// Sauvegarder le nom de l'équipe de l'utilisateur
  Future<void> saveUserTeam(String teamName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userTeamKey, teamName);
      print('Équipe utilisateur sauvegardée: $teamName');
    } catch (e) {
      print('Erreur lors de la sauvegarde de l\'équipe: $e');
    }
  }

  /// Incrémenter le compteur de tournois gagnés
  Future<void> incrementTournamentWins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentWins = prefs.getInt(_tournamentWinsKey) ?? 0;
      await prefs.setInt(_tournamentWinsKey, currentWins + 1);
      print('Tournois gagnés: ${currentWins + 1}');
    } catch (e) {
      print('Erreur lors de l\'incrémentation des victoires: $e');
    }
  }

  /// Obtenir le nombre de tournois gagnés
  Future<int> getTournamentWins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_tournamentWinsKey) ?? 0;
    } catch (e) {
      print('Erreur lors de la récupération des victoires: $e');
      return 0;
    }
  }

  /// Obtenir le nom de l'équipe de l'utilisateur
  Future<String?> getUserTeam() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userTeamKey);
    } catch (e) {
      print('Erreur lors de la récupération de l\'équipe: $e');
      return null;
    }
  }

  /// Vérifier si on peut utiliser des alarmes exactes
  Future<bool> _canUseExactAlarms() async {
    if (!Platform.isAndroid) return true; // iOS peut toujours utiliser des alarmes exactes

    try {
      final status = await Permission.scheduleExactAlarm.status;
      return status.isGranted;
    } catch (e) {
      print('Erreur lors de la vérification des permissions d\'alarmes exactes: $e');
      return false;
    }
  }

  /// Programmer les notifications récurrentes toutes les 3 heures
  Future<bool> scheduleRecurringNotifications() async {
    try {
      // Vérifier si les notifications sont activées
      if (!await areNotificationsEnabled()) {
        print('Notifications désactivées');
        return false;
      }

      // Annuler les anciennes notifications
      await cancelAllNotifications();

      // Programmer plusieurs notifications récurrentes
      final now = DateTime.now();
      final deviceTimeZone = _getDeviceTimeZone();

      // Créer des notifications à différents moments de la journée
      final notificationTimes = [
        DateTime(now.year, now.month, now.day, 11, 03),   // 9h00
        DateTime(now.year, now.month, now.day, 12, 0),  // 12h00
        DateTime(now.year, now.month, now.day, 15, 0),  // 15h00
        DateTime(now.year, now.month, now.day, 18, 0),  // 18h00
        DateTime(now.year, now.month, now.day, 21, 0),  // 21h00
      ];

      int notificationId = 1000;
      int scheduledCount = 0;

      for (final time in notificationTimes) {
        var scheduledDateTime = time;

        // Si l'heure est déjà passée aujourd'hui, programmer pour demain
        if (scheduledDateTime.isBefore(now)) {
          scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
        }

        final scheduledDate = tz.TZDateTime.from(scheduledDateTime, deviceTimeZone);
        final userTeam = await getUserTeam();
        final tournamentWins = await getTournamentWins();

        String title;
        String message;

        // Alterner entre différents types de messages
        if (tournamentWins > 0 && Random().nextBool()) {
          // Message de félicitations pour les tournois gagnés
          title = "Bravo Champion ! 🏆";
          message = _congratulationMessages[Random().nextInt(_congratulationMessages.length)];
        } else {
          // Message motivationnel classique
          final opponent = _getRandomOpponent();
          title = userTeam != null ? "Prêt pour un match $userTeam ? ⚽" : "Prêt à jouer ? ⚽";
          message = "Seriez-vous prêt à gagner contre $opponent ? ${_getRandomMotivationalMessage()}";
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

      print('═══════════════════════════════════════════════════════');
      print('📊 RÉSUMÉ DES NOTIFICATIONS PROGRAMMÉES');
      print('═══════════════════════════════════════════════════════');
      print('$scheduledCount notifications récurrentes programmées avec succès');
      print('🔔 Mode: ${await _canUseExactAlarms() ? "Alarmes exactes" : "Alarmes inexactes"}');
      print('⏰ Horaires quotidiens: 9h, 12h, 15h, 18h, 21h');
      print('═══════════════════════════════════════════════════════');

      return scheduledCount > 0;

    } catch (e) {
      print('Erreur lors de la programmation des notifications récurrentes: $e');
      return false;
    }
  }

  /// Programmer une notification unique (VERSION CORRIGÉE)
  Future<bool> _scheduleSingleNotification({
    required int id,
    required tz.TZDateTime scheduledDate,
    required String title,
    required String message,
    required bool isRepeating,
  }) async {
    try {
      // Configuration des détails de notification
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'happygoal_channel',
        'HappyGoal Notifications',
        channelDescription: 'Notifications pour les rappels de jeu et les tournois',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF34A853),
        enableLights: true,
        enableVibration: true,
        playSound: true,
        channelShowBadge: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        sound: 'default',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        badgeNumber: 1,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Vérifier si on peut utiliser des alarmes exactes
      final canUseExact = await _canUseExactAlarms();

      // Choisir le mode de planification approprié
      final scheduleMode = canUseExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;

      // Programmer la notification
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        message,
        scheduledDate,
        platformDetails,
        androidScheduleMode: scheduleMode, // Mode adaptatif
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: isRepeating ? DateTimeComponents.time : null,
        payload: 'happygoal_game_reminder',
      );

      // Formater la date pour l'affichage
      final dateFormatted = '${scheduledDate.day.toString().padLeft(2, '0')}/${scheduledDate.month.toString().padLeft(2, '0')}/${scheduledDate.year} à ${scheduledDate.hour.toString().padLeft(2, '0')}:${scheduledDate.minute.toString().padLeft(2, '0')}';

      print('✅ Notification programmée (mode: ${canUseExact ? "exact" : "inexact"})');
      print('   📅 Date: $dateFormatted');
      print('   📌 Titre: $title');
      print('   💬 Message: $message');
      print('   🔔 ID: $id');
      print('   🔁 Répétitive: ${isRepeating ? "Oui (quotidienne)" : "Non"}');
      print('   ─────────────────────────────────────');

      return true;

    } catch (e) {
      print('Erreur lors de la programmation de la notification $id: $e');
      return false;
    }
  }

  /// Obtenir un adversaire aléatoire
  String _getRandomOpponent() {
    final opponents = [
      "le Brésil 🇧🇷", "la France 🇫🇷", "l'Allemagne 🇩🇪", "l'Argentine 🇦🇷",
      "l'Espagne 🇪🇸", "l'Angleterre 🏴󐁧󐁢󐁥󐁮󐁧󐁿", "l'Italie 🇮🇹", "le Portugal 🇵🇹",
      "les Pays-Bas 🇳🇱", "la Belgique 🇧🇪", "le Maroc 🇲🇦", "le Sénégal 🇸🇳",
      "le Cameroun 🇨🇲", "la Côte d'Ivoire 🇨🇮", "le Nigeria 🇳🇬", "le Ghana 🇬🇭",
      "l'Égypte 🇪🇬", "la Tunisie 🇹🇳", "l'Algérie 🇩🇿", "le Mexique 🇲🇽",
      "les États-Unis 🇺🇸", "le Canada 🇨🇦", "le Japon 🇯🇵", "la Corée du Sud 🇰🇷",
      "l'Australie 🇦🇺"
    ];
    return opponents[Random().nextInt(opponents.length)];
  }

  /// Obtenir le fuseau horaire correct de l'appareil
  tz.Location _getDeviceTimeZone() {
    try {
      return tz.local;
    } catch (e) {
      print('Erreur lors de la détection du fuseau horaire: $e');
      return tz.local;
    }
  }

  /// Obtenir un message motivationnel aléatoire
  String _getRandomMotivationalMessage() {
    final random = Random();
    return _motivationalMessages[random.nextInt(_motivationalMessages.length)];
  }

  /// Activer/Désactiver les notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationEnabledKey, enabled);

      if (!enabled) {
        await cancelAllNotifications();
        print('Toutes les notifications ont été désactivées et annulées');
      } else {
        // Réactiver les notifications
        await scheduleRecurringNotifications();
        print('Notifications activées et programmées');
      }
    } catch (e) {
      print('Erreur lors du changement d\'état des notifications: $e');
    }
  }

  /// Vérifier si les notifications sont activées
  Future<bool> areNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_notificationEnabledKey) ?? true;
    } catch (e) {
      print('Erreur lors de la vérification de l\'état: $e');
      return true; // Par défaut activé
    }
  }

  /// Annuler toutes les notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      print('Toutes les notifications ont été annulées');
    } catch (e) {
      print('Erreur lors de l\'annulation: $e');
    }
  }

  /// Envoyer une notification immédiate de victoire de tournoi
  Future<bool> sendTournamentWinNotification() async {
    try {
      if (!await areNotificationsEnabled()) {
        return false;
      }

      final tournamentWins = await getTournamentWins();
      final random = Random();

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'happygoal_achievements',
        'Récompenses HappyGoal',
        channelDescription: 'Notifications pour les réussites et tournois gagnés',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFFFFD700),
        enableLights: true,
        enableVibration: true,
        playSound: true,
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

      await _flutterLocalNotificationsPlugin.show(
        random.nextInt(10000),
        "🏆 Tournoi Gagné !",
        _congratulationMessages[random.nextInt(_congratulationMessages.length)],
        platformDetails,
        payload: 'happygoal_tournament_win',
      );

      print('Notification de victoire de tournoi envoyée');
      return true;

    } catch (e) {
      print('Erreur lors de l\'envoi de la notification de victoire: $e');
      return false;
    }
  }

  /// Vérifier et reprogrammer les notifications si nécessaire
  Future<void> checkAndRescheduleNotifications() async {
    try {
      if (await areNotificationsEnabled()) {
        await scheduleRecurringNotifications();
      }
    } catch (e) {
      print('Erreur lors de la vérification des notifications: $e');
    }
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'admob_service.dart';
import 'analytics_service.dart';

class AdController {
  static AdController? _instance;
  static AdController get instance => _instance ??= AdController._();

  AdController._();

  // Configuration des fréquences de publicités
  static const int _gamesUntilInterstitial = 3; // Pub interstitielle tous les 3 matchs
  static const int _minutesBetweenRewarded = 5;  // Pub rewarded min 5 min d'intervalle

  int _gamesSinceLastInterstitial = 0;
  DateTime? _lastRewardedAdTime;

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _gamesSinceLastInterstitial = _prefs?.getInt('games_since_interstitial') ?? 0;

    final lastRewardedString = _prefs?.getString('last_rewarded_time');
    if (lastRewardedString != null) {
      _lastRewardedAdTime = DateTime.tryParse(lastRewardedString);
    }
  }

  // Appelé à la fin d'un match
  Future<void> onGameCompleted(BuildContext context) async {
    _gamesSinceLastInterstitial++;
    await _prefs?.setInt('games_since_interstitial', _gamesSinceLastInterstitial);

    // Afficher pub interstitielle si nécessaire
    if (_gamesSinceLastInterstitial >= _gamesUntilInterstitial) {
      _showInterstitialIfAvailable(context);
    }
  }

  // Afficher publicité interstitielle
  void _showInterstitialIfAvailable(BuildContext context) {
    if (AdMobService.instance.isInterstitialReady) {
      AdMobService.instance.showInterstitialAd(
        onAdClosed: () {
          _gamesSinceLastInterstitial = 0;
          _prefs?.setInt('games_since_interstitial', 0);
          AnalyticsService.logAdEvent('interstitial_shown');
        },
      );
    }
  }

  // Vérifier si une pub rewarded peut être affichée
  bool canShowRewardedAd() {
    if (!AdMobService.instance.isRewardedReady) return false;

    if (_lastRewardedAdTime == null) return true;

    final now = DateTime.now();
    final difference = now.difference(_lastRewardedAdTime!);
    return difference.inMinutes >= _minutesBetweenRewarded;
  }

  // Afficher publicité rewarded avec récompense
  void showRewardedAd({
    required BuildContext context,
    required String rewardType,
    required VoidCallback onRewardEarned,
    VoidCallback? onAdClosed,
    VoidCallback? onAdFailed,
  }) {
    if (!canShowRewardedAd()) {
      onAdFailed?.call();
      _showRewardedCooldownDialog(context);
      return;
    }

    AdMobService.instance.showRewardedAd(
      onUserEarnedReward: (ad, reward) {
        _lastRewardedAdTime = DateTime.now();
        _prefs?.setString('last_rewarded_time', _lastRewardedAdTime!.toIso8601String());

        AnalyticsService.logAdEvent('rewarded_earned', parameters: {
          'reward_type': rewardType,
          'reward_amount': reward.amount,
        });

        onRewardEarned();
      },
      onAdClosed: () {
        onAdClosed?.call();
      },
    );
  }

  // Forcer l'affichage d'une publicité interstitielle (ex: avant un mode important)
  void forceShowInterstitial(BuildContext context, {VoidCallback? onClosed}) {
    if (AdMobService.instance.isInterstitialReady) {
      AdMobService.instance.showInterstitialAd(
        onAdClosed: () {
          _gamesSinceLastInterstitial = 0;
          _prefs?.setInt('games_since_interstitial', 0);
          onClosed?.call();
        },
      );
    } else {
      onClosed?.call();
    }
  }

  // Dialog pour informer du cooldown de la pub rewarded
  void _showRewardedCooldownDialog(BuildContext context) {
    if (_lastRewardedAdTime == null) return;

    final now = DateTime.now();
    final difference = now.difference(_lastRewardedAdTime!);
    final remainingMinutes = _minutesBetweenRewarded - difference.inMinutes;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Publicité non disponible',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Vous pourrez regarder une nouvelle publicité dans $remainingMinutes minute${remainingMinutes > 1 ? 's' : ''}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Dialog pour proposer une récompense via pub rewarded
  void showRewardDialog({
    required BuildContext context,
    required String title,
    required String description,
    required String rewardType,
    required VoidCallback onRewardEarned,
    VoidCallback? onDeclined,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.card_giftcard, color: Colors.amber, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                description,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              if (!canShowRewardedAd())
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Publicité temporairement indisponible',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDeclined?.call();
              },
              child: const Text('Non merci'),
            ),
            ElevatedButton.icon(
              onPressed: canShowRewardedAd()
                  ? () {
                Navigator.of(context).pop();
                showRewardedAd(
                  context: context,
                  rewardType: rewardType,
                  onRewardEarned: onRewardEarned,
                );
              }
                  : null,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Regarder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Getters pour l'état
  int get gamesSinceLastInterstitial => _gamesSinceLastInterstitial;
  bool get isRewardedAvailable => canShowRewardedAd();
}
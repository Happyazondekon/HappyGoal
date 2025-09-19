// ad_controller.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'admob_service.dart';
import 'analytics_service.dart';

class AdController {
  static AdController? _instance;
  static AdController get instance => _instance ??= AdController._();

  // ⭐️ LOGIQUE REMBOBINAGE
  int _rewindCount = 0;

  // ⭐️ LOGIQUE REMBOBINAGE: Limite par match
  static const int MAX_REWINDS_PER_GAME = 2; // Limite de rembobinages par match/tournoi
  int _usedRewindsInCurrentGame = 0;

  AdController._();

  // Configuration des fréquences de publicités
  static const int _gamesUntilInterstitial = 3;
  static const int _minutesBetweenRewarded = 5;

  int _gamesSinceLastInterstitial = 0;
  DateTime? _lastRewardedAdTime;

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _gamesSinceLastInterstitial = _prefs?.getInt('games_since_interstitial') ?? 0;

    // ⭐️ LOGIQUE REMBOBINAGE: Chargement
    _rewindCount = _prefs?.getInt('rewind_count') ?? 0;

    final lastRewardedString = _prefs?.getString('last_rewarded_time');
    if (lastRewardedString != null) {
      _lastRewardedAdTime = DateTime.tryParse(lastRewardedString);
    }
  }

  // Appelé au début d'un match
  void onGameStarted() {
    resetGameRewindLimit();
  }

  // Appelé à la fin d'un match
  Future<void> onGameCompleted(BuildContext context) async {
    resetGameRewindLimit(); // Réinitialiser la limite par match

    _gamesSinceLastInterstitial++;
    await _prefs?.setInt('games_since_interstitial', _gamesSinceLastInterstitial);

    // Afficher pub interstitielle si nécessaire
    if (_gamesSinceLastInterstitial >= _gamesUntilInterstitial) {
      _showInterstitialIfAvailable(context);
    }
  }

  // ⭐️ LOGIQUE REMBOBINAGE: Incrémentation et persistance
  Future<void> incrementRewindCount() async {
    _rewindCount++;
    await _prefs?.setInt('rewind_count', _rewindCount);
  }

  // ⭐️ LOGIQUE REMBOBINAGE: Décrémentation et persistance (MODIFIÉ)
  // Utilise canUseRewind et incrémente le compte d'utilisation par match.
  Future<bool> decrementRewindCount() async {
    if (_rewindCount > 0 && _usedRewindsInCurrentGame < MAX_REWINDS_PER_GAME) {
      _rewindCount--;
      _usedRewindsInCurrentGame++; // Incrémenter l'utilisation pour ce match
      await _prefs?.setInt('rewind_count', _rewindCount);
      return true;
    }
    return false;
  }

  // ⭐️ LOGIQUE REMBOBINAGE: Vérifier si l'utilisateur peut utiliser un rembobinage (NOUVEAU)
  bool canUseRewind() {
    // Vérifier si on a des rembobinages disponibles
    if (_rewindCount <= 0) {
      return false;
    }

    // Vérifier si on n'a pas dépassé la limite par match
    if (_usedRewindsInCurrentGame >= MAX_REWINDS_PER_GAME) {
      return false;
    }

    return true;
  }

  // ⭐️ LOGIQUE REMBOBINAGE: Méthode appelée au début d'un nouveau match/tournoi (NOUVEAU)
  void resetGameRewindLimit() {
    _usedRewindsInCurrentGame = 0;
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
    VoidCallback? onDeclined, required int rewardAmount, required VoidCallback onAdFailed,
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
                  onAdFailed: onAdFailed, // Ajout de onAdFailed
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

  // ⭐️ LOGIQUE REMBOBINAGE: Méthode pour afficher une boîte de dialogue d'information sur les rembobinages (NOUVEAU)
  void showRewindLimitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            const Icon(Icons.info, color: Colors.blue),
            const SizedBox(width: 10),
            const Text('Limite de rembobinages'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vous avez utilisé tous vos rembobinages pour ce match, ou vous n\'en avez plus en stock.'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statut actuel:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('• Maximum $MAX_REWINDS_PER_GAME rembobinages par match'),
                  Text('• Utilisés dans ce match: $_usedRewindsInCurrentGame/$MAX_REWINDS_PER_GAME'),
                  Text('• Rembobinages totaux en stock: $_rewindCount'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text('Regardez une publicité pour gagner plus de rembobinages !'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Compris'),
          ),
          if(canShowRewardedAd())
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                showRewardDialog(
                  context: context,
                  title: 'Gagner des rembobinages',
                  description: 'Regardez une publicité pour gagner un rembobinage supplémentaire !',
                  rewardType: 'rewind',
                  rewardAmount: 1,
                  onRewardEarned: () async {
                    await incrementRewindCount();
                    // Afficher un SnackBar pour confirmer
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Rembobinage gagné !'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  onAdFailed: () {
                    // Afficher un SnackBar si la pub échoue
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Publicité non disponible'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Gagner des rembobinages', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  // Getters pour l'état
  int get gamesSinceLastInterstitial => _gamesSinceLastInterstitial;
  bool get isRewardedAvailable => canShowRewardedAd();
  // ⭐️ LOGIQUE REMBOBINAGE: Getter public
  int get currentRewindCount => _rewindCount;
  // ⭐️ LOGIQUE REMBOBINAGE: Getter pour savoir combien de rembobinages restent pour ce match (NOUVEAU)
  int get remainingRewindsForGame {
    return (MAX_REWINDS_PER_GAME - _usedRewindsInCurrentGame).clamp(0, _rewindCount);
  }
}
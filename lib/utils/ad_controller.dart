// lib/utils/ad_controller.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'admob_service.dart';
import 'analytics_service.dart';

class AdController {
  static AdController? _instance;
  static AdController get instance => _instance ??= AdController._();

  // Constantes économiques
  static const int REWIND_COST = 25; // Coût en coins pour un rembobinage
  static const int REWARD_COINS = 5; // Coins gagnés par pub vidéo
  static const int MAX_REWINDS_PER_GAME = 2; // Limite stratégique par match

  int _coinCount = 0;
  int _rewindCount = 0;
  int _usedRewindsInCurrentGame = 0;

  // Configuration des fréquences de publicités
  static const int _gamesUntilInterstitial = 2;
  static const int _minutesBetweenRewarded = 2;

  int _gamesSinceLastInterstitial = 0;
  DateTime? _lastRewardedAdTime;

  SharedPreferences? _prefs;

  AdController._();

  // ---------------------------------------------------------------------------
  // INITIALISATION
  // ---------------------------------------------------------------------------

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    // Chargement des données persistantes
    _gamesSinceLastInterstitial = _prefs?.getInt('games_since_interstitial') ?? 0;
    _coinCount = _prefs?.getInt('coin_count') ?? 0;
    _rewindCount = _prefs?.getInt('rewind_count') ?? 0;

    final lastRewardedString = _prefs?.getString('last_rewarded_time');
    if (lastRewardedString != null) {
      _lastRewardedAdTime = DateTime.tryParse(lastRewardedString);
    }

    debugPrint("💰 AdController chargé: $_coinCount coins, $_rewindCount rembobinages");
  }

  // Appelé au début d'un match
  void onGameStarted() {
    resetGameRewindLimit();
  }

  // Appelé à la fin d'un match
  Future<void> onGameCompleted(BuildContext context) async {
    resetGameRewindLimit();

    _gamesSinceLastInterstitial++;
    await _prefs?.setInt('games_since_interstitial', _gamesSinceLastInterstitial);

    if (_gamesSinceLastInterstitial >= _gamesUntilInterstitial) {
      _showInterstitialIfAvailable(context);
    }
  }

  // ---------------------------------------------------------------------------
  // GESTION DES COINS (Monétisation & IAP)
  // ---------------------------------------------------------------------------

  /// Ajoute des coins au solde de l'utilisateur.
  /// Cette méthode est le point d'entrée pour :
  /// 1. Les récompenses publicitaires (Rewarded Ads)
  /// 2. Les achats intégrés (In-App Purchases)
  Future<void> addCoins(int amount) async {
    _coinCount += amount;
    await _prefs?.setInt('coin_count', _coinCount);

    // Log pour le debug
    debugPrint("💳 Transaction coins: +$amount. Nouveau solde: $_coinCount");

    // On pourrait ajouter un Analytics event ici pour tracer la circulation de monnaie
    // AnalyticsService.logEvent('earn_virtual_currency', {'value': amount});
  }

  /// Tente d'acheter un stock de rembobinage avec des coins
  Future<bool> buyRewind() async {
    if (_coinCount >= REWIND_COST) {
      _coinCount -= REWIND_COST;
      _rewindCount++;

      await _prefs?.setInt('coin_count', _coinCount);
      await _prefs?.setInt('rewind_count', _rewindCount);

      AnalyticsService.logAdEvent('spend_virtual_currency', parameters: {
        'item_name': 'rewind',
        'value': REWIND_COST,
      });

      return true;
    }
    return false;
  }

  // ---------------------------------------------------------------------------
  // LOGIQUE REMBOBINAGE
  // ---------------------------------------------------------------------------

  Future<void> incrementRewindCount() async {
    _rewindCount++;
    await _prefs?.setInt('rewind_count', _rewindCount);
  }

  Future<bool> decrementRewindCount() async {
    if (canUseRewind()) {
      _rewindCount--;
      _usedRewindsInCurrentGame++;
      await _prefs?.setInt('rewind_count', _rewindCount);
      return true;
    }
    return false;
  }

  bool canUseRewind() {
    return _rewindCount > 0 && _usedRewindsInCurrentGame < MAX_REWINDS_PER_GAME;
  }

  void resetGameRewindLimit() {
    _usedRewindsInCurrentGame = 0;
  }

  int getUsedRewindCount() {
    return _usedRewindsInCurrentGame;
  }

  // ---------------------------------------------------------------------------
  // GESTION DES PUBLICITÉS
  // ---------------------------------------------------------------------------

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

  bool canShowRewardedAd() {
    if (!AdMobService.instance.isRewardedReady) return false;
    if (_lastRewardedAdTime == null) return true;

    final now = DateTime.now();
    final difference = now.difference(_lastRewardedAdTime!);
    return difference.inMinutes >= _minutesBetweenRewarded;
  }

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

        // Logique de récompense
        if (rewardType == 'coins') {
          addCoins(REWARD_COINS);
        } else if (rewardType == 'rewind') {
          incrementRewindCount(); // Cas rare si tu gardes des rewards directs
        }

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

  // ---------------------------------------------------------------------------
  // DIALOGUES UI
  // ---------------------------------------------------------------------------

  void _showRewardedCooldownDialog(BuildContext context) {
    if (_lastRewardedAdTime == null) return;
    final now = DateTime.now();
    final difference = now.difference(_lastRewardedAdTime!);
    final remainingMinutes = _minutesBetweenRewarded - difference.inMinutes;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Publicité non disponible'),
          content: Text('Vous pourrez regarder une nouvelle publicité dans $remainingMinutes minute(s).'),
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

  void showBuyRewindDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1B6B3A),
        title: Row(
          children: const [
            Icon(Icons.shopping_cart, color: Color(0xFFFFD700), size: 28),
            SizedBox(width: 10),
            Text('Acheter', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acheter 1 rembobinage pour $REWIND_COST coins ?',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Vos coins:', style: TextStyle(color: Colors.white)),
                  Text('$_coinCount', style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: _coinCount >= REWIND_COST ? () {
              Navigator.of(context).pop();
              _processRewindPurchase(context);
            } : null,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
            child: const Text('Acheter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _processRewindPurchase(BuildContext context) {
    buyRewind().then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 10), Text('Rembobinage acheté !')]),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(children: [Icon(Icons.error, color: Colors.white), SizedBox(width: 10), Text('Pas assez de coins !')]),
            backgroundColor: Color(0xFFFF5722),
          ),
        );
      }
    });
  }

  void showRewardDialog({
    required BuildContext context,
    required String title,
    required String description,
    required String rewardType,
    required int rewardAmount,
    required VoidCallback onRewardEarned,
    required VoidCallback onAdFailed,
    VoidCallback? onDeclined,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.card_giftcard, color: Colors.amber, size: 28),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(description, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 15),
              if (!canShowRewardedAd())
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Text('Publicité indisponible', style: TextStyle(color: Colors.orange, fontSize: 14), textAlign: TextAlign.center),
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
                  onAdFailed: onAdFailed,
                );
              }
                  : null,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Regarder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        );
      },
    );
  }

  void showRewindLimitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(children: const [Icon(Icons.info, color: Colors.blue), SizedBox(width: 10), Text('Limite atteinte')]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vous avez atteint la limite de rembobinage pour ce match ou votre stock est épuisé.'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Statut:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('• Limite par match: $MAX_REWINDS_PER_GAME'),
                  Text('• Utilisés: $_usedRewindsInCurrentGame'),
                  Text('• Stock total: $_rewindCount'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fermer')),
          if (canShowRewardedAd())
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                showRewardDialog(
                  context: context,
                  title: 'Rembobinage gratuit',
                  description: 'Regardez une pub pour gagner 1 rembobinage !',
                  rewardType: 'rewind',
                  rewardAmount: 1,
                  onRewardEarned: () async {
                    await incrementRewindCount();
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rembobinage gagné !'), backgroundColor: Colors.green));
                  },
                  onAdFailed: () {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pub indisponible'), backgroundColor: Colors.orange));
                  },
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Gagner +1', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // GETTERS
  // ---------------------------------------------------------------------------
  int get gamesSinceLastInterstitial => _gamesSinceLastInterstitial;
  bool get isRewardedAvailable => canShowRewardedAd();
  int get currentCoinCount => _coinCount;
  int get rewindCost => REWIND_COST;
  int get rewardCoins => REWARD_COINS;
  int get currentRewindCount => _rewindCount;
  int get remainingRewindsForGame => (MAX_REWINDS_PER_GAME - _usedRewindsInCurrentGame).clamp(0, _rewindCount);
}
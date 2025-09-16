import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  // Singleton
  static final AdMobService instance = AdMobService._();
  AdMobService._();

  // IDs de test fournis par Google
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  // Vos vrais IDs AdMob (Android / iOS)
  static const String _androidBannerAdUnitId = 'ca-app-pub-2066223330804112/8794013956';
  static const String _iosBannerAdUnitId = 'ca-app-pub-2066223330804112/XXXXXXXXXX';

  static const String _androidInterstitialAdUnitId = 'ca-app-pub-2066223330804112/4298528883';
  static const String _iosInterstitialAdUnitId = 'ca-app-pub-2066223330804112/XXXXXXXXXX';

  static const String _androidRewardedAdUnitId = 'ca-app-pub-2066223330804112/7730561334';
  static const String _iosRewardedAdUnitId = 'ca-app-pub-2066223330804112/XXXXXXXXXX';

  // États des publicités
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isInterstitialAdLoaded = false;
  bool _isRewardedAdLoaded = false;

  // Initialisation de Google Mobile Ads
  static Future<void> initialize({List<String>? testDeviceIds}) async {
    await MobileAds.instance.initialize();

    // Configuration des devices de test si fournis
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        testDeviceIds: kDebugMode ? testDeviceIds : null,
      ),
    );

    debugPrint('AdMob initialized. Debug mode: $kDebugMode');
  }

  // -------------------------
  // Getters pour les Ad Unit IDs
  // -------------------------
  String get bannerAdUnitId {
    if (kDebugMode) return _testBannerAdUnitId;
    return Platform.isAndroid ? _androidBannerAdUnitId : _iosBannerAdUnitId;
  }

  String get interstitialAdUnitId {
    if (kDebugMode) return _testInterstitialAdUnitId;
    return Platform.isAndroid ? _androidInterstitialAdUnitId : _iosInterstitialAdUnitId;
  }

  String get rewardedAdUnitId {
    if (kDebugMode) return _testRewardedAdUnitId;
    return Platform.isAndroid ? _androidRewardedAdUnitId : _iosRewardedAdUnitId;
  }

  // -------------------------
  // Bannière
  // -------------------------
  BannerAd? createBannerAd({AdSize size = AdSize.banner, required BannerAdListener listener}) {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => debugPrint('Bannière chargée'),
        onAdFailedToLoad: (ad, error) {
          debugPrint('Erreur bannière: $error');
          ad.dispose();
          _bannerAd = null;
        },
        onAdOpened: (ad) => debugPrint('Bannière ouverte'),
        onAdClosed: (ad) => debugPrint('Bannière fermée'),
      ),
    );

    _bannerAd!.load();
    return _bannerAd;
  }

  // -------------------------
  // Interstitielle
  // -------------------------
  Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          debugPrint('Interstitielle chargée');
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoaded = false;
          debugPrint('Erreur chargement interstitielle: $error');
        },
      ),
    );
  }

  void showInterstitialAd({VoidCallback? onAdClosed}) {
    if (_interstitialAd != null && _isInterstitialAdLoaded) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) => debugPrint('Interstitielle affichée'),
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('Interstitielle fermée');
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
          onAdClosed?.call();
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Erreur affichage interstitielle: $error');
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
          onAdClosed?.call();
        },
      );
      _interstitialAd!.show();
    } else {
      onAdClosed?.call();
      loadInterstitialAd();
    }
  }

  // -------------------------
  // Rewarded
  // -------------------------
  Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          debugPrint('Rewarded chargée');
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoaded = false;
          debugPrint('Erreur chargement rewarded: $error');
        },
      ),
    );
  }

  void showRewardedAd({
    required Function(AdWithoutView ad, RewardItem reward) onUserEarnedReward,
    VoidCallback? onAdClosed,
  }) {
    if (_rewardedAd != null && _isRewardedAdLoaded) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) => debugPrint('Rewarded affichée'),
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('Rewarded fermée');
          ad.dispose();
          _rewardedAd = null;
          _isRewardedAdLoaded = false;
          onAdClosed?.call();
          loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Erreur affichage rewarded: $error');
          ad.dispose();
          _rewardedAd = null;
          _isRewardedAdLoaded = false;
          onAdClosed?.call();
        },
      );
      _rewardedAd!.show(onUserEarnedReward: onUserEarnedReward);
    } else {
      onAdClosed?.call();
      loadRewardedAd();
    }
  }

  // -------------------------
  // Vérification état ads
  // -------------------------
  bool get isInterstitialReady => _isInterstitialAdLoaded && _interstitialAd != null;
  bool get isRewardedReady => _isRewardedAdLoaded && _rewardedAd != null;

  // -------------------------
  // Dispose
  // -------------------------
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}

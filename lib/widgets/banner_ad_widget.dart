import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/admob_service.dart';

class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;
  final EdgeInsets? margin;
  final Color? backgroundColor;

  const BannerAdWidget({
    Key? key,
    this.adSize = AdSize.banner,
    this.margin,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = AdMobService.instance.createBannerAd(
      size: widget.adSize,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          // AJOUTEZ CETTE LIGNE POUR VÉRIFIER LE SUCCÈS
          debugPrint('✅ Bannière publicitaire chargée avec succès !');
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          // C'est déjà présent
          debugPrint('❌ Erreur chargement bannière: $error');
          ad.dispose();
          if (mounted) {
            setState(() {
              _bannerAd = null;
              _isLoaded = false;
            });
          }
        },
      ),
    );
    _bannerAd?.load(); // S'assurer que la méthode .load() est appelée
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return Container(
        width: widget.adSize.width.toDouble(),
        height: widget.adSize.height.toDouble(),
        margin: widget.margin,
        color: widget.backgroundColor ?? Colors.transparent,
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        ),
      );
    }

    return Container(
      width: widget.adSize.width.toDouble(),
      height: widget.adSize.height.toDouble(),
      margin: widget.margin,
      color: widget.backgroundColor,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
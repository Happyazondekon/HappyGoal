// lib/utils/remote_config_service.dart
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    try {
      // Configuration : En dev on fetch souvent, en prod on garde du cache
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1), // Mettre à 0 pour tester immédiatement
      ));

      // Valeurs par défaut (Sécurité)
      // On met la version actuelle comme défaut pour ne pas s'auto-bloquer
      // si le téléphone n'a pas internet au premier lancement.
      await _remoteConfig.setDefaults({
        'min_required_version': '2.2.2',
      });

      // Récupération des valeurs depuis le cloud
      await _remoteConfig.fetchAndActivate();

      print("🔥 Remote Config (min_required): ${_remoteConfig.getString('min_required_version')}");
    } catch (e) {
      print('❌ Erreur Remote Config (init): $e');
    }
  }

  /// Vérifie si une mise à jour est obligatoire
  Future<bool> isUpdateRequired() async {
    try {
      // 1. Récupérer la version actuelle installée
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      // On nettoie la version pour ne garder que "2.2.2" et ignorer "+16" si présent
      String currentVersion = _cleanVersion(packageInfo.version);

      // 2. Récupérer la version minimum requise depuis Firebase
      String minVersion = _cleanVersion(_remoteConfig.getString('min_required_version'));

      print("📱 Comparaison : App=$currentVersion vs Required=$minVersion");

      if (minVersion.isEmpty) return false;

      // 3. Comparer : Si Actuelle < Requise => Update requise
      return _compareVersions(currentVersion, minVersion) < 0;
    } catch (e) {
      print("⚠️ Erreur vérification version: $e");
      return false; // En cas d'erreur, on laisse passer l'utilisateur
    }
  }

  /// Nettoie la version pour enlever le build number (ex: "2.2.2+16" -> "2.2.2")
  String _cleanVersion(String version) {
    if (version.contains('+')) {
      return version.split('+').first;
    }
    return version;
  }

  /// Retourne -1 si v1 < v2, 0 si égal, 1 si v1 > v2
  int _compareVersions(String v1, String v2) {
    try {
      List<int> v1Parts = v1.split('.').map(int.parse).toList();
      List<int> v2Parts = v2.split('.').map(int.parse).toList();

      for (int i = 0; i < v1Parts.length && i < v2Parts.length; i++) {
        if (v1Parts[i] < v2Parts[i]) return -1;
        if (v1Parts[i] > v2Parts[i]) return 1;
      }

      // Gérer les longueurs différentes (ex: 2.2 vs 2.2.1)
      if (v1Parts.length < v2Parts.length) return -1;
      if (v1Parts.length > v2Parts.length) return 1;

      return 0;
    } catch (e) {
      print("Erreur parsing version: $e");
      return 0; // On considère égal par sécurité
    }
  }
}
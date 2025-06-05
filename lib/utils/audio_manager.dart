import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  static final Map<String, AudioPlayer> _players = {};
  static final AudioPlayer _backgroundPlayer = AudioPlayer();
  static bool _isSoundEnabled = true;
  static bool _isMusicEnabled = true;
  static bool _playInBackground = false;
  static double _volume = 0.5;
  static bool _isInitialized = false;

  /// Initialiser le système audio
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Charger les préférences
      await _loadSettings();

      // Charger la musique de fond
      await _backgroundPlayer.setAsset('assets/audio/background.mp3');
      await _backgroundPlayer.setLoopMode(LoopMode.one);
      await _backgroundPlayer.setVolume(_volume);

      // Précharger les effets sonores
      final sounds = [
        'crowd_cheer',
        'goal',
        'goalkeeper_save',
        'kick',
        'click',
        'whistle',
      ];

      // Création de nouveaux joueurs pour chaque son
      for (var sound in sounds) {
        _players[sound] = AudioPlayer();
        // Uniquement précharger, pas besoin de setAsset ici
      }

      _isInitialized = true;
      if (kDebugMode) {
        print('Initialisation audio réussie');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur d\'initialisation audio: $e');
      }
    }
  }

  /// Charger les paramètres audio depuis SharedPreferences
  static Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isSoundEnabled = prefs.getBool('sound_enabled') ?? true;
      _isMusicEnabled = prefs.getBool('music_enabled') ?? true;
      _playInBackground = prefs.getBool('play_in_background') ?? false;
      _volume = prefs.getDouble('volume') ?? 0.5;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du chargement des paramètres audio: $e');
      }
    }
  }

  /// Sauvegarder les paramètres audio dans SharedPreferences
  static Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sound_enabled', _isSoundEnabled);
      await prefs.setBool('music_enabled', _isMusicEnabled);
      await prefs.setBool('play_in_background', _playInBackground);
      await prefs.setDouble('volume', _volume);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la sauvegarde des paramètres audio: $e');
      }
    }
  }

  /// Jouer un son
  static Future<void> playSound(String name) async {
    if (!_isSoundEnabled) return;
    if (!_isInitialized) {
      if (kDebugMode) {
        print('AudioManager non initialisé');
      }
      return;
    }

    try {
      final player = _players[name];
      if (player != null) {
        // Charger le fichier audio juste avant de le jouer
        await player.setAsset('assets/audio/$name.mp3');
        await player.setVolume(_volume);
        await player.seek(Duration.zero);
        await player.play();
        if (kDebugMode) {
          print('Son joué avec succès: $name');
        }
      } else {
        if (kDebugMode) {
          print('Son non trouvé: $name');
          print('Sons disponibles: ${_players.keys.toList()}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur de lecture du son $name: $e');
      }
    }
  }

  /// Démarrer la musique de fond
  static Future<void> playBackgroundMusic() async {
    if (!_isMusicEnabled || !_isInitialized) return;

    try {
      await _backgroundPlayer.setVolume(_volume);
      await _backgroundPlayer.seek(Duration.zero);
      await _backgroundPlayer.play();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur de lecture de la musique: $e');
      }
    }
  }

  /// Arrêter la musique de fond
  static Future<void> stopBackgroundMusic() async {
    // Si la lecture en arrière-plan est activée, ne pas arrêter la musique
    if (_playInBackground) return;

    try {
      await _backgroundPlayer.pause();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur d\'arrêt de la musique: $e');
      }
    }
  }

  /// Activer/désactiver les sons
  static Future<void> setSoundEnabled(bool enabled) async {
    _isSoundEnabled = enabled;
    await _saveSettings();
  }

  /// Activer/désactiver la musique
  static Future<void> setMusicEnabled(bool enabled) async {
    _isMusicEnabled = enabled;
    await _saveSettings();

    if (_isMusicEnabled) {
      playBackgroundMusic();
    } else {
      await _backgroundPlayer.pause();
    }
  }

  /// Activer/désactiver la lecture en arrière-plan
  static Future<void> setPlayInBackground(bool enabled) async {
    _playInBackground = enabled;
    await _saveSettings();
  }

  /// Définir le volume (0.0 à 1.0)
  static Future<void> setVolume(double volume) async {
    _volume = volume;
    await _saveSettings();

    // Mettre à jour le volume de la musique en cours de lecture
    await _backgroundPlayer.setVolume(_volume);
  }

  /// Récupérer l'état actuel des paramètres audio
  static Map<String, dynamic> getSettings() {
    return {
      'soundEnabled': _isSoundEnabled,
      'musicEnabled': _isMusicEnabled,
      'playInBackground': _playInBackground,
      'volume': _volume,
    };
  }

  /// Libérer les ressources
  static Future<void> dispose() async {
    try {
      for (var player in _players.values) {
        await player.dispose();
      }
      await _backgroundPlayer.dispose();
      _players.clear();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur de libération des ressources audio: $e');
      }
    }
  }
}
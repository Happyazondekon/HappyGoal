import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Gestionnaire audio pour les sons du jeu
class AudioManager {
  static final Map<String, AudioPlayer> _players = {};
  static final AudioPlayer _backgroundPlayer = AudioPlayer();
  static bool _isSoundEnabled = true;
  static bool _isMusicEnabled = true;

  /// Initialiser le système audio
  static Future<void> init() async {
    try {
      await _backgroundPlayer.setAsset('assets/audio/background.mp3');
      await _backgroundPlayer.setLoopMode(LoopMode.one);
      await _backgroundPlayer.setVolume(0.5);

      // Précharger les effets sonores
      final sounds = [
        'assets/audio/crowd_cheer.mp3',
        'assets/audio/goal.mp3',
        'assets/audio/goalkeeper_save.mp3',
        'assets/audio/kick.mp3',
        'assets/audio/whistle.mp3',
      ];

      for (var sound in sounds) {
        final player = AudioPlayer();
        await player.setAsset('assets/audio/${sound}.mp3');
        _players[sound] = player;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur d\'initialisation audio: $e');
      }
    }
  }

  /// Jouer un son
  static Future<void> playSound(String name) async {
    if (!_isSoundEnabled) return;

    try {
      final player = _players[name];
      if (player != null) {
        if (kDebugMode) {
          print('Tentative de lecture du son: $name');
        }
        await player.seek(Duration.zero);
        await player.play();
        if (kDebugMode) {
          print('Son joué avec succès: $name');
        }
      } else {
        if (kDebugMode) {
          print('Son non trouvé dans la map _players: $name');
          print('Sons disponibles: ${_players.keys.toList()}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur de lecture du son: $e');
      }
    }
  }

  /// Démarrer la musique de fond
  static Future<void> playBackgroundMusic() async {
    if (!_isMusicEnabled) return;

    try {
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
    try {
      await _backgroundPlayer.pause();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur d\'arrêt de la musique: $e');
      }
    }
  }

  /// Activer/désactiver les sons
  static void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
  }

  /// Activer/désactiver la musique
  static void setMusicEnabled(bool enabled) {
    _isMusicEnabled = enabled;
    if (_isMusicEnabled) {
      playBackgroundMusic();
    } else {
      stopBackgroundMusic();
    }
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
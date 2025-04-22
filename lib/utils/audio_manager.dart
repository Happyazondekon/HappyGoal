import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static AudioPlayer? _audioPlayer;
  static bool _isMuted = false;

  static final Map<String, String> _sounds = {
    'whistle': 'assets/audio/whistle.mp3',
    'kick': 'assets/audio/kick.mp3',
    'crowd_cheer': 'assets/audio/crowd_cheer.mp3',
    'goalkeeper_save': 'assets/audio/goalkeeper_save.mp3',
    'goal': 'assets/audio/goal.mp3',
    'background': 'assets/audio/background.mp3',
  };

  static Future<void> init() async {
    _audioPlayer = AudioPlayer();
  }

  static Future<void> playSound(String soundName) async {
    if (_isMuted) return;

    final String? path = _sounds[soundName];
    if (path == null) return;

    try {
      await _audioPlayer?.play(AssetSource(path));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  static Future<void> playBackgroundMusic() async {
    if (_isMuted) return;

    try {
      await _audioPlayer?.play(AssetSource(_sounds['background']!));
      await _audioPlayer?.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      print('Error playing background music: $e');
    }
  }

  static Future<void> stopSound() async {
    await _audioPlayer?.stop();
  }

  static void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _audioPlayer?.pause();
    } else {
      _audioPlayer?.resume();
    }
  }

  static void dispose() {
    _audioPlayer?.dispose();
  }
}
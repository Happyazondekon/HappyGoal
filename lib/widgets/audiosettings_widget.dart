import 'package:flutter/material.dart';
import '../utils/audio_manager.dart';

class AudioSettingsWidget extends StatefulWidget {
  const AudioSettingsWidget({Key? key}) : super(key: key);

  @override
  State<AudioSettingsWidget> createState() => _AudioSettingsWidgetState();
}

class _AudioSettingsWidgetState extends State<AudioSettingsWidget> {
  bool _isSoundEnabled = true;
  bool _isMusicEnabled = true;
  bool _playInBackground = false;
  double _volume = 0.5;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final settings = AudioManager.getSettings();
    setState(() {
      _isSoundEnabled = settings['soundEnabled'];
      _isMusicEnabled = settings['musicEnabled'];
      _playInBackground = settings['playInBackground'];
      _volume = settings['volume'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Paramètres audio',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Effets sonores
          SwitchListTile(
            title: const Text('Effets sonores'),
            value: _isSoundEnabled,
            onChanged: (value) {
              setState(() {
                _isSoundEnabled = value;
                AudioManager.setSoundEnabled(value);

                // Jouer un son de test si activé
                if (_isSoundEnabled) {
                  AudioManager.playSound('whistle');
                }
              });
            },
          ),

          // Musique de fond
          SwitchListTile(
            title: const Text('Musique de fond'),
            value: _isMusicEnabled,
            onChanged: (value) {
              setState(() {
                _isMusicEnabled = value;
                AudioManager.setMusicEnabled(value);
              });
            },
          ),

          // Lecture en arrière-plan
          SwitchListTile(
            title: const Text('Continuer la musique en arrière-plan'),
            subtitle: const Text('La musique continue lorsque vous quittez l\'application'),
            value: _playInBackground,
            onChanged: (value) {
              setState(() {
                _playInBackground = value;
                AudioManager.setPlayInBackground(value);
              });
            },
          ),

          // Contrôle du volume
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.volume_down),
                Expanded(
                  child: Slider(
                    value: _volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    onChanged: (value) {
                      setState(() {
                        _volume = value;
                        AudioManager.setVolume(value);
                      });
                    },
                  ),
                ),
                const Icon(Icons.volume_up),
              ],
            ),
          ),

          // Affichage du pourcentage de volume
          Text(
            '${(_volume * 100).round()}%',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
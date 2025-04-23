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
        ],
      ),
    );
  }
}
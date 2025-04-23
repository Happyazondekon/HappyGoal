import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioTestPage extends StatefulWidget {
  @override
  _AudioTestPageState createState() => _AudioTestPageState();
}

class _AudioTestPageState extends State<AudioTestPage> {
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    testAudio();
  }

  Future<void> testAudio() async {
    try {
      await _player.setAsset('assets/audio/goal.mp3');
      await _player.play();
    } catch (e) {
      print('Erreur lors du test audio: $e');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Audio')),
      body: Center(child: Text('Écoute le son !')),
    );
  }
}

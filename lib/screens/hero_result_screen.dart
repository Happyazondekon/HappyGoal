import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:happygoal/models/team.dart';
import 'package:happygoal/models/hero_progression.dart';
import 'hero_mode_screen.dart';

class HeroResultScreen extends StatefulWidget {
  final Team myTeam;
  final Team opponent;
  final int level;
  final int starsWon;
  final VoidCallback onReplay;
  final VoidCallback onNextLevel;

  const HeroResultScreen({
    Key? key,
    required this.myTeam,
    required this.opponent,
    required this.level,
    required this.starsWon,
    required this.onReplay,
    required this.onNextLevel,
  }) : super(key: key);

  @override
  State<HeroResultScreen> createState() => _HeroResultScreenState();
}

class _HeroResultScreenState extends State<HeroResultScreen> with TickerProviderStateMixin {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat du niveau'),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.amber, Colors.blue, Colors.red],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Niveau ${widget.level}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) => Icon(
                    i < widget.starsWon ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 36,
                  )),
                ),
                const SizedBox(height: 24),
                Text('Adversaire : ${widget.opponent.name}', style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Rejouer'),
                      onPressed: widget.onReplay,
                    ),
                    const SizedBox(width: 32),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Niveau suivant'),
                      onPressed: widget.onNextLevel,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

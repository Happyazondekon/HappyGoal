import 'package:flutter/material.dart';
import 'package:happygoal/models/team.dart';

class HeroTransitionScreen extends StatelessWidget {
  final Team myTeam;
  final Team opponent;
  final int level;
  final VoidCallback onContinue;

  const HeroTransitionScreen({
    Key? key,
    required this.myTeam,
    required this.opponent,
    required this.level,
    required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Chapitre $level',
                style: const TextStyle(fontSize: 32, color: Colors.amber, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Image.asset(myTeam.flagImage, width: 60),
                      const SizedBox(height: 8),
                      Text(myTeam.name, style: const TextStyle(color: Colors.white, fontSize: 18)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Icon(Icons.sports_soccer, color: Colors.white, size: 32),
                  ),
                  Column(
                    children: [
                      Image.asset(opponent.flagImage, width: 60),
                      const SizedBox(height: 8),
                      Text(opponent.name, style: const TextStyle(color: Colors.white, fontSize: 18)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                _getStory(level, myTeam, opponent),
                style: const TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Commencer le match'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: onContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStory(int level, Team myTeam, Team opponent) {
    // Personnalise ici l'histoire selon le niveau
    if (level == 1) {
      return "C'est le début de ton aventure ! Tu représentes ${myTeam.name} et ton premier adversaire est ${opponent.name}. Montre ton talent et commence ta légende !";
    } else if (level == 100) {
      return "Le dernier défi t'attend ! Après un parcours héroïque, tu affrontes ${opponent.name} pour la gloire ultime.";
    } else {
      return "Niveau $level : Un nouveau pays se dresse sur ta route. ${myTeam.name} affronte ${opponent.name} dans un duel décisif. Prouve ta valeur !";
    }
  }
}

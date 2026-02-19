import 'package:flutter/material.dart';
import 'package:happygoal/models/game_state.dart';
import 'package:happygoal/models/team.dart';
import 'package:happygoal/screens/game_screen.dart';
import 'package:happygoal/screens/hero_result_screen.dart';
import 'package:happygoal/screens/hero_transition_screen.dart';
import '../models/hero_progression.dart';
import 'hero_team_selection_screen.dart';

class HeroModeScreen extends StatefulWidget {
  @override
  State<HeroModeScreen> createState() => _HeroModeScreenState();
}

class _HeroModeScreenState extends State<HeroModeScreen> {

  HeroProgression? progression;
  String? selectedCountryCode;

  @override
  void initState() {
    super.initState();
    _pendingResult = null;
    _loadProgression();
  }

  Future<void> _loadProgression() async {
    final loaded = await HeroProgression.load();
    if (loaded != null) {
      setState(() {
        progression = loaded;
        selectedCountryCode = loaded.selectedCountryCode;
      });
    }
  }

  Map<String, dynamic>? _pendingResult;

  void _launchLevel(int level, Team myTeam, Team opponent) {
    final double aiDifficulty = 0.5 + 0.005 * (level - 1);
    // Crée une copie profonde des équipes pour éviter la persistance du score
    Team myTeamCopy = myTeam.copyWith(score: 0);
    Team opponentCopy = opponent.copyWith(score: 0);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HeroTransitionScreen(
          myTeam: myTeamCopy,
          opponent: opponentCopy,
          level: level,
          onContinue: () async {
            Navigator.pop(context); // Ferme l'écran de transition
            final gameState = GameState(
              team1: myTeamCopy,
              team2: opponentCopy,
              isSoloMode: true,
              isHeroMode: true,
              aiIntelligenceLevel: aiDifficulty.clamp(0.5, 1.0),
              isTournamentMode: false,
              currentPhase: GamePhase.playerShooting,
            );
            final result = await Navigator.push<Map<String, dynamic>>(
              context,
              MaterialPageRoute(
                builder: (_) => GameScreen(gameState: gameState),
              ),
            );
            if (result != null && result.containsKey('stars')) {
              await progression!.completeLevel(level, result['stars']);
              setState(() {
                _pendingResult = {
                  "level": level,
                  "stars": result['stars'],
                  "myTeam": myTeamCopy,
                  "opponent": opponentCopy,
                };
              });
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_pendingResult != null && progression != null) {
      final int level = _pendingResult!["level"];
      final int stars = _pendingResult!["stars"];
      final Team myTeam = _pendingResult!["myTeam"];
      final Team opponent = _pendingResult!["opponent"];
      return HeroResultScreen(
        myTeam: myTeam,
        opponent: opponent,
        level: level,
        starsWon: stars,
        onReplay: () {
          setState(() {
            _pendingResult = null;
          });
          _launchLevel(level, myTeam, opponent);
        },
        onNextLevel: () {
          setState(() {
            _pendingResult = null;
            // Si 0 étoile, ne pas débloquer le niveau suivant
            if (stars == 0 && progression!.currentLevel == level + 1) {
              progression!.currentLevel = level;
              progression!.save();
            }
          });
        },
      );
    }
    if (progression == null) {
      return HeroTeamSelectionScreen(
        selectedCountryCode: selectedCountryCode,
        onCountrySelected: (countryCode) {
          setState(() {
            selectedCountryCode = countryCode;
            progression = HeroProgression(selectedCountryCode: countryCode);
          });
        },
      );
    } else {
      // Afficher la progression des niveaux
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mode Hero'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Changer de pays (réinitialise la progression)',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Réinitialiser la progression ?'),
                    content: const Text('Vous perdrez votre progression actuelle. Voulez-vous recommencer avec un autre pays ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            progression = null;
                            selectedCountryCode = null;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Oui, recommencer'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: progression!.maxLevel,
          itemBuilder: (context, index) {
            final level = index + 1;
            final stars = progression!.starsPerLevel[level] ?? 0;
            return ListTile(
              leading: Text('Niveau $level'),
              title: Row(
                children: List.generate(3, (i) => Icon(
                  i < stars ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                )),
              ),
              selected: progression!.currentLevel == level,
              onTap: progression!.currentLevel == level
                  ? () {
                      final allTeams = Team.getPredefinedTeams();
                      final myTeam = allTeams.firstWhere((t) => t.name == progression!.selectedCountryCode);
                      final possibleOpponents = allTeams.where((t) => t.name != myTeam.name).toList();
                      possibleOpponents.shuffle();
                      final opponent = possibleOpponents.first;
                      _launchLevel(level, myTeam, opponent);
                    }
                  : null,
            );
          },
        ),
      );
    }
  }
}

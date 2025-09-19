// rewind_reward_widget.dart
import 'package:flutter/material.dart';
import 'package:happygoal/models/game_state.dart';
import 'package:happygoal/screens/game_controller.dart';
import '../utils/ad_controller.dart';
import '../constants.dart';

class RewindRewardWidget extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onStateChanged;
  final GameController? gameController;

  const RewindRewardWidget({
    Key? key,
    required this.gameState,
    required this.onStateChanged,
    this.gameController,
  }) : super(key: key);

  @override
  State<RewindRewardWidget> createState() => _RewindRewardWidgetState();
}

class _RewindRewardWidgetState extends State<RewindRewardWidget> {
  @override
  Widget build(BuildContext context) {
    // CORRECTION : Accès à la propriété statique via la classe
    const maxRewinds = AdController.MAX_REWINDS_PER_GAME;

    final totalRewindCount = AdController.instance.currentRewindCount;
    final remainingForGame = AdController.instance.remainingRewindsForGame;
    // CORRECTION : Utilisation de la constante statique corrigée
    final usedInGame = maxRewinds - remainingForGame;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.8),
            Colors.deepPurple.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ligne principale avec icône et informations
          Row(
            children: [
              const Icon(Icons.replay, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Rembobinages: $totalRewindCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: remainingForGame > 0
                                ? Colors.green.withOpacity(0.7)
                                : Colors.red.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$remainingForGame/$maxRewinds restants', // CORRECTION
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (usedInGame > 0)
                      Text(
                        'Utilisés ce match: $usedInGame',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              _buildActionButton(),
            ],
          ),

          // Barre de progression pour les rembobinages du match
          if (totalRewindCount > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Ce match: ',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      // CORRECTION : Utilisation de la constante statique corrigée
                      widthFactor: remainingForGame / maxRewinds,
                      child: Container(
                        decoration: BoxDecoration(
                          color: remainingForGame > 0 ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '$remainingForGame',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final totalRewindCount = AdController.instance.currentRewindCount;
    final remainingForGame = AdController.instance.remainingRewindsForGame;

    if (totalRewindCount > 0 && remainingForGame > 0) {
      // L'utilisateur a des rembobinages disponibles
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.purple.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 16),
            SizedBox(width: 5),
            Text(
              'Prêt',
              style: TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    } else if (totalRewindCount > 0 && remainingForGame == 0) {
      // L'utilisateur a des rembobinages mais a atteint la limite pour ce match
      return ElevatedButton(
        onPressed: _showLimitReachedDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.warning, size: 14),
            SizedBox(width: 4),
            Text(
              'Limite',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ],
        ),
      );
    } else {
      // L'utilisateur n'a pas de rembobinages
      return ElevatedButton(
        onPressed: _showEarnRewindDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add, size: 14),
            SizedBox(width: 4),
            Text(
              'Gagner',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ],
        ),
      );
    }
  }

  void _showLimitReachedDialog() {
    // CORRECTION : Accès à la propriété statique via la classe
    const maxRewinds = AdController.MAX_REWINDS_PER_GAME;
    final usedInGame = maxRewinds - AdController.instance.remainingRewindsForGame;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: const [
            Icon(Icons.warning, color: Colors.orange, size: 28),
            SizedBox(width: 10),
            Text('Limite atteinte'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vous avez utilisé tous vos rembobinages autorisés pour ce match.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange[800], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Informations:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('• Maximum $maxRewinds rembobinages par match'), // CORRECTION
                  Text('• Utilisés: $usedInGame/$maxRewinds'), // CORRECTION
                  Text('• Rembobinages totaux: ${AdController.instance.currentRewindCount}'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text('Vos rembobinages se réinitialiseront au prochain match !'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Compris'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showEarnRewindDialog();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text(
              'Gagner plus',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showEarnRewindDialog() {
    AdController.instance.showRewardDialog(
      context: context,
      title: 'Gagner un rembobinage',
      description: 'Regardez une publicité pour gagner un rembobinage supplémentaire !',
      rewardType: 'rewind',
      rewardAmount: 1,
      onRewardEarned: () async {
        await AdController.instance.incrementRewindCount();
        widget.onStateChanged();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Rembobinage gagné !'),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      onAdFailed: () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.warning, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Publicité non disponible'),
                ],
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
    );
  }
}
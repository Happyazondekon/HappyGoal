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

class _RewindRewardWidgetState extends State<RewindRewardWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const maxRewinds = AdController.MAX_REWINDS_PER_GAME;
    final totalRewindCount = AdController.instance.currentRewindCount;
    final remainingForGame = AdController.instance.remainingRewindsForGame;
    final coinCount = AdController.instance.currentCoinCount;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B6B3A),
            Color(0xFF2E8B4B),
            Color(0xFF0D4A2D),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icône coins
          GestureDetector(
            onTap: () => _showCoinInfoDialog(),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD700).withOpacity(0.2),
                border: Border.all(
                  color: const Color(0xFFFFD700).withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.monetization_on,
                color: Color(0xFFFFD700),
                size: 14,
              ),
            ),
          ),

          const SizedBox(width: 6),

          // Compteur de coins
          Text(
            '$coinCount',
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),

          const SizedBox(width: 12),

          // Séparateur
          Container(
            width: 1,
            height: 20,
            color: Colors.white.withOpacity(0.3),
          ),

          const SizedBox(width: 12),

          // Icône rembobinage avec effet de lueur
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.25 * _pulseAnimation.value),
                      blurRadius: 6 * _pulseAnimation.value,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.replay,
                  color: Colors.white,
                  size: 14,
                ),
              );
            },
          ),

          const SizedBox(width: 8),

          // Compteur principal rembobinages
          Text(
            '$totalRewindCount',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 0.3,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 3,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          // Badge de status moderne
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: remainingForGame > 0
                  ? const Color(0xFF4CAF50).withOpacity(0.8)
                  : const Color(0xFFFF5722).withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (remainingForGame > 0 ? Colors.green : Colors.red)
                      .withOpacity(0.25),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              '$remainingForGame',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Icône d'action compacte
          _buildCompactActionIcon(totalRewindCount, remainingForGame),
        ],
      ),
    );
  }

  Widget _buildCompactActionIcon(int totalRewindCount, int remainingForGame) {
    Widget iconWidget;
    Color iconColor;
    VoidCallback? onTap;

    if (totalRewindCount > 0 && remainingForGame > 0) {
      iconWidget = const Icon(Icons.check_circle, size: 14);
      iconColor = const Color(0xFF4CAF50);
    } else if (totalRewindCount > 0 && remainingForGame == 0) {
      iconWidget = const Icon(Icons.warning, size: 14);
      iconColor = const Color(0xFFFF9800);
      onTap = _showLimitReachedDialog;
    } else {
      iconWidget = const Icon(Icons.add_circle, size: 14);
      iconColor = const Color(0xFFFFD700);
      onTap = _showEarnRewardDialog;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: iconColor.withOpacity(0.2),
          border: Border.all(
            color: iconColor.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: IconTheme(
          data: IconThemeData(color: iconColor),
          child: iconWidget,
        ),
      ),
    );
  }

  void _showLimitReachedDialog() {
    const maxRewinds = AdController.MAX_REWINDS_PER_GAME;
    final usedInGame = maxRewinds - AdController.instance.remainingRewindsForGame;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1B6B3A),
        title: Row(
          children: const [
            Icon(Icons.warning, color: Color(0xFFFF9800), size: 28),
            SizedBox(width: 10),
            Text(
              'Limite atteinte',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vous avez utilisé tous vos rembobinages autorisés pour ce match.',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.white.withOpacity(0.8), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Informations:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('• Maximum $maxRewinds rembobinages par match',
                      style: TextStyle(color: Colors.white.withOpacity(0.8))),
                  Text('• Utilisés: $usedInGame/$maxRewinds',
                      style: TextStyle(color: Colors.white.withOpacity(0.8))),
                  Text('• Rembobinages totaux: ${AdController.instance.currentRewindCount}',
                      style: TextStyle(color: Colors.white.withOpacity(0.8))),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Vos rembobinages se réinitialiseront au prochain match !',
              style: TextStyle(color: Colors.white.withOpacity(0.9)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Compris', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showEarnRewardDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text(
              'Gagner plus',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showEarnRewardDialog() {
    AdController.instance.showRewardDialog(
      context: context,
      title: 'Gagner des Coins',
      description: 'Regardez une publicité pour gagner ${AdController.instance.rewardCoins} coins !',
      rewardType: 'coins', // Changé de 'rewind' à 'coins'
      rewardAmount: AdController.instance.rewardCoins,
      onRewardEarned: () {
        widget.onStateChanged();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.white),
                  const SizedBox(width: 10),
                  Text('+${AdController.instance.rewardCoins} coins gagnés !'),
                ],
              ),
              backgroundColor: const Color(0xFFFFD700),
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
              backgroundColor: Color(0xFFFF9800),
            ),
          );
        }
      },
    );
  }

  // Nouvelle méthode pour afficher les informations sur les coins
  void _showCoinInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1B6B3A),
        title: Row(
          children: const [
            Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 28),
            SizedBox(width: 10),
            Text(
              'Système de Coins',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comment gagner et utiliser vos coins:',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoItem('🎥 Regarder une pub', '+${AdController.instance.rewardCoins} coins'),
                  _buildInfoItem('🔄 Acheter un rembobinage', '${AdController.instance.rewindCost} coins'),
                  _buildInfoItem('📊 Votre solde', '${AdController.instance.currentCoinCount} coins'),
                  _buildInfoItem('🔄 Rembobinages disponibles', '${AdController.instance.currentRewindCount}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showEarnRewardDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
            ),
            child: const Text(
              'Gagner des Coins',
              style: TextStyle(color: Colors.black),
            ),
          ),
          if (AdController.instance.currentCoinCount >= AdController.instance.rewindCost)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                AdController.instance.showBuyRewindDialog(context);
                widget.onStateChanged();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
              ),
              child: const Text(
                'Acheter Rembobinage',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.9))),
          Text(value,
              style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.bold
              )),
        ],
      ),
    );
  }
}
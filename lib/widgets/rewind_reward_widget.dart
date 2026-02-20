import 'package:happygoal/l10n/app_localizations.dart';
// rewind_reward_widget.dart
import 'package:flutter/material.dart';
import 'package:happygoal/models/game_state.dart';
import 'package:happygoal/screens/game_controller.dart';
import 'package:happygoal/utils/ad_controller.dart';
import 'package:happygoal/constants.dart';
import 'package:happygoal/widgets/coin_shop_dialog.dart'; // ⭐ NOUVEAU : Import de la boutique

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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A3A22),
            const Color(0xFF0A2515),
            const Color(0xFF051108),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Coins section
          _buildCoinSection(coinCount),
          const SizedBox(width: 14),
          Container(
            width: 1.5,
            height: 24,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(width: 14),
          // Rewinds section
          _buildRewindSection(totalRewindCount, remainingForGame),
        ],
      ),
    );
  }

  Widget _buildCoinSection(int coinCount) {
    return GestureDetector(
      onTap: () => _showCoinInfoDialog(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFD700),
                  const Color(0xFFF57F17),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.monetization_on,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$coinCount',
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewindSection(int totalRewindCount, int remainingForGame) {
    return GestureDetector(
      onTap: () {
        if (totalRewindCount > 0 && remainingForGame == 0) {
          _showLimitReachedDialog();
        } else if (totalRewindCount == 0) {
          _showEarnRewardDialog();
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.08),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white
                          .withOpacity(0.2 * _pulseAnimation.value),
                      blurRadius: 8 * _pulseAnimation.value,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.replay,
                  color: Colors.white,
                  size: 16,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Text(
            '$totalRewindCount',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: remainingForGame > 0
                    ? [const Color(0xFF4CAF50), const Color(0xFF2E7D32)]
                    : [Color(0xFFE53935), Color(0xFFC62828)],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: (remainingForGame > 0 ? Colors.green : Colors.red)
                      .withOpacity(0.25),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              '$remainingForGame',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
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
          children: [
            const Icon(Icons.warning, color: Color(0xFFFF9800), size: 28),
            const SizedBox(width: 10),
            Text(
              AppLocalizations.of(context)!.rewindLimitTitle,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.rewindLimitDesc,
              style: const TextStyle(fontSize: 16, color: Colors.white),
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
                        AppLocalizations.of(context)!.rewindLimitInfo,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context)!.rewindLimitMax(maxRewinds.toString()),
                      style: TextStyle(color: Colors.white.withOpacity(0.8))),
                  Text(AppLocalizations.of(context)!.rewindLimitUsed(usedInGame.toString(), maxRewinds.toString()),
                      style: TextStyle(color: Colors.white.withOpacity(0.8))),
                  Text(AppLocalizations.of(context)!.rewindLimitTotal(AdController.instance.currentRewindCount.toString()),
                      style: TextStyle(color: Colors.white.withOpacity(0.8))),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.rewindLimitReset,
              style: TextStyle(color: Colors.white.withOpacity(0.9)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.rewindLimitUnderstood, style: const TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openCoinShop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: Text(
              AppLocalizations.of(context)!.rewindLimitRefill,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showEarnRewardDialog() {
    AdController.instance.showRewardDialog(
        context: context,
        title: AppLocalizations.of(context)!.coinsNeededTitle,
        description: AppLocalizations.of(context)!.coinsNeededDesc(AdController.instance.rewardCoins.toString()),
        rewardType: 'coins',
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
                    Text(AppLocalizations.of(context)!.coinsEarnedSnack(AdController.instance.rewardCoins.toString())),
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
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(AppLocalizations.of(context)!.adUnavailableSnack),
                  ],
                ),
                backgroundColor: const Color(0xFFFF9800),
              ),
            );
          }
        },
        onDeclined: () {
          // Optionnel : ne rien faire ou proposer l'achat
        }
    );
  }

  // Helper pour ouvrir la boutique
  void _openCoinShop() {
    showDialog(
      context: context,
      builder: (context) => const CoinShopDialog(),
    ).then((_) {
      // Rafraîchir l'état au retour de la boutique
      widget.onStateChanged();
    });
  }

  void _showCoinInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1B6B3A),
        title: Row(
          children: [
            const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 28),
            const SizedBox(width: 10),
            Text(
              AppLocalizations.of(context)!.coinSystemTitle,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.coinSystemDesc,
              style: const TextStyle(fontSize: 16, color: Colors.white),
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
                  _buildInfoItem(AppLocalizations.of(context)!.coinSystemBalance, '${AdController.instance.currentCoinCount} coins'),
                  _buildInfoItem(AppLocalizations.of(context)!.coinSystemRewindCost, '${AdController.instance.rewindCost} coins'),
                  const Divider(color: Colors.white30),
                  _buildInfoItem(AppLocalizations.of(context)!.coinSystemAdReward, '+${AdController.instance.rewardCoins} coins'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _showEarnRewardDialog();
            },
            icon: const Icon(Icons.play_circle_fill, color: Colors.white),
            label: Text(AppLocalizations.of(context)!.freeAdButton, style: const TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openCoinShop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
            ),
            child: Text(AppLocalizations.of(context)!.buyCoinsButton),
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
              child: Text(
                AppLocalizations.of(context)!.buyRewindButton,
                style: const TextStyle(color: Colors.white),
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
import 'package:flutter/material.dart';
import 'package:happygoal/screens/tutorial_settings_screen.dart';
import 'package:happygoal/screens/achievements_screen.dart';
import 'package:happygoal/constants.dart';
import 'package:happygoal/utils/responsive_helper.dart';
import 'package:happygoal/widgets/tutorial_overlay.dart';
import 'mode_selection_screen.dart';
import 'package:happygoal/widgets/audiosettings_widget.dart';
import 'package:happygoal/utils/analytics_service.dart';
import 'package:happygoal/utils/ad_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:happygoal/widgets/tutorial_mixin.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:happygoal/widgets/coin_shop_dialog.dart';
import 'dart:math' as math;
import 'package:happygoal/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// ANIMATION: Ballon flottant
// ---------------------------------------------------------------------------

class FloatingBallWidget extends StatefulWidget {
  const FloatingBallWidget({Key? key}) : super(key: key);

  @override
  State<FloatingBallWidget> createState() => _FloatingBallWidgetState();
}

class _FloatingBallWidgetState extends State<FloatingBallWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _float;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _float = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _rotate = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _float.value),
          child: Transform.rotate(
            angle: _rotate.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFE8F5E9)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
            BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: const Center(
          child: Text('⚽', style: TextStyle(fontSize: 65)),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ANIMATION: Particules de fond
// ---------------------------------------------------------------------------

class _Particle {
  late double x, y, radius, opacity, speed;
  _Particle(double w, double h) {
    final rng = math.Random();
    x = rng.nextDouble() * w;
    y = rng.nextDouble() * h;
    radius = 1 + rng.nextDouble() * 3;
    opacity = 0.1 + rng.nextDouble() * 0.25;
    speed = 0.2 + rng.nextDouble() * 0.5;
  }
}

class ParticlesPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;

  ParticlesPainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      final dy = (p.y - progress * p.speed * size.height) % size.height;
      paint.color = Colors.white.withOpacity(p.opacity);
      canvas.drawCircle(Offset(p.x, dy), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter old) => old.progress != progress;
}

// ---------------------------------------------------------------------------
// BOUTON JOUER PRINCIPAL
// ---------------------------------------------------------------------------

class PlayButton extends StatefulWidget {
  final VoidCallback onPressed;
  const PlayButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.5 * _glow.value),
                blurRadius: 30 * _glow.value,
                spreadRadius: 4 * _glow.value,
              ),
            ],
          ),
          child: child,
        );
      },
      child: SizedBox(
        width: double.infinity,
        height: ResponsiveHelper.scale(context, 72),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFF57F17)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sports_soccer, color: Colors.white, size: ResponsiveHelper.scale(context, 28)),
                  SizedBox(width: ResponsiveHelper.scale(context, 12)),
                  Text(
                    AppLocalizations.of(context)!.playButton,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.textScale(context, 24),
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ECRAN PRINCIPAL
// ---------------------------------------------------------------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TutorialMixin, SingleTickerProviderStateMixin {
  final GlobalKey _playButtonKey = GlobalKey();
  final GlobalKey _rulesButtonKey = GlobalKey();
  final GlobalKey _settingsButtonKey = GlobalKey();
  final GlobalKey _rewardButtonKey = GlobalKey();
  final GlobalKey _inviteButtonKey = GlobalKey();
  final GlobalKey _coinBalanceKey = GlobalKey();
  final GlobalKey _achievementsButtonKey = GlobalKey();

  late AnimationController _particleCtrl;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    AdController.instance.initialize();

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      _particles = List.generate(40, (_) => _Particle(size.width, size.height));
      showTutorialIfNeeded('home_screen', _createTutorialSteps());
    });
  }

  List<TutorialStep> _createTutorialSteps() {
    return [
      TutorialStep(
        title: AppLocalizations.of(context)!.welcomeMessage,
        description: AppLocalizations.of(context)!.startAdventure,
        targetKey: _playButtonKey,
        position: TutorialPosition.top,
        customContent: Column(
          children: [
            const Icon(Icons.sports_soccer, size: 50, color: Colors.blue),
            const SizedBox(height: 10),
            Text(AppLocalizations.of(context)!.startAdventure,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      TutorialStep(
        title: AppLocalizations.of(context)!.shop,
        description: AppLocalizations.of(context)!.shopDescription,
        targetKey: _coinBalanceKey,
        position: TutorialPosition.bottom,
      ),
      TutorialStep(
        title: AppLocalizations.of(context)!.dailyGift,
        description: AppLocalizations.of(context)!.dailyGiftDescription,
        targetKey: _rewardButtonKey,
        position: TutorialPosition.top,
      ),
      TutorialStep(
        title: AppLocalizations.of(context)!.achievements,
        description: AppLocalizations.of(context)!.achievementsDescription,
        targetKey: _achievementsButtonKey,
        position: TutorialPosition.top,
      ),
    ];
  }

  @override
  void dispose() {
    _particleCtrl.dispose();
    super.dispose();
  }

  void _navigateToAchievements() {
    AnalyticsService.logAdEvent('achievements_screen');
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, animation, __) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: const AchievementsScreen(),
        ),
      ),
    );
  }

  void _inviteFriends() {
    AnalyticsService.logAdEvent('invite_friends');
    final String shareText = AppLocalizations.of(context)!.inviteShareText;
    Share.share(shareText, subject: AppLocalizations.of(context)!.inviteShareSubject);
  }

  void _rateApp() async {
    AnalyticsService.logAdEvent('rate_app');
    final uri = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.heyhappy.happygoal');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  // ---- BUILD ----

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fond dégradé profond
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary, AppColors.fieldGreen, Color(0xFF0F4A2D)],
                  stops: [0.0, 0.5, 1.0],

              ),
            ),
          ),

          // Particules animées
          AnimatedBuilder(
            animation: _particleCtrl,
            builder: (context, _) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: ParticlesPainter(
                  progress: _particleCtrl.value,
                  particles: _particles.isNotEmpty
                      ? _particles
                      : [],
                ),
              );
            },
          ),

          // Cercle décoratif en haut
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),

          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4CAF50).withOpacity(0.07),
              ),
            ),
          ),

          // Contenu
          SafeArea(
            child: Column(
              children: [
                // ── TOP BAR ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTopChip(
                        key: _achievementsButtonKey,
                        icon: Icons.emoji_events,
                        label: AppLocalizations.of(context)!.achievements,
                        gradient: const [Color(0xFFFFD700), Color(0xFFFFA000)],
                        onTap: _navigateToAchievements,
                      ),
                      _buildCoinChip(),
                    ],
                  ),
                ),

                // ── HERO SECTION ─────────────────────────────────────
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FloatingBallWidget(),
                      const SizedBox(height: 28),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.white, Color(0xFFB9F6CA)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds),
                        child: Text(
                          AppLocalizations.of(context)!.appTitle,
                          style: const TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.55),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── ACTIONS ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
                  child: Column(
                    children: [
                      // BOUTON JOUER
                      PlayButton(
                        key: _playButtonKey,
                        onPressed: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 300),
                              pageBuilder: (_, animation, __) => SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: const ModeSelectionScreen(),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // GRILLE DE BOUTONS SECONDAIRES
                      Row(
                        children: [
                          Expanded(
                            child: _buildIconAction(
                              key: _rewardButtonKey,
                              icon: Icons.card_giftcard,
                              label: AppLocalizations.of(context)!.dailyGift,
                              color: const Color(0xFFE2FD31),
                              onTap: _showEarnRewardDialog,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildIconAction(
                              key: _inviteButtonKey,
                              icon: Icons.group_add,
                              label: AppLocalizations.of(context)!.invite,
                              color: const Color(0xFFBCF1A4),
                              onTap: _inviteFriends,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildIconAction(
                              key: _rulesButtonKey,
                              icon: Icons.menu_book,
                              label: AppLocalizations.of(context)!.rules,
                              color: const Color(0xFFFFFFFF),
                              onTap: () => _showRulesDialog(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildIconAction(
                              key: _settingsButtonKey,
                              icon: Icons.tune,
                              label: AppLocalizations.of(context)!.settings,
                              color: const Color(0xDBD15959),
                              onTap: () => _showSettingsDialog(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── WIDGETS HELPERS ────────────────────────────────────────────────────────

  /// Chip en haut de l'écran (Succès / Coins)
  Widget _buildTopChip({
    Key? key,
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinChip() {
    return GestureDetector(
      key: _coinBalanceKey,
      onTap: () => _showCoinInfoDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🪙', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              '${AdController.instance.currentCoinCount}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Color(0xFFFFD700),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.black, size: 10),
            ),
          ],
        ),
      ),
    );
  }

  /// Bouton icône carré pour la grille secondaire
  Widget _buildIconAction({
    Key? key,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── DIALOGS ────────────────────────────────────────────────────────────────

  void _showCoinInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF1B2A1E),
        title: Row(
          children: [
            const Text('🪙', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            Text(AppLocalizations.of(context)!.coinInfoTitle, style: const TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCoinInfoItem(AppLocalizations.of(context)!.coinInfoBalance, '${AdController.instance.currentCoinCount} coins'),
            _buildCoinInfoItem(AppLocalizations.of(context)!.coinInfoAdReward, '+${AdController.instance.rewardCoins} coins'),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.coinInfoShopUseCoins,
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showEarnRewardDialog();
            },
            icon: const Icon(Icons.play_circle, color: Colors.white70),
            label: Text(AppLocalizations.of(context)!.coinInfoShopPubFree, style: const TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => const CoinShopDialog(),
              ).then((_) => setState(() {}));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(AppLocalizations.of(context)!.coinInfoShop, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinInfoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          Text(value,
              style: const TextStyle(
                  color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showEarnRewardDialog() {
    AdController.instance.showRewardDialog(
      context: context,
      title: AppLocalizations.of(context)!.coinInfoShopGift,
      description: AppLocalizations.of(context)!.coinInfoShopGiftDesc(AdController.instance.rewardCoins),
      rewardType: 'coins',
      rewardAmount: AdController.instance.rewardCoins,
      onRewardEarned: () {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.card_giftcard, color: Colors.white),
              const SizedBox(width: 10),
              Text(AppLocalizations.of(context)!.coinInfoShopAdded(AdController.instance.rewardCoins)),
            ]),
            backgroundColor: Colors.green,
          ),
        );
      },
      onAdFailed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.coinInfoShopUnavailable),
            backgroundColor: Colors.orange,
          ),
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF1B2A1E),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                  ),
                ),
                child:  Row(
                  children: [
                    Icon(Icons.tune, color: Colors.white),
                    SizedBox(width: 12),
                    Text(AppLocalizations.of(context)!.settingsOptions,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const AudioSettingsWidget(),
                    const SizedBox(height: 15),
                    const TutorialSettingsWidget(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white12,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(AppLocalizations.of(context)!.settingsClose,
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF1B2A1E),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                gradient: LinearGradient(
                  colors: [Color(0xFF00695C), Color(0xFF00897B)],
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.menu_book, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(AppLocalizations.of(context)!.rulesTitle,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ruleItem('1', AppLocalizations.of(context)!.rules1),
                  _ruleItem('2', AppLocalizations.of(context)!.rules2),
                  _ruleItem('3', AppLocalizations.of(context)!.rules3),
                  _ruleItem('4', AppLocalizations.of(context)!.rules4),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00897B),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(AppLocalizations.of(context)!.rulesUnderstood,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ruleItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFF00897B),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(number,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
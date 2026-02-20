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
import 'package:provider/provider.dart';
import 'package:happygoal/l10n/locale_provider.dart';

// ---------------------------------------------------------------------------
// ANIMATION: Ballon flottant — style Hero
// ---------------------------------------------------------------------------

class FloatingBallWidget extends StatefulWidget {
  const FloatingBallWidget({Key? key}) : super(key: key);

  @override
  State<FloatingBallWidget> createState() => _FloatingBallWidgetState();
}

class _FloatingBallWidgetState extends State<FloatingBallWidget>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _glowController;
  late Animation<double> _float;
  late Animation<double> _rotate;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _float = Tween<double>(begin: -12, end: 12).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _rotate = Tween<double>(begin: -0.04, end: 0.04).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _glow = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatController, _glowController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _float.value),
          child: Transform.rotate(
            angle: _rotate.value,
            child: Container(
              width: ResponsiveHelper.scale(context, 130),
              height: ResponsiveHelper.scale(context, 130),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white,
                    const Color(0xFFE8F5E9),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 35,
                    offset: const Offset(0, 18),
                  ),
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.45 * _glow.value),
                    blurRadius: 40 * _glow.value,
                    spreadRadius: 6 * _glow.value,
                  ),
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.15 * _glow.value),
                    blurRadius: 60 * _glow.value,
                    spreadRadius: 10 * _glow.value,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '⚽',
                  style: TextStyle(fontSize: ResponsiveHelper.scale(context, 70)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// ANIMATION: Particules stylisées
// ---------------------------------------------------------------------------

class _Particle {
  late double x, y, radius, opacity, speed, angle;
  _Particle(double w, double h) {
    final rng = math.Random();
    x = rng.nextDouble() * w;
    y = rng.nextDouble() * h;
    radius = 0.5 + rng.nextDouble() * 2.5;
    opacity = 0.08 + rng.nextDouble() * 0.22;
    speed = 0.15 + rng.nextDouble() * 0.4;
    angle = rng.nextDouble() * math.pi * 2;
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
      final dx = p.x + math.sin(progress * math.pi * 2 + p.angle) * 8;
      paint.color = Colors.white.withOpacity(p.opacity);
      canvas.drawCircle(Offset(dx % size.width, dy), p.radius, paint);
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
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.55, end: 1.0).animate(
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
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.55 * _glow.value),
                blurRadius: 32 * _glow.value,
                spreadRadius: 3 * _glow.value,
              ),
            ],
          ),
          child: child,
        );
      },
      child: SizedBox(
        width: double.infinity,
        height: ResponsiveHelper.scale(context, 68),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFF57F17)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sports_soccer,
                      color: Colors.white,
                      size: ResponsiveHelper.scale(context, 26),
                      shadows: const [
                        Shadow(color: Colors.black26, blurRadius: 8),
                      ],
                    ),
                    SizedBox(width: ResponsiveHelper.scale(context, 12)),
                    Text(
                      AppLocalizations.of(context)!.playButton,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.textScale(context, 20),
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 4,
                        shadows: const [
                          Shadow(color: Colors.black26, blurRadius: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ÉCRAN PRINCIPAL
// ---------------------------------------------------------------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TutorialMixin, TickerProviderStateMixin {
  final GlobalKey _playButtonKey = GlobalKey();
  final GlobalKey _rulesButtonKey = GlobalKey();
  final GlobalKey _settingsButtonKey = GlobalKey();
  final GlobalKey _rewardButtonKey = GlobalKey();
  final GlobalKey _inviteButtonKey = GlobalKey();
  final GlobalKey _coinBalanceKey = GlobalKey();
  final GlobalKey _achievementsButtonKey = GlobalKey();

  late AnimationController _particleCtrl;
  late AnimationController _entryController;
  late List<_Particle> _particles;

  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    AdController.instance.initialize();

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fadeIn = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        _particles = List.generate(50, (_) => _Particle(size.width, size.height));
      });
      Future.delayed(Duration.zero, () {
        if (mounted) {
          showTutorialIfNeeded('home_screen', _createTutorialSteps());
        }
      });
    });
  }

  List<TutorialStep> _createTutorialSteps() {
    return [
      TutorialStep(
        title: AppLocalizations.of(context)!.welcomeMessage,
        description: AppLocalizations.of(context)!.startAdventure,
        targetKey: _playButtonKey,
        position: TutorialPosition.top,
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
    _entryController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Fond dégradé profond cohérent avec Hero screens ──────────
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

          // ── Cercles décoratifs en arrière-plan ───────────────────────
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4CAF50).withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD700).withOpacity(0.04),
              ),
            ),
          ),

          // ── Ligne de terrain décoration ───────────────────────────────
          CustomPaint(
            size: Size.infinite,
            painter: _FieldDecorationPainter(),
          ),

          // ── Particules animées ────────────────────────────────────────
          AnimatedBuilder(
            animation: _particleCtrl,
            builder: (context, _) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: ParticlesPainter(
                  progress: _particleCtrl.value,
                  particles: _particles.isNotEmpty ? _particles : [],
                ),
              );
            },
          ),

          // ── Contenu principal ─────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Column(
                  children: [
                    // ── TOP BAR ─────────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.scale(context, 20),
                        vertical: ResponsiveHelper.scale(context, 14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildAchievementsChip(),
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
                          SizedBox(height: ResponsiveHelper.scale(context, 24)),

                          // Titre principal
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.white, Color(0xFFB9F6CA)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                            child: Text(
                              AppLocalizations.of(context)!.appTitle,
                              style: TextStyle(
                                fontSize: ResponsiveHelper.textScale(context, 48),
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2,
                                shadows: const [
                                  Shadow(color: Colors.black38, blurRadius: 20),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.scale(context, 8)),

                          // Sous-titre badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.scale(context, 20),
                              vertical: ResponsiveHelper.scale(context, 6),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.12)),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.subtitle,
                              style: TextStyle(
                                fontSize: ResponsiveHelper.textScale(context, 13),
                                color: Colors.white54,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── ACTIONS ──────────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        ResponsiveHelper.scale(context, 24),
                        0,
                        ResponsiveHelper.scale(context, 24),
                        ResponsiveHelper.scale(context, 8),
                      ),
                      child: Column(
                        children: [
                          // BOUTON JOUER
                          PlayButton(
                            key: _playButtonKey,
                            onPressed: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  transitionDuration:
                                  const Duration(milliseconds: 300),
                                  pageBuilder: (_, animation, __) =>
                                      SlideTransition(
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

                          SizedBox(height: ResponsiveHelper.scale(context, 16)),

                          // GRILLE BOUTONS SECONDAIRES
                          Row(
                            children: [
                              Expanded(
                                child: _buildIconAction(
                                  key: _rewardButtonKey,
                                  icon: Icons.card_giftcard_rounded,
                                  label: AppLocalizations.of(context)!.dailyGift,
                                  color: const Color(0xFFFFD700),
                                  onTap: _showEarnRewardDialog,
                                ),
                              ),
                              SizedBox(width: ResponsiveHelper.scale(context, 10)),
                              Expanded(
                                child: _buildIconAction(
                                  key: _inviteButtonKey,
                                  icon: Icons.group_add_rounded,
                                  label: AppLocalizations.of(context)!.invite,
                                  color: const Color(0xFF4CAF50),
                                  onTap: _inviteFriends,
                                ),
                              ),
                              SizedBox(width: ResponsiveHelper.scale(context, 10)),
                              Expanded(
                                child: _buildIconAction(
                                  key: _rulesButtonKey,
                                  icon: Icons.menu_book_rounded,
                                  label: AppLocalizations.of(context)!.rules,
                                  color: const Color(0xFF2196F3),
                                  onTap: () => _showRulesDialog(context),
                                ),
                              ),
                              SizedBox(width: ResponsiveHelper.scale(context, 10)),
                              Expanded(
                                child: _buildIconAction(
                                  key: _settingsButtonKey,
                                  icon: Icons.tune_rounded,
                                  label: AppLocalizations.of(context)!.settings,
                                  color: const Color(0xFFFF7043),
                                  onTap: () => _showSettingsDialog(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: ResponsiveHelper.scale(context, 20)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── WIDGET HELPERS ────────────────────────────────────────────────────────

  Widget _buildAchievementsChip() {
    return GestureDetector(
      key: _achievementsButtonKey,
      onTap: _navigateToAchievements,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.scale(context, 14),
          vertical: ResponsiveHelper.scale(context, 9),
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFF57F17)],
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.4),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events_rounded,
                color: Colors.white,
                size: ResponsiveHelper.scale(context, 18)),
            SizedBox(width: ResponsiveHelper.scale(context, 6)),
            Text(
              AppLocalizations.of(context)!.achievements,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveHelper.textScale(context, 13),
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
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.scale(context, 14),
          vertical: ResponsiveHelper.scale(context, 9),
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🪙',
                style: TextStyle(fontSize: ResponsiveHelper.scale(context, 16))),
            SizedBox(width: ResponsiveHelper.scale(context, 6)),
            Text(
              '${AdController.instance.currentCoinCount}',
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveHelper.textScale(context, 15),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: ResponsiveHelper.scale(context, 6)),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Color(0xFFFFD700),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add,
                  color: Colors.black,
                  size: ResponsiveHelper.scale(context, 10)),
            ),
          ],
        ),
      ),
    );
  }

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
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.scale(context, 16),
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(ResponsiveHelper.scale(context, 18)),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: ResponsiveHelper.scale(context, 24)),
            SizedBox(height: ResponsiveHelper.scale(context, 6)),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: ResponsiveHelper.textScale(context, 11),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
      builder: (context) => _buildStyledDialog(
        title: Row(
          children: [
            const Text('🪙', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Text(AppLocalizations.of(context)!.coinInfoTitle,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoRow(
                AppLocalizations.of(context)!.coinInfoBalance,
                '${AdController.instance.currentCoinCount} coins'),
            _buildInfoRow(
                AppLocalizations.of(context)!.coinInfoAdReward,
                '+${AdController.instance.rewardCoins} coins'),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.coinInfoShopUseCoins,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.55), fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          _buildDialogTextButton(
            label: AppLocalizations.of(context)!.coinInfoShopPubFree,
            icon: Icons.play_circle_outline_rounded,
            onTap: () {
              Navigator.pop(context);
              _showEarnRewardDialog();
            },
          ),
          _buildDialogPrimaryButton(
            label: AppLocalizations.of(context)!.coinInfoShop,
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => const CoinShopDialog(),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white60, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ],
      ),
    );
  }

  void _showEarnRewardDialog() {
    AdController.instance.showRewardDialog(
      context: context,
      title: AppLocalizations.of(context)!.coinInfoShopGift,
      description: AppLocalizations.of(context)!
          .coinInfoShopGiftDesc(AdController.instance.rewardCoins),
      rewardType: 'coins',
      rewardAmount: AdController.instance.rewardCoins,
      onRewardEarned: () {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.card_giftcard, color: Colors.white),
              const SizedBox(width: 10),
              Text(AppLocalizations.of(context)!
                  .coinInfoShopAdded(AdController.instance.rewardCoins)),
            ]),
            backgroundColor: const Color(0xFF2E7D32),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onAdFailed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text(AppLocalizations.of(context)!.coinInfoShopUnavailable),
            backgroundColor: Colors.orange.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A3A22), Color(0xFF0A1A0F)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 10)),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                    ),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tune_rounded, color: Colors.white),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context)!.settingsOptions,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Langue
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.language_rounded,
                                color: Color(0xFF4CAF50), size: 20),
                            const SizedBox(width: 10),
                            Text(
                              AppLocalizations.of(context)!.language,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                            const Spacer(),
                            Builder(
                              builder: (context) {
                                final localeProvider =
                                Provider.of<LocaleProvider>(context);
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<Locale>(
                                      value: localeProvider.locale,
                                      dropdownColor:
                                      const Color(0xFF1A3A22),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14),
                                      iconEnabledColor: Colors.white54,
                                      items: const [
                                        DropdownMenuItem(
                                          value: Locale('fr'),
                                          child: Text('Français'),
                                        ),
                                        DropdownMenuItem(
                                          value: Locale('en'),
                                          child: Text('English'),
                                        ),
                                      ],
                                      onChanged: (Locale? locale) {
                                        if (locale != null) {
                                          localeProvider.setLocale(locale);
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const AudioSettingsWidget(),
                      const SizedBox(height: 14),
                      const TutorialSettingsWidget(),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.white.withOpacity(0.08),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                  color: Colors.white.withOpacity(0.12)),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.settingsClose,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _buildStyledDialog(
        title: Row(
          children: [
            const Icon(Icons.menu_book_rounded, color: Color(0xFF4CAF50)),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.rulesTitle,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ruleItem('1', AppLocalizations.of(context)!.rules1),
            _ruleItem('2', AppLocalizations.of(context)!.rules2),
            _ruleItem('3', AppLocalizations.of(context)!.rules3),
            _ruleItem('4', AppLocalizations.of(context)!.rules4),
          ],
        ),
        actions: [
          _buildDialogPrimaryButton(
            label: AppLocalizations.of(context)!.rulesUnderstood,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledDialog({
    required Widget title,
    required Widget content,
    required List<Widget> actions,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A3A22), Color(0xFF0A1A0F)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                offset: const Offset(0, 10)),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title,
            const SizedBox(height: 20),
            content,
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions
                  .map((w) => Padding(
                  padding: const EdgeInsets.only(left: 8), child: w))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogTextButton(
      {required String label,
        required IconData icon,
        required VoidCallback onTap}) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white54, size: 16),
      label: Text(label,
          style: const TextStyle(color: Colors.white54, fontSize: 13)),
    );
  }

  Widget _buildDialogPrimaryButton(
      {required String label, required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFD700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold)),
    );
  }

  Widget _ruleItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFF57F17)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(number,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

// ── Painter terrain décoratif ────────────────────────────────────────────────

class _FieldDecorationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Cercle central
    canvas.drawCircle(
        Offset(size.width / 2, size.height * 0.65), size.width * 0.22, paint);

    // Ligne médiane
    canvas.drawLine(Offset(0, size.height * 0.65),
        Offset(size.width, size.height * 0.65), paint);

    // Surface de réparation en bas
    final goalRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.95),
          width: size.width * 0.55,
          height: 70),
      const Radius.circular(12),
    );
    canvas.drawRRect(goalRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
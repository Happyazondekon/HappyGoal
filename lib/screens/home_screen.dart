import 'package:flutter/material.dart';
import 'package:happygoal/screens/tutorial_settings_screen.dart';
import '../constants.dart';
import '../widgets/tutorial_overlay.dart';
import 'mode_selection_screen.dart';
import '../widgets/audiosettings_widget.dart';
import '../utils/analytics_service.dart';
import '../utils/ad_controller.dart';
import 'package:flutter/foundation.dart';
import '../widgets/tutorial_mixin.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/coin_shop_dialog.dart'; // ⭐ NOUVEAU : Import de la boutique

// --- WIDGETS D'ANIMATION (Modifiés pour Noël) ---

class PulsatingButton extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final Duration duration;

  const PulsatingButton({
    Key? key,
    required this.child,
    this.glowColor = Colors.white,
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  _PulsatingButtonState createState() => _PulsatingButtonState();
}

class _PulsatingButtonState extends State<PulsatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
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
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(0.6 * _animation.value),
                spreadRadius: 4 * _animation.value,
                blurRadius: 15 * _animation.value,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

// Transformé en flocon de neige (tombe vers le bas)
class SnowParticle extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const SnowParticle({
    Key? key,
    this.size = 4.0,
    this.color = Colors.white,
    this.duration = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  _SnowParticleState createState() => _SnowParticleState();
}

class _SnowParticleState extends State<SnowParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    // La neige tombe (de -0.2 à 1.2 pour traverser l'écran)
    _animation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: const Offset(0, 1.2),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear, // Chute constante
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 2,
                spreadRadius: 1,
              )
            ]
        ),
      ),
    );
  }
}

// --- ECRAN PRINCIPAL ---

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TutorialMixin {
  final GlobalKey _playButtonKey = GlobalKey();
  final GlobalKey _rulesButtonKey = GlobalKey();
  final GlobalKey _settingsButtonKey = GlobalKey();
  final GlobalKey _rewardButtonKey = GlobalKey();
  final GlobalKey _inviteButtonKey = GlobalKey();
  final GlobalKey _coinBalanceKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    AdController.instance.initialize();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showTutorialIfNeeded('home_screen', _createTutorialSteps());
    });
  }

  List<TutorialStep> _createTutorialSteps() {
    return [
      TutorialStep(
        title: 'Joyeux Noël sur HappyGoal ! 🎄',
        description: 'Découvrez notre édition festive ! Prêt pour des tirs au but sous la neige ?',
        targetKey: _playButtonKey,
        position: TutorialPosition.top,
        customContent: Column(
          children: [
            const Icon(Icons.snowboarding, size: 50, color: Colors.blue), // Icône festive
            const SizedBox(height: 10),
            const Text(
              'Prêt à marquer ?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      TutorialStep(
        title: 'Boutique de Noël 🎁',
        description: 'Vos coins sont ici. Touchez pour ouvrir la boutique et faire le plein !',
        targetKey: _coinBalanceKey,
        position: TutorialPosition.bottom,
      ),
      TutorialStep(
        title: 'Cadeau Quotidien',
        description: 'Récupérez votre cadeau de Noël (coins gratuits) ici !',
        targetKey: _rewardButtonKey,
        position: TutorialPosition.top,
      ),
    ];
  }

  void _inviteFriends() {
    AnalyticsService.logAdEvent('invite_friends');
    final String shareText =
        '🎄 Spécial Noël sur HappyGoal ! ⚽\n\n'
        'Viens tirer des penalties sous la neige et défie-moi !\n'
        '🎁 Bonus de fêtes actifs\n'
        'Télécharge maintenant : https://play.google.com/store/apps/details?id=com.heyhappy.happygoal';
    Share.share(shareText, subject: 'HappyGoal: Édition de Noël 🎅');
  }

  void _rateApp() async {
    AnalyticsService.logAdEvent('rate_app');
    final String url = 'https://play.google.com/store/apps/details?id=com.heyhappy.happygoal';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Arrière-plan Noël (Dégradé Vert Sapin -> Rouge Noël)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F3622),  // Vert sapin très foncé (Nuit)
                  Color(0xFF1B5E20),  // Vert sapin
                  Color(0xFF8F2525),  // Rouge foncé bas (Sol/Fête)
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),

          // 2. Neige qui tombe (Particules)
          ...List.generate(30, (index) {
            return Positioned(
              left: (index * 13.0 * index) % screenWidth,
              top: (index * 20.0) % (screenHeight / 2), // Départ aléatoire haut
              child: SnowParticle(
                size: 2.0 + (index % 4), // Flocons de tailles différentes
                color: Colors.white.withOpacity(0.6 + (index % 4) * 0.1),
                duration: Duration(seconds: 4 + (index % 5)),
              ),
            );
          }),

          // 3. Lignes de terrain (Subtiles)
          CustomPaint(
            size: Size(screenWidth, screenHeight),
            painter: FieldLinesPainter(),
          ),

          // 4. Contenu principal
          SafeArea(
            child: Column(
              children: [
                // --- HEADER ---
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo avec touche festive
                              TweenAnimationBuilder(
                                duration: const Duration(seconds: 2),
                                tween: Tween<double>(begin: 0, end: 1),
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: 0.8 + (0.2 * value),
                                    child: Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        Container(
                                          width: 140,
                                          height: 140,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: const LinearGradient(
                                              colors: [Colors.white, Color(0xFFF0F0F0)],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFC62828).withOpacity(0.5), // Lueur rouge
                                                blurRadius: 25,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: const Center(
                                            child: Text('⚽', style: TextStyle(fontSize: 70)),
                                          ),
                                        ),
                                        // Petit bonnet de noël (emoji)
                                        const Positioned(
                                          right: 10,
                                          top: -5,
                                          child: Text('🎅', style: TextStyle(fontSize: 50)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 25),

                              // Titre HappyGoal
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Colors.white, Color(0xFFFFEBEE)],
                                ).createShader(bounds),
                                child: const Text(
                                  'HappyGoal',
                                  style: TextStyle(
                                    fontSize: 52,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                    fontFamily: "Roboto",
                                    shadows: [
                                      Shadow(color: Color(0xFFB71C1C), blurRadius: 15),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Sous-titre Edition Noël
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC62828).withOpacity(0.8), // Rouge Noël
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white30),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.ac_unit, color: Colors.white, size: 16),
                                    SizedBox(width: 8),
                                    Text(
                                      'ÉDITION FÊTES DE FIN D\'ANNÉE',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.ac_unit, color: Colors.white, size: 16),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Solde Coins
                        Positioned(
                          top: 10,
                          right: 20,
                          child: _buildCoinBalance(context),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- BOUTONS ---
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Bouton JOUER (Vert sapin avec lueur dorée)
                        PulsatingButton(
                          key: _playButtonKey,
                          glowColor: const Color(0xFFFFD700), // Or
                          child: _buildModernButton(
                            context,
                            icon: Icons.sports_soccer,
                            text: 'JOUER',
                            isPrimary: true,
                            onPressed: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  transitionDuration: const Duration(milliseconds: 300),
                                  pageBuilder: (_, animation, __) => SlideTransition(
                                    position: Tween<Offset>(begin: const Offset(1,0), end: Offset.zero).animate(animation),
                                    child: const ModeSelectionScreen(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Boutons secondaires
                        Row(
                          children: [
                            Expanded(
                              child: _buildSecondaryButton(
                                context,
                                key: _rulesButtonKey,
                                icon: Icons.menu_book,
                                text: 'RÈGLES',
                                onPressed: () => _showRulesDialog(context),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildSecondaryButton(
                                context,
                                key: _settingsButtonKey,
                                icon: Icons.settings_suggest,
                                text: 'OPTIONS',
                                onPressed: () => _showSettingsDialog(context),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Inviter
                        _buildInviteButton(context, key: _inviteButtonKey),

                        const SizedBox(height: 20),

                        // Cadeau Noël (Récompense)
                        _buildRewardButton(context, key: _rewardButtonKey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DÉTAILLÉS ---

  Widget _buildInviteButton(BuildContext context, {Key? key}) {
    return Container(
      key: key,
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _inviteFriends,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1565C0), // Bleu glace
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: const BorderSide(color: Colors.white30, width: 1),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send, size: 18),
            SizedBox(width: 10),
            Text('INVITER UN AMI', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // Bouton Solde (Ouvre le menu coins)
  Widget _buildCoinBalance(BuildContext context) {
    return GestureDetector(
      key: _coinBalanceKey,
      onTap: () => _showCoinInfoDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA000)], // Or festif
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.monetization_on, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              '${AdController.instance.currentCoinCount}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black45, blurRadius: 2, offset: Offset(1,1))],
              ),
            ),
            // Petit badge "+"
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.white, size: 12),
            )
          ],
        ),
      ),
    );
  }

  // Dialogue Coins + Boutique
  void _showCoinInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF0F3622), // Fond vert foncé
        title: Row(
          children: const [
            Icon(Icons.storefront, color: Color(0xFFFFD700), size: 30),
            SizedBox(width: 10),
            Text('Trésorerie', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                children: [
                  _buildCoinInfoItem('💰 Votre Solde', '${AdController.instance.currentCoinCount} coins'),
                  _buildCoinInfoItem('🎁 Gain Pub', '+${AdController.instance.rewardCoins} coins'),
                ],
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Utilisez vos coins pour acheter des rembobinages et sauver vos matchs !',
              style: TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          // Bouton Pub
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showEarnRewardDialog();
            },
            icon: const Icon(Icons.play_circle, color: Colors.white),
            label: const Text('Pub Gratuit', style: TextStyle(color: Colors.white)),
          ),

          // ⭐ BOUTON BOUTIQUE IAP
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => const CoinShopDialog(),
              ).then((_) => setState((){})); // Rafraichir au retour
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)),
            child: const Text('OUVRIR LA BOUTIQUE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
          Text(value, style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Dialogue Pub
  void _showEarnRewardDialog() {
    AdController.instance.showRewardDialog(
      context: context,
      title: 'Cadeau de Noël 🎁',
      description: 'Regardez une vidéo festive pour gagner ${AdController.instance.rewardCoins} coins !',
      rewardType: 'coins',
      rewardAmount: AdController.instance.rewardCoins,
      onRewardEarned: () {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.card_giftcard, color: Colors.white),
              const SizedBox(width: 10),
              Text('+${AdController.instance.rewardCoins} coins ajoutés ! Ho Ho Ho !'),
            ]),
            backgroundColor: Colors.green,
          ),
        );
      },
      onAdFailed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le traîneau publicitaire est en retard...'), backgroundColor: Colors.orange),
        );
      },
    );
  }

  // Bouton Récompense (Design Noël)
  Widget _buildRewardButton(BuildContext context, {Key? key}) {
    return Container(
      key: key,
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => _showEarnRewardDialog(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC62828), // Rouge Noël
          foregroundColor: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFFFD700), width: 2), // Bordure Or
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.card_giftcard, size: 24, color: Color(0xFFFFD700)),
            const SizedBox(width: 10),
            Text(
              AdController.instance.isRewardedAvailable
                  ? 'CADEAU DE NOËL (+${AdController.instance.rewardCoins})'
                  : 'COINS',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernButton(
      BuildContext context, {
        required IconData icon,
        required String text,
        required VoidCallback onPressed,
        bool isPrimary = false,
      }) {
    return Container(
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? const Color(0xFF2E7D32) // Vert Sapin
              : Colors.white.withOpacity(0.15),
          foregroundColor: Colors.white,
          elevation: isPrimary ? 8 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: BorderSide(
              color: isPrimary ? const Color(0xFF66BB6A) : Colors.white30,
              width: isPrimary ? 2 : 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 15),
            Text(
              text,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
      BuildContext context, {
        Key? key,
        required IconData icon,
        required String text,
        required VoidCallback onPressed,
      }) {
    return Container(
      key: key,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black.withOpacity(0.3),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.white24),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 4),
            Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                    gradient: LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)]),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.settings, color: Colors.white),
                      SizedBox(width: 15),
                      Text('Paramètres', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
                          backgroundColor: Colors.grey[800],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Fermer', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                    gradient: LinearGradient(colors: [Color(0xFFC62828), Color(0xFFE53935)]),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.rule, color: Colors.white),
                      SizedBox(width: 15),
                      Text('Règles du Jeu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('1. Choisissez une direction pour tirer.\n2. Le gardien plonge aléatoirement.\n3. Marquez 5 buts pour gagner !\n4. Utilisez les rembobinages si vous ratez.'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Compris !'),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Painter pour les lignes du terrain (inchangé mais nécessaire)
class FieldLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 60, paint);
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(size.width / 2, size.height * 0.8), width: size.width * 0.6, height: 80),
      const Radius.circular(20),
    );
    canvas.drawRRect(rect, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
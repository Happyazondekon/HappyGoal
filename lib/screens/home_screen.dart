import 'package:flutter/material.dart';
import 'package:happygoal/screens/tutorial_settings_screen.dart';
import '../constants.dart';
import 'mode_selection_screen.dart';
import '../widgets/audiosettings_widget.dart';
import '../utils/analytics_service.dart';
import '../widgets/banner_ad_widget.dart';
import '../utils/ad_controller.dart';
import 'package:flutter/foundation.dart';
import '../utils/tutorial_manager.dart';
import '../widgets/tutorial_overlay.dart';
import '../widgets/tutorial_mixin.dart';
import 'package:share_plus/share_plus.dart'; // Import pour le partage
import 'package:url_launcher/url_launcher.dart'; // Import pour ouvrir l'URL

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

class FloatingParticle extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const FloatingParticle({
    Key? key,
    this.size = 4.0,
    this.color = Colors.white,
    this.duration = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  _FloatingParticleState createState() => _FloatingParticleState();
}

class _FloatingParticleState extends State<FloatingParticle>
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

    _animation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
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
        ),
      ),
    );
  }
}

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
  final GlobalKey _inviteButtonKey = GlobalKey(); // Nouvelle clé pour le bouton d'invitation
  final GlobalKey _coinBalanceKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    AdController.instance.initialize();

    // Ajouter le tutoriel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showTutorialIfNeeded('home_screen', _createTutorialSteps());
    });
  }

  List<TutorialStep> _createTutorialSteps() {
    return [
      TutorialStep(
        title: 'Bienvenue dans HappyGoal!',
        description: 'Découvrons ensemble les fonctionnalités de votre nouveau jeu de penalties préféré!',
        targetKey: _playButtonKey,
        position: TutorialPosition.top,
        customContent: Column(
          children: [
            Image.asset('assets/images/ball.png', width: 50, height: 50),
            const SizedBox(height: 10),
            const Text(
              'Prêt pour des tirs au but épiques?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      TutorialStep(
        title: 'Vos coins',
        description: 'Ici vous pouvez voir votre solde de coins. Utilisez-les pour acheter des rembobinages!',
        targetKey: _coinBalanceKey,
        position: TutorialPosition.bottom,
      ),
      TutorialStep(
        title: 'Commencer à jouer',
        description: 'Appuyez sur JOUER pour accéder aux différents modes de jeu : Solo, Multijoueur et Tournoi.',
        targetKey: _playButtonKey,
        position: TutorialPosition.top,
      ),
      TutorialStep(
        title: 'Règles du jeu',
        description: 'Consultez les règles pour comprendre comment marquer des buts et remporter vos matches!',
        targetKey: _rulesButtonKey,
        position: TutorialPosition.top,
      ),
      TutorialStep(
        title: 'Paramètres',
        description: 'Ajustez les paramètres audio et personnalisez votre expérience de jeu.',
        targetKey: _settingsButtonKey,
        position: TutorialPosition.top,
      ),
      TutorialStep(
        title: 'Inviter des amis',
        description: 'Partagez le jeu avec vos amis et n\'oubliez pas de nous noter sur le Play Store!',
        targetKey: _inviteButtonKey,
        position: TutorialPosition.top,
      ),
      TutorialStep(
        title: 'Bonus quotidien',
        description: 'N\'oubliez pas de récupérer votre bonus quotidien pour débloquer des avantages spéciaux!',
        targetKey: _rewardButtonKey,
        position: TutorialPosition.top,
      ),
    ];
  }

  // Nouvelle méthode pour inviter des amis
  void _inviteFriends() {
    AnalyticsService.logAdEvent('invite_friends');

    final String shareText =
        '🎯 Découvre HappyGoal - Le jeu de penalties ultime ! ⚽\n\n'
        'Affronte tes amis dans des séances de tirs au but épiques !\n'
        '✅ Mode Solo contre IA\n'
        '✅ Mode Multijoueur\n'
        '✅ Tournois passionnants\n'
        '✅ Graphiques magnifiques\n\n'
        'Télécharge le jeu maintenant :\n'
        'https://play.google.com/store/apps/details?id=com.heyhappy.happygoal\n\n'
        'Et n\'oublie pas de nous noter ⭐⭐⭐⭐⭐ sur le Play Store !';

    Share.share(shareText, subject: 'Rejoins-moi sur HappyGoal !');
  }

  // Nouvelle méthode pour ouvrir la page de notation
  void _rateApp() async {
    AnalyticsService.logAdEvent('rate_app');
    final String url = 'https://play.google.com/store/apps/details?id=com.heyhappy.happygoal';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir le Play Store'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Arrière-plan dégradé moderne
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D4A2D),  // Vert foncé
                  Color(0xFF1B6B3A),  // Vert moyen
                  Color(0xFF2E8B4B),  // Vert clair
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Particules flottantes
          ...List.generate(15, (index) {
            return Positioned(
              left: (index * 25.0) % screenWidth,
              top: (index * 37.0) % screenHeight,
              child: FloatingParticle(
                size: 2.0 + (index % 3),
                color: Colors.white.withOpacity(0.1 + (index % 3) * 0.1),
                duration: Duration(seconds: 3 + (index % 4)),
              ),
            );
          }),

          // Lignes de terrain stylisées
          CustomPaint(
            size: Size(screenWidth, screenHeight),
            painter: FieldLinesPainter(),
          ),

          // Contenu principal
          SafeArea(
            child: Column(
              children: [
                // Section header moderne avec coins
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    child: Stack(
                      children: [
                        // Contenu principal centré
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo moderne avec animation
                              TweenAnimationBuilder(
                                duration: const Duration(seconds: 2),
                                tween: Tween<double>(begin: 0, end: 1),
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: 0.8 + (0.2 * value),
                                    child: Container(
                                      width: 140,
                                      height: 140,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white,
                                            Color(0xFFF0F0F0),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, -5),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Text(
                                          '⚽',
                                          style: TextStyle(fontSize: 70),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 30),

                              // Titre avec effet néon
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Color(0xFFE0E0E0),
                                    Colors.white,
                                  ],
                                ).createShader(bounds),
                                child: const Text(
                                  'HappyGoal',
                                  style: TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 3,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 0),
                                        blurRadius: 20,
                                        color: Colors.white,
                                      ),
                                      Shadow(
                                        offset: Offset(0, 5),
                                        blurRadius: 15,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Sous-titre moderne
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white.withOpacity(0.1),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: const Text(
                                  'Le défi des tirs au but',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Affichage du solde de coins en haut à droite
                        Positioned(
                          top: 10,
                          right: 20,
                          child: _buildCoinBalance(context),
                        ),
                      ],
                    ),
                  ),
                ),

                // Section boutons redesignée
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Bouton JOUER principal
                        PulsatingButton(
                          key: _playButtonKey,
                          glowColor: const Color(0xFF4CAF50),
                          child: _buildModernButton(
                            context,
                            icon: Icons.play_circle_filled,
                            text: 'JOUER',
                            isPrimary: true,
                            onPressed: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  transitionDuration: const Duration(milliseconds: 300),
                                  pageBuilder: (context, animation, _) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(1.0, 0.0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: const ModeSelectionScreen(),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Boutons secondaires en ligne
                        Row(
                          children: [
                            Expanded(
                              child: _buildSecondaryButton(
                                context,
                                key: _rulesButtonKey,
                                icon: Icons.info_outline,
                                text: 'RÈGLES',
                                onPressed: () => _showRulesDialog(context),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildSecondaryButton(
                                context,
                                key: _settingsButtonKey,
                                icon: Icons.settings,
                                text: 'OPTIONS',
                                onPressed: () => _showSettingsDialog(context),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Nouveau bouton Inviter des amis
                        _buildInviteButton(context, key: _inviteButtonKey),

                        const SizedBox(height: 20),

                        _buildRewardButton(context, key: _rewardButtonKey),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Nouveau bouton pour inviter des amis
  Widget _buildInviteButton(BuildContext context, {Key? key}) {
    return Container(
      key: key,
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _inviteFriends,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3), // Bleu pour l'invitation
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.share, size: 20),
            const SizedBox(width: 10),
            const Text(
              'INVITER DES AMIS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Nouvelle méthode pour afficher le solde de coins
  Widget _buildCoinBalance(BuildContext context) {
    return GestureDetector(
      key: _coinBalanceKey,
      onTap: () => _showCoinInfoDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFD700),
              Color(0xFFFFC400),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.monetization_on,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '${AdController.instance.currentCoinCount}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 3,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Nouvelle méthode pour afficher les informations sur les coins
  void _showCoinInfoDialog(BuildContext context) {
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
              'Vos Coins',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Votre solde actuel et comment utiliser vos coins:',
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
                  _buildCoinInfoItem('💰 Solde actuel', '${AdController.instance.currentCoinCount} coins'),
                  _buildCoinInfoItem('🎥 Gagner des coins', '+${AdController.instance.rewardCoins} coins/pub'),
                  _buildCoinInfoItem('🔄 Acheter rembobinage', '${AdController.instance.rewindCost} coins'),
                  _buildCoinInfoItem('📊 Rembobinages disponibles', '${AdController.instance.currentRewindCount}'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Les coins vous permettent d\'acheter des rembobinages pour revenir en arrière pendant les matches!',
              style: TextStyle(fontSize: 14, color: Colors.white70),
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
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              )),
        ],
      ),
    );
  }

  void _showEarnRewardDialog() {
    AdController.instance.showRewardDialog(
      context: context,
      title: 'Gagner des Coins',
      description: 'Regardez une publicité pour gagner ${AdController.instance.rewardCoins} coins !',
      rewardType: 'coins',
      rewardAmount: AdController.instance.rewardCoins,
      onRewardEarned: () {
        setState(() {}); // Rafraîchir l'affichage du solde
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
            duration: const Duration(seconds: 2),
          ),
        );
      },
      onAdFailed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Publicité non disponible'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      },
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
              ? const Color(0xFF4CAF50)
              : Colors.white.withOpacity(0.15),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: BorderSide(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.white,
            ),
            const SizedBox(width: 15),
            Text(
              text,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
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
          backgroundColor: Colors.white.withOpacity(0.1),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(height: 4),
            Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    AnalyticsService.logSettingsView(); // Laissez cette ligne si vous utilisez un service d'analyse
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 20,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFF8F8F8)],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header du dialogue
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Colors.green[800]!, // Remplacez AppColors.primary
                          Colors.green[800]!.withOpacity(0.8), // Remplacez AppColors.primary
                        ],
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 28,
                        ),
                        SizedBox(width: 15),
                        Text(
                          'Paramètres',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Contenu principal (scrollable)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      children: [
                        // Paramètres Audio
                        const AudioSettingsWidget(),
                        const SizedBox(height: 15),
                        // Paramètres du Tutoriel
                        const TutorialSettingsWidget(),
                        const SizedBox(height: 20),
                        // Bouton pour fermer le dialogue
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[800]!, // Remplacez AppColors.primary
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            "Fermer",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
        );
      },
    );
  }

  void _showRulesDialog(BuildContext context) {
    AnalyticsService.logRulesView();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 20,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFF8F8F8)],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 15),
                        const Text(
                          "Règles du jeu",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                  ),

                  // Contenu
                  Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Principe du jeu"),
                        _buildRuleItem("HappyGoal est un jeu de penalties où deux équipes s'affrontent dans une séance de tirs au but."),
                        _buildRuleItem("Chaque équipe tire à tour de rôle pour marquer le plus de buts possible."),

                        const SizedBox(height: 20),
                        _buildSectionTitle("Déroulement du jeu"),
                        _buildRuleItem("1. Choisissez deux équipes pour commencer le match."),
                        _buildRuleItem("2. Chaque équipe dispose de 5 tirs pendant la phase normale."),
                        _buildRuleItem("3. Pour chaque tir, choisissez une direction: gauche, centre ou droite."),
                        _buildRuleItem("4. Le gardien plongera aléatoirement dans une des trois directions."),
                        _buildRuleItem("5. Si le gardien plonge dans la même direction que votre tir, c'est un arrêt. Sinon, c'est un but!"),

                        const SizedBox(height: 20),
                        _buildSectionTitle("Comment gagner"),
                        _buildRuleItem("L'équipe avec le plus de buts après les 5 tirs remporte le match."),
                        _buildRuleItem("Si une équipe ne peut mathématiquement plus rattraper son retard, le match se termine immédiatement."),

                        const SizedBox(height: 20),
                        _buildSectionTitle("Mort subite"),
                        _buildRuleItem("En cas d'égalité après les 5 tirs, une phase de mort subite commence."),
                        _buildRuleItem("Chaque équipe tire à tour de rôle. Si une équipe marque et l'autre rate, la première remporte le match."),

                        const SizedBox(height: 30),
                        Center(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              "Compris!",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
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
        );
      },
    );
  }
  Widget _buildRewardButton(BuildContext context, {Key? key}) {
    return Container(
      key: key,
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          AdController.instance.showRewardDialog(
            context: context,
            title: 'Bonus Quotidien - Coins',
            description: 'Regardez une publicité pour gagner ${AdController.instance.rewardCoins} coins !',
            rewardType: 'coins',
            rewardAmount: AdController.instance.rewardCoins,
            onRewardEarned: () {
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
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            onAdFailed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Publicité non disponible'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber.withOpacity(0.9),
          foregroundColor: Colors.black,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.monetization_on, size: 24),
            const SizedBox(width: 10),
            Text(
              AdController.instance.isRewardedAvailable ?
              'GAGNER ${AdController.instance.rewardCoins} COINS' :
              'COINS',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildSectionTitle(String title) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: AppColors.primary.withOpacity(0.1),
    ),
    child: Row(
      children: [
        Icon(
          Icons.star,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    ),
  );
}

Widget _buildRuleItem(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6, right: 12),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}


class FieldLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Ligne centrale
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Cercle central
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      60,
      paint,
    );

    // Surface de réparation stylisée
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.8),
        width: size.width * 0.6,
        height: 80,
      ),
      const Radius.circular(20),
    );
    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
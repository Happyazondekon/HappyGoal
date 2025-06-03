// tournament_result_screen.dart
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';
import '../models/team.dart';
import 'home_screen.dart';
import '../constants.dart';

class TournamentResultScreen extends StatefulWidget {
  final Team userTeam;
  final int userWins;
  final int aiWins;
  final bool isWinner;

  const TournamentResultScreen({
    Key? key,
    required this.userTeam,
    required this.userWins,
    required this.aiWins,
    required this.isWinner,
  }) : super(key: key);

  @override
  _TournamentResultScreenState createState() => _TournamentResultScreenState();
}

class _TournamentResultScreenState extends State<TournamentResultScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _fadeController;

  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Contrôleur pour les confettis
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    // Contrôleurs d'animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Animations
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.bounceOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Démarrer les animations
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();

    if (widget.userWins == 4) { // Confettis seulement si champion
      _confettiController.play();
    }

    await Future.delayed(const Duration(milliseconds: 500));
    _slideController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arrière-plan
          _buildBackground(),

          // Confettis
          if (widget.userWins == 4) _buildConfetti(), // Confettis seulement si champion

          // Contenu principal
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Titre de résultat avec animation
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildResultTitle(),
                    ),

                    const SizedBox(height: 30),

                    // Espace pour l'animation du trophée
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildTrophySection(),
                    ),

                    const SizedBox(height: 40),

                    // Carte des résultats avec animation de glissement
                    SlideTransition(
                      position: _slideAnimation,
                      child: _buildResultsCard(),
                    ),


                    const SizedBox(height: 40),

                    // Boutons d'action
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildActionButtons(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    // Champion seulement si 4 victoires (tous les matches gagnés)
    bool isChampion = widget.userWins == 4;

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.5,
          colors: isChampion
              ? [
            Colors.amber.withOpacity(0.3),
            Colors.yellow.withOpacity(0.2),
            Colors.black.withOpacity(0.8),
            Colors.black,
          ]
              : widget.userWins > widget.aiWins
              ? [
            Colors.green.withOpacity(0.3),
            Colors.lightGreen.withOpacity(0.2),
            Colors.black.withOpacity(0.8),
            Colors.black,
          ]
              : [
            Colors.red.withOpacity(0.3),
            Colors.orange.withOpacity(0.2),
            Colors.black.withOpacity(0.8),
            Colors.black,
          ],
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/stadium_background.jpg'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildConfetti() {
    // Confettis seulement si champion (4 victoires)
    bool isChampion = widget.userWins == 4;

    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirection: 1.57, // Pi/2 (vers le bas)
        maxBlastForce: 5,
        minBlastForce: 2,
        emissionFrequency: 0.05,
        numberOfParticles: 50,
        colors: const [
          Colors.green,
          Colors.blue,
          Colors.pink,
          Colors.orange,
          Colors.purple,
          Colors.yellow,
          Colors.red,
        ],
      ),
    );
  }

  Widget _buildResultTitle() {
    // Champion seulement si 4 victoires (tous les matches gagnés)
    bool isChampion = widget.userWins == 4;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isChampion
              ? [Colors.amber, Colors.yellow]
              : widget.userWins > widget.aiWins
              ? [Colors.green, Colors.lightGreen]
              : [Colors.red, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: (isChampion ? Colors.amber :
            widget.userWins > widget.aiWins ? Colors.green : Colors.red).withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isChampion ? '🏆' :
            widget.userWins > widget.aiWins ? '⚽' : '💔',
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 10),
          Text(
            isChampion ? 'CHAMPION!' :
            widget.userWins > widget.aiWins ? 'BONNE PERFORMANCE!' : 'DÉFAITE',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 3,
              shadows: [
                Shadow(
                  offset: Offset(2, 2),
                  blurRadius: 4,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            isChampion ? 'TOURNOI REMPORTÉ' :
            widget.userWins > widget.aiWins ? 'ÉLIMINÉ' : 'FIN DU PARCOURS',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              letterSpacing: 2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrophySection() {
    // Champion seulement si 4 victoires (tous les matches gagnés)
    bool isChampion = widget.userWins == 4;

    return Container(

      child: Center(
        child: isChampion
            ? Lottie.asset(
          'assets/animations/trophy.json', // Espace réservé pour l'animation Lottie
          repeat: false,
        )
            : Icon(
          Icons.emoji_events_outlined,
          size: 80,
          color: Colors.grey.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête de la carte
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_outlined,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'RÉSULTATS DU TOURNOI',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                  letterSpacing: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // Informations de l'équipe
          _buildTeamInfo(),

          const SizedBox(height: 20),

          Divider(color: Colors.grey[300], thickness: 1),

          const SizedBox(height: 20),

          // Statistiques des matchs
          _buildMatchStats(),
        ],
      ),
    );
  }

  Widget _buildTeamInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.userTeam.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.userTeam.color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                widget.userTeam.flagImage,
                height: 60,
                width: 90,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userTeam.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.userTeam.color,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.userTeam.color,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    widget.userWins == 4 ? '🏆 CHAMPION' :
                    widget.userWins > widget.aiWins ? '⚔️ COMBATTANT' : '💔 ÉLIMINÉ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'VICTOIRES',
            widget.userWins.toString(),
            Colors.green,
            Icons.emoji_events,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            'DÉFAITES',
            widget.aiWins.toString(),
            Colors.red,
            Icons.close,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            'TOTAL',
            '${widget.userWins + widget.aiWins}',
            AppColors.primary,
            Icons.sports_soccer,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildActionButtons() {
    return Column(
      children: [
        // Bouton principal
        ElevatedButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.home,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'RETOUR À L\'ACCUEIL',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        // Bouton secondaire - Rejouer
        OutlinedButton(
          onPressed: () {
            // Logique pour rejouer le tournoi
            Navigator.pop(context);
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.refresh,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'NOUVEAU TOURNOI',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
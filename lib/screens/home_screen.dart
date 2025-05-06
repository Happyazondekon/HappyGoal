import 'package:flutter/material.dart';
import '../constants.dart';
import 'mode_selection_screen.dart';
import '../widgets/audiosettings_widget.dart';
import '../utils/analytics_service.dart';



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
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(0.7 * _animation.value),
                spreadRadius: 3 * _animation.value,
                blurRadius: 10 * _animation.value,
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
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arrière-plan amélioré avec overlay plus sombre
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/stadium_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),

          // Contenu principal
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo et titre avec effet 3D amélioré
                  Column(
                    children: [

                      const SizedBox(height: 10),
                      const Text(
                        'HappyGoal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              offset: Offset(3.0, 3.0),
                              blurRadius: 6.0,
                              color: Colors.black,
                            ),
                            Shadow(
                              offset: Offset(-3.0, -3.0),
                              blurRadius: 6.0,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Le défi des tirs au but..!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 3.0,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 60),

                  // Boutons d'action avec icônes
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        // Bouton JOUER
                        PulsatingButton(
                          glowColor: Colors.white,
                          child: _buildActionButton(
                            context,
                            icon: Icons.play_arrow_rounded,
                            text: 'JOUER',
                            backgroundColor: AppColors.primary,
                            onPressed: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) =>
                                  const ModeSelectionScreen(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(1.0, 0.0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Bouton RÈGLES
                        _buildActionButton(
                          context,
                          icon: Icons.rule_rounded,
                          text: 'RÈGLES',
                          backgroundColor: Colors.white,
                          textColor: AppColors.primary,
                          onPressed: () {
                            _showRulesDialog(context);
                          },
                        ),

                        const SizedBox(height: 20),

                        // Bouton PARAMÈTRES
                        _buildActionButton(
                          context,
                          icon: Icons.settings_rounded,
                          text: 'PARAMÈTRES',
                          backgroundColor: Colors.purple.withOpacity(0.8),
                          textColor: Colors.white,
                          onPressed: () {
                            _showSettingsDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required IconData icon,
        required String text,
        required Color backgroundColor,
        Color textColor = Colors.white,
        required VoidCallback onPressed,
      }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 30,
            color: textColor,
          ),
          const SizedBox(width: 15),
          Text(
            text,
            style: TextStyle(
              fontSize: 22,
              color: textColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    AnalyticsService.logSettingsView();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  'Paramètres',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Divider(),
              const AudioSettingsWidget(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "OK",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
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
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Règles du jeu",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),

                // Contenu des règles (inchangé)
                _buildSectionTitle("Principe du jeu"),
                _buildRuleItem("HappyGoal est un jeu de penalties où deux équipes s'affrontent dans une séance de tirs au but."),
                _buildRuleItem("Chaque équipe tire à tour de rôle pour marquer le plus de buts possible."),

                const SizedBox(height: 15),
                _buildSectionTitle("Déroulement du jeu"),
                _buildRuleItem("1. Choisissez deux équipes pour commencer le match."),
                _buildRuleItem("2. Chaque équipe dispose de 5 tirs pendant la phase normale."),
                _buildRuleItem("3. Pour chaque tir, choisissez une direction: gauche, centre ou droite."),
                _buildRuleItem("4. Le gardien plongera aléatoirement dans une des trois directions."),
                _buildRuleItem("5. Si le gardien plonge dans la même direction que votre tir, c'est un arrêt. Sinon, c'est un but!"),

                const SizedBox(height: 15),
                _buildSectionTitle("Comment gagner"),
                _buildRuleItem("L'équipe avec le plus de buts après les 5 tirs remporte le match."),
                _buildRuleItem("Si une équipe ne peut mathématiquement plus rattraper son retard, le match se termine immédiatement."),

                const SizedBox(height: 15),
                _buildSectionTitle("Mort subite"),
                _buildRuleItem("En cas d'égalité après les 5 tirs, une phase de mort subite commence."),
                _buildRuleItem("Chaque équipe tire à tour de rôle. Si une équipe marque et l'autre rate, la première remporte le match."),

                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
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
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 3, right: 10),
            child: Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primary,
              size: 14,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
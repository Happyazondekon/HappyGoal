import 'package:flutter/material.dart';
import '../constants.dart';
import 'team_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arrière-plan avec effet de flou
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/stadium_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ColorFilter.mode(
                Colors.white,
                BlendMode.darken,
              ),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          // Contenu principal
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo et titre
                  Column(
                    children: [
                      const SizedBox(height: 20),
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
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Le défi des penalties',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 3.0,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 80),

                  // Boutons d'action
                  Column(
                    children: [
                      // Bouton JOUER
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                              const TeamSelectionScreen(),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.primary.withOpacity(0.5),
                        ),
                        child: const Text(
                          'JOUER',
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Bouton RÈGLES
                      ElevatedButton(
                        onPressed: () {
                          _showRulesDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                          shadowColor: Colors.white.withOpacity(0.5),
                        ),
                        child: const Text(
                          'RÈGLES',
                          style: TextStyle(
                            fontSize: 22,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          backgroundColor: Colors.white.withOpacity(0.95),
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

                // Principe du jeu
                _buildSectionTitle("Principe du jeu"),
                _buildRuleItem("HappyGoal est un jeu de penalties où deux équipes s'affrontent dans une séance de tirs au but."),
                _buildRuleItem("Chaque équipe tire à tour de rôle pour marquer le plus de buts possible."),

                const SizedBox(height: 15),

                // Déroulement du jeu
                _buildSectionTitle("Déroulement du jeu"),
                _buildRuleItem("1. Choisissez deux équipes pour commencer le match."),
                _buildRuleItem("2. Chaque équipe dispose de 5 tirs pendant la phase normale."),
                _buildRuleItem("3. Pour chaque tir, choisissez une direction: gauche, centre ou droite."),
                _buildRuleItem("4. Le gardien plongera aléatoirement dans une des trois directions."),
                _buildRuleItem("5. Si le gardien plonge dans la même direction que votre tir, c'est un arrêt. Sinon, c'est un but!"),

                const SizedBox(height: 15),

                // Comment gagner
                _buildSectionTitle("Comment gagner"),
                _buildRuleItem("L'équipe avec le plus de buts après les 5 tirs remporte le match."),
                _buildRuleItem("Si une équipe ne peut mathématiquement plus rattraper son retard, le match se termine immédiatement."),

                const SizedBox(height: 15),

                // Mort subite
                _buildSectionTitle("Mort subite"),
                _buildRuleItem("En cas d'égalité après les 5 tirs, une phase de mort subite commence."),
                _buildRuleItem("Chaque équipe tire à tour de rôle. Si une équipe marque et l'autre rate, la première remporte le match."),
                _buildRuleItem("Si les deux équipes marquent ou ratent, la mort subite continue avec un nouveau tour."),

                const SizedBox(height: 15),

                // Astuces stratégiques
                _buildSectionTitle("Astuces stratégiques"),
                _buildRuleItem("Les gardiens plongent de façon aléatoire, donc variez vos directions de tir pour ne pas être prévisible."),
                _buildRuleItem("Le choix judicieux des équipes peut influencer l'ambiance visuelle du match."),

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
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
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
              Icons.sports_soccer,
              color: AppColors.primary,
              size: 18,
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
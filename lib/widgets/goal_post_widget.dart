import 'package:flutter/material.dart';
import '../constants.dart';

class GoalPostWidget extends StatelessWidget {
  const GoalPostWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtenir la largeur de l'écran
    final screenWidth = MediaQuery.of(context).size.width;

    // Largeur du but (comme proposé précédemment)
    final goalWidth = screenWidth * 0.9;

    // Augmenter la hauteur ici - changez cette valeur selon vos besoins
    final goalHeight = goalWidth * 0.8; // Augmenté de 0.5 à 0.7 pour un but plus haut

    return Image.asset(
      'assets/images/camp.png',
      width: goalWidth,
      height: goalHeight, // C'est cet attribut qui contrôle la hauteur
      fit: BoxFit.fill,
    );
  }
}
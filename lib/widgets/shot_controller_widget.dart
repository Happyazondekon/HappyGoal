// lib/widgets/shot_controller_widget.dart
// Ce fichier est conservé pour la compatibilité avec game_screen.dart
// mais il délègue maintenant entièrement à SwipeShotWidget.
import 'package:flutter/material.dart';
import 'package:happygoal/utils/responsive_helper.dart';
import 'package:happygoal/widgets/swipe_shot_widget.dart';

/// Callback identique à l'ancien widget pour ne rien casser dans game_screen.dart
typedef OnShootCallback = void Function(int direction, int power, String effect);

class ShotControllerWidget extends StatelessWidget {
  final OnShootCallback onShoot;

  const ShotControllerWidget({
    Key? key,
    required this.onShoot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwipeShotWidget(onShoot: onShoot);
  }
}
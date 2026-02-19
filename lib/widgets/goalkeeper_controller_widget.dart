// lib/widgets/goalkeeper_controller_widget.dart
// Conserve l'interface onDive(int direction) existante
// mais délègue maintenant au GoalkeeperSwipeWidget.
import 'package:flutter/material.dart';
import 'package:happygoal/widgets/goalkeeper_swipe_widget.dart';

class GoalkeeperControllerWidget extends StatelessWidget {
  final void Function(int direction) onDive;

  const GoalkeeperControllerWidget({
    Key? key,
    required this.onDive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GoalkeeperSwipeWidget(onDive: onDive);
  }
}
import 'package:flutter/material.dart';
import '../models/team.dart';

class GoalkeeperWidget extends StatelessWidget {
  final Team team;

  const GoalkeeperWidget({
    Key? key,
    required this.team,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 120,
      child: Image.asset(
        'assets/images/players/goalkeeper.png',
        fit: BoxFit.contain,
      ),
    );
  }
}
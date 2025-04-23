import 'package:flutter/material.dart';

class PlayerWidget extends StatelessWidget {
  const PlayerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 100,
      child: Image.asset(
        'assets/images/players/striker.png',
        fit: BoxFit.contain,
      ),
    );
  }
}
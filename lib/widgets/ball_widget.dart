import 'package:flutter/material.dart';

class BallWidget extends StatelessWidget {
  final double positionX;
  final double positionY;
  final double size;

  const BallWidget({
    Key? key,
    required this.positionX,
    required this.positionY,
    this.size = 30.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: positionX - (size / 2),
      top: positionY - (size / 2),
      child: Image.asset(
        'assets/images/ball.png',
        width: size,
        height: size,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../constants.dart';

class GoalPostWidget extends StatelessWidget {
  const GoalPostWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: GameSettings.goalWidth,
      height: GameSettings.goalHeight,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: 8.0,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        children: [
          // Net pattern
          CustomPaint(
            size: Size(GameSettings.goalWidth, GameSettings.goalHeight),
            painter: NetPainter(),
          ),

          // Dividers for shot zones
          Positioned(
            top: 0,
            bottom: 0,
            left: GameSettings.goalWidth / 3,
            child: Container(
              width: 1,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: GameSettings.goalWidth * 2 / 3,
            child: Container(
              width: 1,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}

class NetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Horizontal net lines
    double lineHeight = 10.0;
    for (double y = 0; y < size.height; y += lineHeight) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Vertical net lines
    double lineWidth = 10.0;
    for (double x = 0; x < size.width; x += lineWidth) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
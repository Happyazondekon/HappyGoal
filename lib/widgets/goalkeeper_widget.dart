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
      decoration: BoxDecoration(
        color: team.color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Body
          Positioned(
            top: 40,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: team.color,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
            ),
          ),

          // Head
          Positioned(
            top: 10,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFD2B48C),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Arms
          Positioned(
            top: 50,
            left: 5,
            child: Container(
              width: 40,
              height: 10,
              decoration: BoxDecoration(
                color: team.color,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 5,
            child: Container(
              width: 40,
              height: 10,
              decoration: BoxDecoration(
                color: team.color,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
            ),
          ),

          // Legs
          Positioned(
            bottom: 10,
            left: 25,
            child: Container(
              width: 15,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 25,
            child: Container(
              width: 15,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),

          // Number
          Positioned(
            top: 50,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '1',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../constants.dart';



class GoalkeeperControllerWidget extends StatelessWidget {
  final Function(int) onDive;

  const GoalkeeperControllerWidget({
    Key? key,
    required this.onDive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🥅 Contrôlez votre gardien',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDiveButton('Gauche', ShotDirection.left, Icons.keyboard_arrow_left),
              _buildDiveButton('Centre', ShotDirection.center, Icons.keyboard_arrow_up),
              _buildDiveButton('Droite', ShotDirection.right, Icons.keyboard_arrow_right),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiveButton(String label, int direction, IconData icon) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () => onDive(direction),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
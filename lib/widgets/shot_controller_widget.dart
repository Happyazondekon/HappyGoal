import 'package:flutter/material.dart';
import '../constants.dart';

class ShotControllerWidget extends StatelessWidget {
  final Function(int) onShoot;

  const ShotControllerWidget({
    Key? key,
    required this.onShoot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.black.withOpacity(0.7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDirectionButton(
            label: 'GAUCHE',
            icon: Icons.arrow_back,
            direction: ShotDirection.left,
          ),
          _buildDirectionButton(
            label: 'CENTRE',
            icon: Icons.arrow_upward,
            direction: ShotDirection.center,
          ),
          _buildDirectionButton(
            label: 'DROITE',
            icon: Icons.arrow_forward,
            direction: ShotDirection.right,
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionButton({
    required String label,
    required IconData icon,
    required int direction,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () => onShoot(direction),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(15),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
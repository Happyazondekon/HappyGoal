import 'package:flutter/material.dart';
import '../constants.dart';

class ShotControllerWidget extends StatefulWidget {
  final Function(int direction, int power, String effect) onShoot;

  const ShotControllerWidget({
    Key? key,
    required this.onShoot,
  }) : super(key: key);

  @override
  State<ShotControllerWidget> createState() => _ShotControllerWidgetState();
}

class _ShotControllerWidgetState extends State<ShotControllerWidget> {
  int _selectedDirection = ShotDirection.center;
  int _shotPower = 50; // Valeur par défaut
  String _selectedEffect = 'normal'; // Effet par défaut

  // Liste des effets disponibles
  final List<Map<String, dynamic>> effects = [
    {'id': 'normal', 'name': 'Normal', 'icon': Icons.sports_soccer},
    {'id': 'curve', 'name': 'Effet', 'icon': Icons.rotate_right},
    {'id': 'lob', 'name': 'Lob', 'icon': Icons.arrow_upward},
    {'id': 'knuckle', 'name': 'Knuckle', 'icon': Icons.waves},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Zone de sélection de puissance
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Puissance: ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '$_shotPower%',
                    style: TextStyle(
                      color: _getPowerColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _shotPower.toDouble(),
                min: 0,
                max: 100,
                divisions: 10,
                activeColor: _getPowerColor(),
                onChanged: (value) {
                  setState(() {
                    _shotPower = value.toInt();
                  });
                },
              ),
            ],
          ),
        ),

        // Zone de sélection d'effet avec icônes
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Effet: ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(
                height: 70,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: effects.map((effect) {
                    final bool isSelected = _selectedEffect == effect['id'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        avatar: Icon(
                          effect['icon'] as IconData,
                          color: isSelected ? Colors.white : Colors.black,
                          size: 18,
                        ),
                        label: Text(
                          effect['name'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: Colors.blue,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedEffect = effect['id'] as String;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Boutons de direction (existants)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDirectionButton(
                ShotDirection.left,
                Icons.arrow_back,
                'Gauche',
              ),
              _buildDirectionButton(
                ShotDirection.center,
                Icons.arrow_upward,
                'Centre',
              ),
              _buildDirectionButton(
                ShotDirection.right,
                Icons.arrow_forward,
                'Droite',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getPowerColor() {
    if (_shotPower < 30) {
      return Colors.green;
    } else if (_shotPower < 70) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Widget _buildDirectionButton(int direction, IconData icon, String label) {
    final bool isSelected = _selectedDirection == direction;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDirection = direction;
        });
        // Déclenche le tir avec la direction, la puissance et l'effet sélectionnés
        widget.onShoot(_selectedDirection, _shotPower, _selectedEffect);
      },
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 30,
              color: isSelected ? Colors.white : Colors.blue,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
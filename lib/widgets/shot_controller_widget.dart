import 'package:flutter/material.dart';
import '../constants.dart'; // Assurez-vous que ShotDirection est défini ici

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
  int _shotPower = 50;
  String _selectedEffect = 'normal';

  final List<Map<String, dynamic>> effects = [
    {'id': 'normal', 'name': 'Normal', 'icon': Icons.sports_soccer},
    {'id': 'curve', 'name': 'Effet', 'icon': Icons.rotate_right},
    {'id': 'lob', 'name': 'Lob', 'icon': Icons.arrow_upward_rounded}, // Icône plus adaptée
    {'id': 'knuckle', 'name': 'Knuckle', 'icon': Icons.waves_rounded}, // Icône plus adaptée
  ];

  @override
  Widget build(BuildContext context) {
    // Tailles de police réduites
    const double labelFontSize = 13.0;
    const double chipLabelFontSize = 11.0;
    const double buttonLabelFontSize = 11.0;

    // Espacements réduits
    const EdgeInsets sectionPadding = EdgeInsets.symmetric(horizontal: 15, vertical: 6); // Moins de padding vertical
    const EdgeInsets chipPadding = EdgeInsets.symmetric(horizontal: 6.0, vertical: 0); // Padding pour les chips
    const EdgeInsets chipLabelPadding = EdgeInsets.symmetric(horizontal: 4.0, vertical: 0); // Padding label des chips

    return Column(
      mainAxisSize: MainAxisSize.min, // Important pour que la Column prenne le minimum de place
      children: [
        // Zone de sélection de puissance
        Padding(
          padding: sectionPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Pour espacer le label et la valeur
                children: [
                  const Text(
                    'Puissance: ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: labelFontSize,
                    ),
                  ),
                  Text(
                    '$_shotPower%',
                    style: TextStyle(
                      color: _getPowerColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: labelFontSize,
                    ),
                  ),
                ],
              ),
              SizedBox( // Réduire l'espace pour le Slider
                height: 25, // Hauteur réduite pour le conteneur du Slider
                child: SliderTheme( // Personnaliser le Slider pour le rendre plus compact
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2.0, // Piste plus fine
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0), // Curseur plus petit
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0), // Overlay plus petit
                    activeTrackColor: _getPowerColor(),
                    inactiveTrackColor: _getPowerColor().withOpacity(0.3),
                    thumbColor: _getPowerColor(),
                  ),
                  child: Slider(
                    value: _shotPower.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20, // Plus de divisions pour un contrôle plus fin si souhaité
                    onChanged: (value) {
                      setState(() {
                        _shotPower = value.toInt();
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // Zone de sélection d'effet
        Padding(
          padding: sectionPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Effet: ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: labelFontSize,
                ),
              ),
              SizedBox(
                height: 40, // Hauteur réduite pour la liste des effets
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: effects.map((effect) {
                    final bool isSelected = _selectedEffect == effect['id'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 6), // Espacement réduit entre les chips
                      child: ChoiceChip(
                        avatar: Icon(
                          effect['icon'] as IconData,
                          color: isSelected ? Colors.white : Colors.black87,
                          size: 15, // Icône plus petite
                        ),
                        label: Text(
                          effect['name'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: chipLabelFontSize,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary, // Utiliser une couleur de AppConstants
                        backgroundColor: Colors.white.withOpacity(0.8),
                        padding: chipPadding,
                        labelPadding: chipLabelPadding,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Réduit la zone de clic
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

        // Boutons de direction
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15), // Padding vertical réduit
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDirectionButton(
                ShotDirection.left,
                Icons.arrow_back_rounded,
                'Gauche',
                buttonLabelFontSize,
              ),
              _buildDirectionButton(
                ShotDirection.center,
                Icons.arrow_upward_rounded,
                'Centre',
                buttonLabelFontSize,
              ),
              _buildDirectionButton(
                ShotDirection.right,
                Icons.arrow_forward_rounded,
                'Droite',
                buttonLabelFontSize,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getPowerColor() {
    if (_shotPower < 30) {
      return Colors.greenAccent; // Couleurs plus vives
    } else if (_shotPower < 70) {
      return Colors.orangeAccent;
    } else {
      return Colors.redAccent;
    }
  }

  Widget _buildDirectionButton(int direction, IconData icon, String label, double fontSize) {
    final bool isSelected = _selectedDirection == direction;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDirection = direction;
        });
        widget.onShoot(_selectedDirection, _shotPower, _selectedEffect);
      },
      child: Container(
        width: 70, // Largeur réduite
        height: 55, // Hauteur réduite
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(10), // Bordure moins arrondie
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 3, // Ombre plus subtile
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22, // Icône plus petite
              color: isSelected ? Colors.white : AppColors.primary.withOpacity(0.9),
            ),
            const SizedBox(height: 3), // Espace réduit
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.primary.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


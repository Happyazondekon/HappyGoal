import 'package:flutter/material.dart';
import 'package:happygoal/models/team.dart';

class HeroTeamSelectionScreen extends StatelessWidget {
  final Function(String countryCode) onCountrySelected;
  final String? selectedCountryCode;

  const HeroTeamSelectionScreen({
    Key? key,
    required this.onCountrySelected,
    this.selectedCountryCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final teams = Team.getPredefinedTeams();
    return Scaffold(
      appBar: AppBar(title: const Text('Choisissez votre pays')),
      body: ListView.builder(
        itemCount: teams.length,
        itemBuilder: (context, index) {
          final team = teams[index];
          return ListTile(
            leading: Image.asset(team.flagImage, width: 40),
            title: Text(team.name),
            subtitle: Text(team.continent),
            selected: selectedCountryCode == team.name,
            onTap: () => onCountrySelected(team.name),
            trailing: selectedCountryCode == team.name
                ? ElevatedButton(
                    onPressed: () => onCountrySelected(team.name),
                    child: const Text('Valider'),
                  )
                : null,
          );
        },
      ),
    );
  }
}

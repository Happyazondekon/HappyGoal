// lib/screens/tutorial_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/tutorial_manager.dart';
import '../constants.dart';

class TutorialSettingsScreen extends StatefulWidget {
  const TutorialSettingsScreen({Key? key}) : super(key: key);

  @override
  State<TutorialSettingsScreen> createState() => _TutorialSettingsScreenState();
}

class _TutorialSettingsScreenState extends State<TutorialSettingsScreen> {
  Map<String, bool> tutorialStatus = {};
  bool isLoading = true;

  final Map<String, String> tutorialTitles = {
    'home_screen': 'Écran d\'accueil',
    'mode_selection': 'Sélection du mode',
    'team_selection': 'Sélection des équipes',
    'game_screen_solo': 'Jeu solo',
    'game_screen_multi': 'Jeu multijoueur',
    'tournament_mode': 'Mode tournoi',
  };

  final Map<String, String> tutorialDescriptions = {
    'home_screen': 'Guide des fonctionnalités principales',
    'mode_selection': 'Explication des différents modes de jeu',
    'team_selection': 'Comment choisir vos équipes',
    'game_screen_solo': 'Mécaniques de jeu contre l\'IA',
    'game_screen_multi': 'Jeu à deux joueurs',
    'tournament_mode': 'Navigation dans le tournoi',
  };

  @override
  void initState() {
    super.initState();
    _loadTutorialStatus();
  }

  Future<void> _loadTutorialStatus() async {
    final status = <String, bool>{};
    for (String tutorialName in tutorialTitles.keys) {
      final hasBeenShown = !await TutorialManager.shouldShowTutorial(tutorialName);
      status[tutorialName] = hasBeenShown;
    }

    if (mounted) {
      setState(() {
        tutorialStatus = status;
        isLoading = false;
      });
    }
  }

  Future<void> _resetTutorial(String tutorialName) async {
    // Supprimer la clé spécifique du SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tutorial_shown_$tutorialName');

    setState(() {
      tutorialStatus[tutorialName] = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tutoriel "${tutorialTitles[tutorialName]}" réinitialisé'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Future<void> _resetAllTutorials() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la réinitialisation'),
        content: const Text(
          'Êtes-vous sûr de vouloir réinitialiser tous les tutoriels ? '
              'Ils s\'afficheront à nouveau lors de vos prochaines visites.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Confirmer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await TutorialManager.resetTutorials();
      await _loadTutorialStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tous les tutoriels ont été réinitialisés'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tutoriels'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // En-tête avec informations
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.school,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Gestion des tutoriels',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Gérez l\'affichage des tutoriels pour chaque écran. '
                      'Les tutoriels marqués comme "Vu" ne s\'afficheront plus automatiquement.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Liste des tutoriels
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: tutorialTitles.length,
              itemBuilder: (context, index) {
                final tutorialName = tutorialTitles.keys.elementAt(index);
                final title = tutorialTitles[tutorialName]!;
                final description = tutorialDescriptions[tutorialName]!;
                final hasBeenShown = tutorialStatus[tutorialName] ?? false;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    description,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: hasBeenShown
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                hasBeenShown ? 'Vu' : 'Nouveau',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: hasBeenShown
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (hasBeenShown)
                              TextButton.icon(
                                onPressed: () => _resetTutorial(tutorialName),
                                icon: const Icon(
                                  Icons.refresh,
                                  size: 18,
                                  color: Colors.blue,
                                ),
                                label: const Text(
                                  'Réactiver',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'S\'affichera automatiquement',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bouton de réinitialisation globale
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _resetAllTutorials,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Réinitialiser tous les tutoriels'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget pour intégrer dans les paramètres existants
class TutorialSettingsWidget extends StatelessWidget {
  const TutorialSettingsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(
          Icons.school,
          color: Colors.blue,
        ),
        title: const Text(
          'Tutoriels',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text('Gérer l\'affichage des guides'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const TutorialSettingsScreen(),
            ),
          );
        },
      ),
    );
  }
}
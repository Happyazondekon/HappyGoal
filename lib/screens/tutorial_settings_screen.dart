// lib/screens/tutorial_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:happygoal/utils/tutorial_manager.dart';
import 'package:happygoal/constants.dart';
import 'package:happygoal/utils/responsive_helper.dart';
import 'package:happygoal/l10n/app_localizations.dart';

class TutorialSettingsScreen extends StatefulWidget {
  const TutorialSettingsScreen({Key? key}) : super(key: key);

  @override
  State<TutorialSettingsScreen> createState() => _TutorialSettingsScreenState();
}

class _TutorialSettingsScreenState extends State<TutorialSettingsScreen> {
  Map<String, bool> tutorialStatus = {};
  bool isLoading = true;

  Map<String, String> get tutorialTitles => {
    'home_screen': AppLocalizations.of(context)!.tutorialSettingsHome,
    'mode_selection': AppLocalizations.of(context)!.tutorialSettingsModeSelection,
    'team_selection': AppLocalizations.of(context)!.tutorialSettingsTeamSelection,
    'game_screen_solo': AppLocalizations.of(context)!.tutorialSettingsGameSolo,
    'game_screen_multi': AppLocalizations.of(context)!.tutorialSettingsGameMulti,
    'tournament_mode': AppLocalizations.of(context)!.tutorialSettingsTournament,
  };

  Map<String, String> get tutorialDescriptions => {
    'home_screen': AppLocalizations.of(context)!.tutorialSettingsHomeDesc,
    'mode_selection': AppLocalizations.of(context)!.tutorialSettingsModeSelectionDesc,
    'team_selection': AppLocalizations.of(context)!.tutorialSettingsTeamSelectionDesc,
    'game_screen_solo': AppLocalizations.of(context)!.tutorialSettingsGameSoloDesc,
    'game_screen_multi': AppLocalizations.of(context)!.tutorialSettingsGameMultiDesc,
    'tournament_mode': AppLocalizations.of(context)!.tutorialSettingsTournamentDesc,
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
        content: Text(AppLocalizations.of(context)!.tutorialSettingsResetSingle(tutorialTitles[tutorialName]!)),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Future<void> _resetAllTutorials() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.tutorialSettingsResetConfirmTitle),
        content: Text(AppLocalizations.of(context)!.tutorialSettingsResetConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.tutorialSettingsResetCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(AppLocalizations.of(context)!.tutorialSettingsResetConfirm, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await TutorialManager.resetTutorials();
      await _loadTutorialStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.tutorialSettingsResetSuccess),
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
        title: Text(AppLocalizations.of(context)!.tutorialSettingsTitle),
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
                    Text(
                      AppLocalizations.of(context)!.tutorialSettingsHeader,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.tutorialSettingsHeaderDesc,
                  style: const TextStyle(
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
                                hasBeenShown ? AppLocalizations.of(context)!.tutorialSettingsSeen : AppLocalizations.of(context)!.tutorialSettingsNew,
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
                                label: Text(
                                  AppLocalizations.of(context)!.tutorialSettingsReactivate,
                                  style: const TextStyle(color: Colors.blue),
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
                                child: Text(
                                  AppLocalizations.of(context)!.tutorialSettingsWillShow,
                                  style: const TextStyle(
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
              label: Text(AppLocalizations.of(context)!.tutorialSettingsResetAll),
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
        title: Text(
          AppLocalizations.of(context)!.tutorialSettingsWidgetTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(AppLocalizations.of(context)!.tutorialSettingsWidgetSubtitle),
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
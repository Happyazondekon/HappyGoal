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

class _TutorialSettingsScreenState extends State<TutorialSettingsScreen> with TickerProviderStateMixin {
  Map<String, bool> tutorialStatus = {};
  bool isLoading = true;
  String? errorMessage;

  // Static list of tutorial keys to avoid context issues in initState
  static const List<String> tutorialKeys = [
    'home_screen',
    'mode_selection',
    'team_selection',
    'game_screen_solo',
    'game_screen_multi',
    'tournament_mode',
  ];

  late AnimationController _headerController;
  late AnimationController _listController;
  late Animation<double> _headerAnimation;

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
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _listController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _headerAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutBack),
    );
    _loadTutorialStatus();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _listController.dispose();
    super.dispose();
  }

  Future<void> _loadTutorialStatus() async {
    try {
      final status = <String, bool>{};
      // Use static keys instead of tutorialTitles.keys to avoid context issues
      for (String tutorialName in tutorialKeys) {
        try {
          final hasBeenShown = !await TutorialManager.shouldShowTutorial(tutorialName);
          status[tutorialName] = hasBeenShown;
        } catch (e) {
          debugPrint('Error loading tutorial status for $tutorialName: $e');
          status[tutorialName] = false;
        }
      }

      if (mounted) {
        setState(() {
          tutorialStatus = status;
          isLoading = false;
          errorMessage = null;
        });
        _headerController.forward();
        _listController.forward();
      }
    } catch (e) {
      debugPrint('Error loading tutorial statuses: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Erreur lors du chargement des tutoriels';
        });
      }
    }
  }

  Future<void> _resetTutorial(String tutorialName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('tutorial_shown_$tutorialName');

      setState(() {
        tutorialStatus[tutorialName] = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.tutorialSettingsResetSingle(tutorialTitles[tutorialName]!)),
            backgroundColor: const Color(0xFF4CAF50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error resetting tutorial: $e');
    }
  }

  Future<void> _resetAllTutorials() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppLocalizations.of(context)!.tutorialSettingsResetConfirmTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)!.tutorialSettingsResetConfirmContent,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              AppLocalizations.of(context)!.tutorialSettingsResetCancel,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              AppLocalizations.of(context)!.tutorialSettingsResetConfirm,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await TutorialManager.resetTutorials();
        await _loadTutorialStatus();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.tutorialSettingsResetSuccess),
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error resetting all tutorials: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.tutorialSettingsTitle),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Header avec informations
                    ScaleTransition(
                      scale: _headerAnimation,
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: RadialGradient(
                            center: Alignment.topCenter,
                            radius: 1.5,
                            colors: [
                              const Color(0xFF1A3A22),
                              const Color(0xFF0A1A0F),
                              const Color(0xFF050D07),
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFFFFD700).withOpacity(0.25),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withOpacity(0.15),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [Color(0xFFFFD700), Color(0xFFF57F17)],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.school_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => const LinearGradient(
                                      colors: [
                                        Color(0xFFFFD700),
                                        Colors.white,
                                      ],
                                    ).createShader(bounds),
                                    child: Text(
                                      AppLocalizations.of(context)!.tutorialSettingsHeader,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)!.tutorialSettingsHeaderDesc,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                                letterSpacing: 0.3,
                              ),
                      ),
                          ],
                        ),
                      ),
                    ),

                    // Liste des tutoriels
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: tutorialKeys.length,
                        itemBuilder: (context, index) {
                          final tutorialName = tutorialKeys[index];
                          final title = tutorialTitles[tutorialName]!;
                          final description = tutorialDescriptions[tutorialName]!;
                          final hasBeenShown = tutorialStatus[tutorialName] ?? false;

                          return FadeTransition(
                            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                              CurvedAnimation(
                                parent: _listController,
                                curve: Interval(
                                  (index * 0.1).clamp(0.0, 1.0),
                                  ((index + 1) * 0.1).clamp(0.0, 1.0),
                                  curve: Curves.easeOut,
                                ),
                              ),
                            ),
                            child: SlideTransition(
                              position: Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
                                CurvedAnimation(
                                  parent: _listController,
                                  curve: Interval(
                                    (index * 0.1).clamp(0.0, 1.0),
                                    ((index + 1) * 0.1).clamp(0.0, 1.0),
                                    curve: Curves.easeOut,
                                  ),
                                ),
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF1A2A1F).withOpacity(0.6),
                                      const Color(0xFF0F1815).withOpacity(0.4),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
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
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.white,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  description,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.white70,
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.4,
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
                                                  ? const Color(0xFF4CAF50).withOpacity(0.2)
                                                  : const Color(0xFFF57F17).withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: hasBeenShown
                                                    ? const Color(0xFF4CAF50).withOpacity(0.5)
                                                    : const Color(0xFFF57F17).withOpacity(0.5),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              hasBeenShown
                                                  ? AppLocalizations.of(context)!.tutorialSettingsSeen
                                                  : AppLocalizations.of(context)!.tutorialSettingsNew,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w900,
                                                color: hasBeenShown
                                                    ? const Color(0xFF4CAF50)
                                                    : const Color(0xFFF57F17),
                                                letterSpacing: 0.5,
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
                                            GestureDetector(
                                              onTap: () => _resetTutorial(tutorialName),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF2196F3).withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: const Color(0xFF2196F3).withOpacity(0.5),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.refresh_rounded,
                                                      size: 14,
                                                      color: Color(0xFF2196F3),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      AppLocalizations.of(context)!.tutorialSettingsReactivate,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(0xFF2196F3),
                                                      ),
                                                    ),
                                                  ],
                                                ),
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
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.blue.withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                AppLocalizations.of(context)!.tutorialSettingsWillShow,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
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
                      child: GestureDetector(
                        onTap: _resetAllTutorials,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFF57F17)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 1,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.restart_alt_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                AppLocalizations.of(context)!.tutorialSettingsResetAll,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A2A1F).withOpacity(0.6),
            const Color(0xFF0F1815).withOpacity(0.4),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withOpacity(0.2),
          ),
          child: const Icon(
            Icons.school_rounded,
            color: Colors.blue,
            size: 20,
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.tutorialSettingsWidgetTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          AppLocalizations.of(context)!.tutorialSettingsWidgetSubtitle,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: Colors.white54,
        ),
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
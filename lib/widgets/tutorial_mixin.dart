import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:happygoal/widgets/tutorial_overlay.dart';

import '../utils/tutorial_manager.dart';

mixin TutorialMixin<T extends StatefulWidget> on State<T> {
  bool _tutorialShown = false;

  Future<void> showTutorialIfNeeded(String screenName, List<TutorialStep> steps) async {
    if (!_tutorialShown && mounted) {
      final shouldShow = await TutorialManager.shouldShowTutorial(screenName);
      if (shouldShow && mounted) {
        _tutorialShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showTutorial(screenName, steps);
        });
      }
    }
  }

  void _showTutorial(String screenName, List<TutorialStep> steps) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => TutorialOverlay(
        steps: steps,
        onComplete: () {
          Navigator.of(context).pop();
          TutorialManager.markTutorialAsShown(screenName);
        },
        onSkip: () {
          TutorialManager.markTutorialAsShown(screenName);
        },
      ),
    );
  }

  void forceTutorial(String screenName, List<TutorialStep> steps) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTutorial(screenName, steps);
    });
  }
}
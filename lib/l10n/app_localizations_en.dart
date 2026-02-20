// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HappyGoal';

  @override
  String get welcomeMessage => 'Welcome to HappyGoal!';

  @override
  String get chooseCountry => 'Choose the country you will represent in your Hero adventure';

  @override
  String get startAdventure => 'Ready for a penalty shootout?';

  @override
  String get swipeUp => 'SWIPE UP';

  @override
  String get shots => 'SHOTS';

  @override
  String get goal => 'Goal!';

  @override
  String get miss => 'Miss!';

  @override
  String get team => 'Team';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get french => 'French';

  @override
  String get english => 'English';

  @override
  String get shop => 'Shop';

  @override
  String get shopDescription => 'Your coins are here. Tap to open the shop!';

  @override
  String get dailyGift => 'Daily Gift';

  @override
  String get dailyGiftDescription => 'Collect your free coins here!';

  @override
  String get achievements => 'Achievements';

  @override
  String get achievementsDescription => 'Check your achievements and claim your rewards!';

  @override
  String get subtitle => 'THE PENALTY CHALLENGE';

  @override
  String get invite => 'Invite';

  @override
  String get rules => 'Rules';

  @override
  String get playButton => 'PLAY';

  @override
  String get splashTitle => 'HappyGoal';

  @override
  String get splashSubtitle => 'The penalty shootout challenge';

  @override
  String get splashLoading => 'Loading...';

  @override
  String get splashRequiredUpdateTitle => 'Update required';

  @override
  String get splashRequiredUpdateContent => 'A new version of HappyGoal is available.\n\nThis update is required to enjoy online features and tournaments.\n\nPlease update to continue.';

  @override
  String get splashRequiredUpdateButton => 'UPDATE NOW';

  @override
  String get modeSelectionTitle => 'Choose a mode';

  @override
  String get modeSelectionSubtitle => 'Select your challenge';

  @override
  String get modeHeroTitle => 'HERO MODE';

  @override
  String get modeHeroSubtitle => 'Progress through 100 levels';

  @override
  String get modeMultiplayerTitle => 'MULTIPLAYER MODE';

  @override
  String get modeMultiplayerSubtitle => 'Challenge a friend';

  @override
  String get modeTournamentTitle => 'TOURNAMENT MODE';

  @override
  String get modeTournamentSubtitle => 'Win the championship';

  @override
  String get modeBack => 'Back';

  @override
  String get heroModeTitle => 'HERO MODE';

  @override
  String get heroModeEnd => 'END';

  @override
  String get heroModeStart => 'START';

  @override
  String get heroModeResetTitle => 'Change country?';

  @override
  String get heroModeResetContent => 'You will lose your progress. Do you want to restart?';

  @override
  String get heroModeResetCancel => 'Cancel';

  @override
  String get heroModeResetConfirm => 'Restart';

  @override
  String heroModeRewardTitle(Object level) {
    return 'Level $level reward';
  }

  @override
  String heroModeRewardDescription(Object coins) {
    return 'Watch a video to earn $coins coins!';
  }

  @override
  String heroModeRewardAdded(Object coins) {
    return '+$coins coins added!';
  }

  @override
  String get heroModeRewardAdUnavailable => 'Ad unavailable or loading error.';

  @override
  String get heroTeamSelectHeader1 => 'CHOOSE';

  @override
  String get heroTeamSelectHeader2 => 'YOUR COUNTRY';

  @override
  String get heroTeamSelectSubtitle => 'Choose the country you will represent in your Hero adventure';

  @override
  String get heroTeamSelectStart => 'START THE ADVENTURE';

  @override
  String heroTransitionChapter(Object level) {
    return 'CHAPTER $level';
  }

  @override
  String get heroTransitionVS => 'VS';

  @override
  String get heroTransitionYou => 'YOU';

  @override
  String get heroTransitionBestResult => 'YOUR BEST RESULT';

  @override
  String get heroTransitionStart => 'START MATCH';

  @override
  String heroTransitionStoryStart(Object myTeam, Object opponent) {
    return 'The adventure begins! You represent $myTeam and your first opponent is $opponent. Show your talent!';
  }

  @override
  String heroTransitionStoryEnd(Object opponent) {
    return 'The ultimate challenge! After a legendary journey, you face $opponent for eternal glory.';
  }

  @override
  String heroTransitionStoryLevel(Object level, Object myTeam, Object opponent) {
    return 'Level $level: $myTeam faces $opponent in a decisive duel. Prove your worth!';
  }

  @override
  String heroResultChapter(Object level) {
    return 'CHAPTER $level';
  }

  @override
  String get heroResultVictory => 'VICTORY!';

  @override
  String get heroResultDefeat => 'DEFEAT';

  @override
  String get heroResultVictorySubtitle => 'Congratulations on your victory!';

  @override
  String get heroResultDefeatSubtitle => 'The AI won this round';

  @override
  String get heroResultYou => 'YOU';

  @override
  String get heroResultOpponent => 'OPP.';

  @override
  String heroResultLevel(Object level) {
    return 'Level $level';
  }

  @override
  String get heroResultObjectives => 'OBJECTIVES';

  @override
  String get heroResultNextLevel => 'NEXT LEVEL';

  @override
  String get heroResultBack => 'BACK';

  @override
  String get teamSelectionTitle => 'Team Selection';

  @override
  String get teamSelectionModeSolo => 'Solo Mode';

  @override
  String get teamSelectionModeMulti => 'Multiplayer Mode';

  @override
  String get teamSelectionModeTournament => 'Tournament Mode';

  @override
  String get teamSelectionChooseTeams => 'Choose your team and the opponent team controlled by the computer';

  @override
  String get teamSelectionTeam1 => 'Team 1';

  @override
  String get teamSelectionTeam2 => 'Team 2';

  @override
  String get teamSelectionYourTeam => 'Your Team';

  @override
  String get teamSelectionAITeam => 'AI Team';

  @override
  String get teamSelectionToSelect => 'To select';

  @override
  String get teamSelectionStart => 'START MATCH';

  @override
  String get teamSelectionSelectTwo => 'Please select two teams';

  @override
  String get resultGreat => 'GREAT!';

  @override
  String get resultDefeat => 'Defeat';

  @override
  String get resultVictory => 'Victory!';

  @override
  String get resultDefeatSubtitle => 'The AI won this round';

  @override
  String get resultVictorySubtitle => 'Congratulations on your victory!';

  @override
  String get resultCoin => '+1 COIN WON!';

  @override
  String get resultRematch => 'Rematch';

  @override
  String get resultBackToMenu => 'Back to Menu';

  @override
  String get resultChangeTeam => 'Change Team';

  @override
  String get resultShots => 'Shots';

  @override
  String resultLastShots(Object count) {
    return 'Last $count shots';
  }
}

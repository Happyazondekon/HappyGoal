import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'HappyGoal'**
  String get appTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to HappyGoal!'**
  String get welcomeMessage;

  /// No description provided for @chooseCountry.
  ///
  /// In en, this message translates to:
  /// **'Choose the country you will represent in your Hero adventure'**
  String get chooseCountry;

  /// No description provided for @startAdventure.
  ///
  /// In en, this message translates to:
  /// **'Ready for a penalty shootout?'**
  String get startAdventure;

  /// No description provided for @swipeUp.
  ///
  /// In en, this message translates to:
  /// **'SWIPE UP'**
  String get swipeUp;

  /// No description provided for @shots.
  ///
  /// In en, this message translates to:
  /// **'SHOTS'**
  String get shots;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal!'**
  String get goal;

  /// No description provided for @miss.
  ///
  /// In en, this message translates to:
  /// **'Miss!'**
  String get miss;

  /// No description provided for @team.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get team;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// No description provided for @shopDescription.
  ///
  /// In en, this message translates to:
  /// **'Your coins are here. Tap to open the shop!'**
  String get shopDescription;

  /// No description provided for @dailyGift.
  ///
  /// In en, this message translates to:
  /// **'Daily Gift'**
  String get dailyGift;

  /// No description provided for @dailyGiftDescription.
  ///
  /// In en, this message translates to:
  /// **'Collect your free coins here!'**
  String get dailyGiftDescription;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @achievementsDescription.
  ///
  /// In en, this message translates to:
  /// **'Check your achievements and claim your rewards!'**
  String get achievementsDescription;

  /// No description provided for @subtitle.
  ///
  /// In en, this message translates to:
  /// **'THE PENALTY CHALLENGE'**
  String get subtitle;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// No description provided for @rules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get rules;

  /// No description provided for @playButton.
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get playButton;

  /// No description provided for @splashTitle.
  ///
  /// In en, this message translates to:
  /// **'HappyGoal'**
  String get splashTitle;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The penalty shootout challenge'**
  String get splashSubtitle;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get splashLoading;

  /// No description provided for @splashRequiredUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get splashRequiredUpdateTitle;

  /// No description provided for @splashRequiredUpdateContent.
  ///
  /// In en, this message translates to:
  /// **'A new version of HappyGoal is available.\n\nThis update is required to enjoy online features and tournaments.\n\nPlease update to continue.'**
  String get splashRequiredUpdateContent;

  /// No description provided for @splashRequiredUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'UPDATE NOW'**
  String get splashRequiredUpdateButton;

  /// No description provided for @modeSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a mode'**
  String get modeSelectionTitle;

  /// No description provided for @modeSelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your challenge'**
  String get modeSelectionSubtitle;

  /// No description provided for @modeHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'HERO MODE'**
  String get modeHeroTitle;

  /// No description provided for @modeHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Progress through 100 levels'**
  String get modeHeroSubtitle;

  /// No description provided for @modeMultiplayerTitle.
  ///
  /// In en, this message translates to:
  /// **'MULTIPLAYER MODE'**
  String get modeMultiplayerTitle;

  /// No description provided for @modeMultiplayerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Challenge a friend'**
  String get modeMultiplayerSubtitle;

  /// No description provided for @modeTournamentTitle.
  ///
  /// In en, this message translates to:
  /// **'TOURNAMENT MODE'**
  String get modeTournamentTitle;

  /// No description provided for @modeTournamentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Win the championship'**
  String get modeTournamentSubtitle;

  /// No description provided for @modeBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get modeBack;

  /// No description provided for @heroModeTitle.
  ///
  /// In en, this message translates to:
  /// **'HERO MODE'**
  String get heroModeTitle;

  /// No description provided for @heroModeEnd.
  ///
  /// In en, this message translates to:
  /// **'END'**
  String get heroModeEnd;

  /// No description provided for @heroModeStart.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get heroModeStart;

  /// No description provided for @heroModeResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Change country?'**
  String get heroModeResetTitle;

  /// No description provided for @heroModeResetContent.
  ///
  /// In en, this message translates to:
  /// **'You will lose your progress. Do you want to restart?'**
  String get heroModeResetContent;

  /// No description provided for @heroModeResetCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get heroModeResetCancel;

  /// No description provided for @heroModeResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get heroModeResetConfirm;

  /// No description provided for @heroModeRewardTitle.
  ///
  /// In en, this message translates to:
  /// **'Level {level} reward'**
  String heroModeRewardTitle(Object level);

  /// No description provided for @heroModeRewardDescription.
  ///
  /// In en, this message translates to:
  /// **'Watch a video to earn {coins} coins!'**
  String heroModeRewardDescription(Object coins);

  /// No description provided for @heroModeRewardAdded.
  ///
  /// In en, this message translates to:
  /// **'+{coins} coins added!'**
  String heroModeRewardAdded(Object coins);

  /// No description provided for @heroModeRewardAdUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Ad unavailable or loading error.'**
  String get heroModeRewardAdUnavailable;

  /// No description provided for @heroTeamSelectHeader1.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE'**
  String get heroTeamSelectHeader1;

  /// No description provided for @heroTeamSelectHeader2.
  ///
  /// In en, this message translates to:
  /// **'YOUR COUNTRY'**
  String get heroTeamSelectHeader2;

  /// No description provided for @heroTeamSelectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the country you will represent in your Hero adventure'**
  String get heroTeamSelectSubtitle;

  /// No description provided for @heroTeamSelectStart.
  ///
  /// In en, this message translates to:
  /// **'START THE ADVENTURE'**
  String get heroTeamSelectStart;

  /// No description provided for @heroTransitionChapter.
  ///
  /// In en, this message translates to:
  /// **'CHAPTER {level}'**
  String heroTransitionChapter(Object level);

  /// No description provided for @heroTransitionVS.
  ///
  /// In en, this message translates to:
  /// **'VS'**
  String get heroTransitionVS;

  /// No description provided for @heroTransitionYou.
  ///
  /// In en, this message translates to:
  /// **'YOU'**
  String get heroTransitionYou;

  /// No description provided for @heroTransitionBestResult.
  ///
  /// In en, this message translates to:
  /// **'YOUR BEST RESULT'**
  String get heroTransitionBestResult;

  /// No description provided for @heroTransitionStart.
  ///
  /// In en, this message translates to:
  /// **'START MATCH'**
  String get heroTransitionStart;

  /// No description provided for @heroTransitionStoryStart.
  ///
  /// In en, this message translates to:
  /// **'The adventure begins! You represent {myTeam} and your first opponent is {opponent}. Show your talent!'**
  String heroTransitionStoryStart(Object myTeam, Object opponent);

  /// No description provided for @heroTransitionStoryEnd.
  ///
  /// In en, this message translates to:
  /// **'The ultimate challenge! After a legendary journey, you face {opponent} for eternal glory.'**
  String heroTransitionStoryEnd(Object opponent);

  /// No description provided for @heroTransitionStoryLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}: {myTeam} faces {opponent} in a decisive duel. Prove your worth!'**
  String heroTransitionStoryLevel(Object level, Object myTeam, Object opponent);

  /// No description provided for @heroResultChapter.
  ///
  /// In en, this message translates to:
  /// **'CHAPTER {level}'**
  String heroResultChapter(Object level);

  /// No description provided for @heroResultVictory.
  ///
  /// In en, this message translates to:
  /// **'VICTORY!'**
  String get heroResultVictory;

  /// No description provided for @heroResultDefeat.
  ///
  /// In en, this message translates to:
  /// **'DEFEAT'**
  String get heroResultDefeat;

  /// No description provided for @heroResultVictorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Congratulations on your victory!'**
  String get heroResultVictorySubtitle;

  /// No description provided for @heroResultDefeatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The AI won this round'**
  String get heroResultDefeatSubtitle;

  /// No description provided for @heroResultYou.
  ///
  /// In en, this message translates to:
  /// **'YOU'**
  String get heroResultYou;

  /// No description provided for @heroResultOpponent.
  ///
  /// In en, this message translates to:
  /// **'OPP.'**
  String get heroResultOpponent;

  /// No description provided for @heroResultLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String heroResultLevel(Object level);

  /// No description provided for @heroResultObjectives.
  ///
  /// In en, this message translates to:
  /// **'OBJECTIVES'**
  String get heroResultObjectives;

  /// No description provided for @heroResultNextLevel.
  ///
  /// In en, this message translates to:
  /// **'NEXT LEVEL'**
  String get heroResultNextLevel;

  /// No description provided for @heroResultBack.
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get heroResultBack;

  /// No description provided for @teamSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Team Selection'**
  String get teamSelectionTitle;

  /// No description provided for @teamSelectionModeSolo.
  ///
  /// In en, this message translates to:
  /// **'Solo Mode'**
  String get teamSelectionModeSolo;

  /// No description provided for @teamSelectionModeMulti.
  ///
  /// In en, this message translates to:
  /// **'Multiplayer Mode'**
  String get teamSelectionModeMulti;

  /// No description provided for @teamSelectionModeTournament.
  ///
  /// In en, this message translates to:
  /// **'Tournament Mode'**
  String get teamSelectionModeTournament;

  /// No description provided for @teamSelectionChooseTeams.
  ///
  /// In en, this message translates to:
  /// **'Choose your team and the opponent team controlled by the computer'**
  String get teamSelectionChooseTeams;

  /// No description provided for @teamSelectionTeam1.
  ///
  /// In en, this message translates to:
  /// **'Team 1'**
  String get teamSelectionTeam1;

  /// No description provided for @teamSelectionTeam2.
  ///
  /// In en, this message translates to:
  /// **'Team 2'**
  String get teamSelectionTeam2;

  /// No description provided for @teamSelectionYourTeam.
  ///
  /// In en, this message translates to:
  /// **'Your Team'**
  String get teamSelectionYourTeam;

  /// No description provided for @teamSelectionAITeam.
  ///
  /// In en, this message translates to:
  /// **'AI Team'**
  String get teamSelectionAITeam;

  /// No description provided for @teamSelectionToSelect.
  ///
  /// In en, this message translates to:
  /// **'To select'**
  String get teamSelectionToSelect;

  /// No description provided for @teamSelectionStart.
  ///
  /// In en, this message translates to:
  /// **'START MATCH'**
  String get teamSelectionStart;

  /// No description provided for @teamSelectionSelectTwo.
  ///
  /// In en, this message translates to:
  /// **'Please select two teams'**
  String get teamSelectionSelectTwo;

  /// No description provided for @resultGreat.
  ///
  /// In en, this message translates to:
  /// **'GREAT!'**
  String get resultGreat;

  /// No description provided for @resultDefeat.
  ///
  /// In en, this message translates to:
  /// **'Defeat'**
  String get resultDefeat;

  /// No description provided for @resultVictory.
  ///
  /// In en, this message translates to:
  /// **'Victory!'**
  String get resultVictory;

  /// No description provided for @resultDefeatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The AI won this round'**
  String get resultDefeatSubtitle;

  /// No description provided for @resultVictorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Congratulations on your victory!'**
  String get resultVictorySubtitle;

  /// No description provided for @resultCoin.
  ///
  /// In en, this message translates to:
  /// **'+1 COIN WON!'**
  String get resultCoin;

  /// No description provided for @resultRematch.
  ///
  /// In en, this message translates to:
  /// **'Rematch'**
  String get resultRematch;

  /// No description provided for @resultBackToMenu.
  ///
  /// In en, this message translates to:
  /// **'Back to Menu'**
  String get resultBackToMenu;

  /// No description provided for @resultChangeTeam.
  ///
  /// In en, this message translates to:
  /// **'Change Team'**
  String get resultChangeTeam;

  /// No description provided for @resultShots.
  ///
  /// In en, this message translates to:
  /// **'Shots'**
  String get resultShots;

  /// No description provided for @resultLastShots.
  ///
  /// In en, this message translates to:
  /// **'Last {count} shots'**
  String resultLastShots(Object count);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}

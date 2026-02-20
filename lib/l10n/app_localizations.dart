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

  /// No description provided for @tournamentStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'TOURNAMENT STATISTICS'**
  String get tournamentStatsTitle;

  /// No description provided for @tournamentStatsLast.
  ///
  /// In en, this message translates to:
  /// **'Last: {date}'**
  String tournamentStatsLast(Object date);

  /// No description provided for @tournamentStatsPlayed.
  ///
  /// In en, this message translates to:
  /// **'Played'**
  String get tournamentStatsPlayed;

  /// No description provided for @tournamentStatsWon.
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get tournamentStatsWon;

  /// No description provided for @tournamentStatsVictory.
  ///
  /// In en, this message translates to:
  /// **'Victory'**
  String get tournamentStatsVictory;

  /// No description provided for @tournamentStatsRewinds.
  ///
  /// In en, this message translates to:
  /// **'Rewinds'**
  String get tournamentStatsRewinds;

  /// No description provided for @tournamentStatsGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get tournamentStatsGoals;

  /// No description provided for @tournamentStatsMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get tournamentStatsMatches;

  /// No description provided for @tournamentStatsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get tournamentStatsReset;

  /// No description provided for @tournamentStatsResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset statistics'**
  String get tournamentStatsResetTitle;

  /// No description provided for @tournamentStatsResetContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all your tournament statistics? This action is irreversible.'**
  String get tournamentStatsResetContent;

  /// No description provided for @tournamentStatsResetCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get tournamentStatsResetCancel;

  /// No description provided for @tournamentStatsResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get tournamentStatsResetConfirm;

  /// No description provided for @tournamentStatsResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Statistics successfully reset'**
  String get tournamentStatsResetSuccess;

  /// No description provided for @tournamentStatsClickToView.
  ///
  /// In en, this message translates to:
  /// **'Click to view your performance'**
  String get tournamentStatsClickToView;

  /// No description provided for @tournamentStatsMotivationStart.
  ///
  /// In en, this message translates to:
  /// **'Start your first tournament! 🚀'**
  String get tournamentStatsMotivationStart;

  /// No description provided for @tournamentStatsMotivationChampion.
  ///
  /// In en, this message translates to:
  /// **'Excellent win rate! You are a champion! 🏆'**
  String get tournamentStatsMotivationChampion;

  /// No description provided for @tournamentStatsMotivationGood.
  ///
  /// In en, this message translates to:
  /// **'Good win rate! Keep it up! 💪'**
  String get tournamentStatsMotivationGood;

  /// No description provided for @tournamentStatsMotivationOpportunity.
  ///
  /// In en, this message translates to:
  /// **'Every tournament is a new opportunity! 🔥'**
  String get tournamentStatsMotivationOpportunity;

  /// No description provided for @tournamentStatsMotivationPerseverance.
  ///
  /// In en, this message translates to:
  /// **'Perseverance is the key to success! Never give up! ⚽'**
  String get tournamentStatsMotivationPerseverance;

  /// No description provided for @tournamentHappyTitle.
  ///
  /// In en, this message translates to:
  /// **'HAPPY TOURNAMENT'**
  String get tournamentHappyTitle;

  /// No description provided for @tournamentPathToGlory.
  ///
  /// In en, this message translates to:
  /// **'Path to glory'**
  String get tournamentPathToGlory;

  /// No description provided for @tournamentPhaseRoundOf16.
  ///
  /// In en, this message translates to:
  /// **'ROUND OF 16'**
  String get tournamentPhaseRoundOf16;

  /// No description provided for @tournamentPhaseQuarterFinals.
  ///
  /// In en, this message translates to:
  /// **'QUARTER FINALS'**
  String get tournamentPhaseQuarterFinals;

  /// No description provided for @tournamentPhaseSemiFinals.
  ///
  /// In en, this message translates to:
  /// **'SEMI-FINALS'**
  String get tournamentPhaseSemiFinals;

  /// No description provided for @tournamentPhaseFinal.
  ///
  /// In en, this message translates to:
  /// **'GRAND FINAL'**
  String get tournamentPhaseFinal;

  /// No description provided for @tournamentYourTeam.
  ///
  /// In en, this message translates to:
  /// **'YOUR TEAM'**
  String get tournamentYourTeam;

  /// No description provided for @tournamentReadyToFight.
  ///
  /// In en, this message translates to:
  /// **'READY TO FIGHT'**
  String get tournamentReadyToFight;

  /// No description provided for @tournamentFourMatches.
  ///
  /// In en, this message translates to:
  /// **'⚡ 4 MATCHES FOR VICTORY ⚡'**
  String get tournamentFourMatches;

  /// No description provided for @tournamentChooseTeam.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE YOUR TEAM'**
  String get tournamentChooseTeam;

  /// No description provided for @tournamentChangeTeam.
  ///
  /// In en, this message translates to:
  /// **'CHANGE TEAM'**
  String get tournamentChangeTeam;

  /// No description provided for @tournamentNotEnoughTeams.
  ///
  /// In en, this message translates to:
  /// **'Not enough teams for a full tournament'**
  String get tournamentNotEnoughTeams;

  /// No description provided for @tournamentStart.
  ///
  /// In en, this message translates to:
  /// **'START TOURNAMENT'**
  String get tournamentStart;

  /// No description provided for @tournamentResultChampion.
  ///
  /// In en, this message translates to:
  /// **'CHAMPION!'**
  String get tournamentResultChampion;

  /// No description provided for @tournamentResultGoodPerformance.
  ///
  /// In en, this message translates to:
  /// **'GOOD PERFORMANCE!'**
  String get tournamentResultGoodPerformance;

  /// No description provided for @tournamentResultDefeat.
  ///
  /// In en, this message translates to:
  /// **'DEFEAT'**
  String get tournamentResultDefeat;

  /// No description provided for @tournamentResultTournamentWon.
  ///
  /// In en, this message translates to:
  /// **'TOURNAMENT WON'**
  String get tournamentResultTournamentWon;

  /// No description provided for @tournamentResultEliminated.
  ///
  /// In en, this message translates to:
  /// **'ELIMINATED'**
  String get tournamentResultEliminated;

  /// No description provided for @tournamentResultEndOfJourney.
  ///
  /// In en, this message translates to:
  /// **'END OF JOURNEY'**
  String get tournamentResultEndOfJourney;

  /// No description provided for @tournamentResultCoins.
  ///
  /// In en, this message translates to:
  /// **'+25 COINS'**
  String get tournamentResultCoins;

  /// No description provided for @tournamentResultResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'TOURNAMENT RESULTS'**
  String get tournamentResultResultsTitle;

  /// No description provided for @tournamentResultChampionBadge.
  ///
  /// In en, this message translates to:
  /// **'🏆 CHAMPION'**
  String get tournamentResultChampionBadge;

  /// No description provided for @tournamentResultFighterBadge.
  ///
  /// In en, this message translates to:
  /// **'⚔️ FIGHTER'**
  String get tournamentResultFighterBadge;

  /// No description provided for @tournamentResultEliminatedBadge.
  ///
  /// In en, this message translates to:
  /// **'💔 ELIMINATED'**
  String get tournamentResultEliminatedBadge;

  /// No description provided for @tournamentResultWins.
  ///
  /// In en, this message translates to:
  /// **'WINS'**
  String get tournamentResultWins;

  /// No description provided for @tournamentResultLosses.
  ///
  /// In en, this message translates to:
  /// **'LOSSES'**
  String get tournamentResultLosses;

  /// No description provided for @tournamentResultTotal.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get tournamentResultTotal;

  /// No description provided for @tournamentResultBackHome.
  ///
  /// In en, this message translates to:
  /// **'BACK TO HOME'**
  String get tournamentResultBackHome;

  /// No description provided for @tournamentResultNewTournament.
  ///
  /// In en, this message translates to:
  /// **'NEW TOURNAMENT'**
  String get tournamentResultNewTournament;

  /// No description provided for @tournamentResultAchievementsUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievements Unlocked!'**
  String get tournamentResultAchievementsUnlocked;

  /// No description provided for @tournamentResultSuccessGreat.
  ///
  /// In en, this message translates to:
  /// **'GREAT!'**
  String get tournamentResultSuccessGreat;

  /// No description provided for @tournamentResultSnackChampion.
  ///
  /// In en, this message translates to:
  /// **'CHAMPION! +25 COINS WON!'**
  String get tournamentResultSnackChampion;

  /// No description provided for @gameResultLob.
  ///
  /// In en, this message translates to:
  /// **'GOAL on LOB 🎯'**
  String get gameResultLob;

  /// No description provided for @gameResultCurve.
  ///
  /// In en, this message translates to:
  /// **'GOAL with CURVE 🔥'**
  String get gameResultCurve;

  /// No description provided for @gameResultKnuckle.
  ///
  /// In en, this message translates to:
  /// **'KNUCKLE GOAL ⚡'**
  String get gameResultKnuckle;

  /// No description provided for @gameResultSoft.
  ///
  /// In en, this message translates to:
  /// **'SOFT GOAL 💨'**
  String get gameResultSoft;

  /// No description provided for @gameResultGoal.
  ///
  /// In en, this message translates to:
  /// **'GOOOAL!'**
  String get gameResultGoal;

  /// No description provided for @gameResultWeakShot.
  ///
  /// In en, this message translates to:
  /// **'SHOT TOO WEAK 😢'**
  String get gameResultWeakShot;

  /// No description provided for @gameResultSaved.
  ///
  /// In en, this message translates to:
  /// **'GOALKEEPER SAVE!'**
  String get gameResultSaved;

  /// No description provided for @gameNextMatch.
  ///
  /// In en, this message translates to:
  /// **'Next match: {phase}'**
  String gameNextMatch(Object phase);

  /// No description provided for @gameMissedShot.
  ///
  /// In en, this message translates to:
  /// **'MISSED SHOT!'**
  String get gameMissedShot;

  /// No description provided for @gameSecondChance.
  ///
  /// In en, this message translates to:
  /// **'Second chance available'**
  String get gameSecondChance;

  /// No description provided for @gameUseRewind.
  ///
  /// In en, this message translates to:
  /// **'Use a rewind?\n(Remaining: {count})'**
  String gameUseRewind(Object count);

  /// No description provided for @gameContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get gameContinue;

  /// No description provided for @gameRewind.
  ///
  /// In en, this message translates to:
  /// **'Rewind'**
  String get gameRewind;

  /// No description provided for @gameRewindSuccess.
  ///
  /// In en, this message translates to:
  /// **'Shot rewound!'**
  String get gameRewindSuccess;

  /// No description provided for @gameRewindFailed.
  ///
  /// In en, this message translates to:
  /// **'Rewind failed!'**
  String get gameRewindFailed;

  /// No description provided for @gameRoundReset.
  ///
  /// In en, this message translates to:
  /// **'Round reset!'**
  String get gameRoundReset;

  /// No description provided for @gameGoalScored.
  ///
  /// In en, this message translates to:
  /// **'Goal scored!'**
  String get gameGoalScored;

  /// No description provided for @gameGoalSaved.
  ///
  /// In en, this message translates to:
  /// **'Goal saved!'**
  String get gameGoalSaved;

  /// No description provided for @gameWhistle.
  ///
  /// In en, this message translates to:
  /// **'Whistle!'**
  String get gameWhistle;

  /// No description provided for @gameSuddenDeath.
  ///
  /// In en, this message translates to:
  /// **'SUDDEN DEATH'**
  String get gameSuddenDeath;

  /// No description provided for @gameAIShootingPrompt.
  ///
  /// In en, this message translates to:
  /// **'AI is shooting - Choose your dive!'**
  String get gameAIShootingPrompt;

  /// No description provided for @gameAITurnWait.
  ///
  /// In en, this message translates to:
  /// **'AI\'s turn - Please wait...'**
  String get gameAITurnWait;

  /// No description provided for @coinInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Treasury'**
  String get coinInfoTitle;

  /// No description provided for @coinInfoBalance.
  ///
  /// In en, this message translates to:
  /// **'Your Balance'**
  String get coinInfoBalance;

  /// No description provided for @coinInfoAdReward.
  ///
  /// In en, this message translates to:
  /// **'Ad Reward'**
  String get coinInfoAdReward;

  /// No description provided for @coinInfoShop.
  ///
  /// In en, this message translates to:
  /// **'SHOP'**
  String get coinInfoShop;

  /// No description provided for @coinInfoShopAdded.
  ///
  /// In en, this message translates to:
  /// **'+{coins} coins added!'**
  String coinInfoShopAdded(Object coins);

  /// No description provided for @coinInfoShopUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Ad unavailable.'**
  String get coinInfoShopUnavailable;

  /// No description provided for @coinInfoShopGift.
  ///
  /// In en, this message translates to:
  /// **'Daily Gift'**
  String get coinInfoShopGift;

  /// No description provided for @coinInfoShopGiftDesc.
  ///
  /// In en, this message translates to:
  /// **'Watch a video to earn {coins} coins!'**
  String coinInfoShopGiftDesc(Object coins);

  /// No description provided for @coinInfoShopPubFree.
  ///
  /// In en, this message translates to:
  /// **'Free Ad'**
  String get coinInfoShopPubFree;

  /// No description provided for @coinInfoShopUseCoins.
  ///
  /// In en, this message translates to:
  /// **'Use your coins to buy rewinds!'**
  String get coinInfoShopUseCoins;

  /// No description provided for @settingsOptions.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get settingsOptions;

  /// No description provided for @settingsClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get settingsClose;

  /// No description provided for @rulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Game Rules'**
  String get rulesTitle;

  /// No description provided for @rules1.
  ///
  /// In en, this message translates to:
  /// **'1. Choose a direction to shoot.'**
  String get rules1;

  /// No description provided for @rules2.
  ///
  /// In en, this message translates to:
  /// **'2. The goalkeeper dives randomly.'**
  String get rules2;

  /// No description provided for @rules3.
  ///
  /// In en, this message translates to:
  /// **'3. Score 5 goals to win!'**
  String get rules3;

  /// No description provided for @rules4.
  ///
  /// In en, this message translates to:
  /// **'4. Use rewinds if you miss.'**
  String get rules4;

  /// No description provided for @rulesUnderstood.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get rulesUnderstood;

  /// No description provided for @inviteShareText.
  ///
  /// In en, this message translates to:
  /// **'HappyGoal! ⚽\n\nCome take penalties and challenge me!\nDownload: https://play.google.com/store/apps/details?id=com.heyhappy.happygoal'**
  String get inviteShareText;

  /// No description provided for @inviteShareSubject.
  ///
  /// In en, this message translates to:
  /// **'HappyGoal'**
  String get inviteShareSubject;

  /// No description provided for @achievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// No description provided for @achievementsUnlocked.
  ///
  /// In en, this message translates to:
  /// **'{unlocked} / {total} unlocked'**
  String achievementsUnlocked(Object total, Object unlocked);

  /// No description provided for @achievementsCategoryMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get achievementsCategoryMatches;

  /// No description provided for @achievementsCategoryGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get achievementsCategoryGoals;

  /// No description provided for @achievementsCategoryTournaments.
  ///
  /// In en, this message translates to:
  /// **'Tournaments'**
  String get achievementsCategoryTournaments;

  /// No description provided for @achievementsCategorySpecial.
  ///
  /// In en, this message translates to:
  /// **'Special'**
  String get achievementsCategorySpecial;

  /// No description provided for @achievementsCategorySkills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get achievementsCategorySkills;

  /// No description provided for @achievementsStatWins.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get achievementsStatWins;

  /// No description provided for @achievementsProgressGlobal.
  ///
  /// In en, this message translates to:
  /// **'Global Progress'**
  String get achievementsProgressGlobal;

  /// No description provided for @achievementsNone.
  ///
  /// In en, this message translates to:
  /// **'No achievements in this category'**
  String get achievementsNone;

  /// No description provided for @achievementsClaimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get achievementsClaimed;

  /// No description provided for @achievementsReward.
  ///
  /// In en, this message translates to:
  /// **'+{coins} coins'**
  String achievementsReward(Object coins);

  /// No description provided for @achievementsSnackClaimed.
  ///
  /// In en, this message translates to:
  /// **'+{coins} coins claimed!'**
  String achievementsSnackClaimed(Object coins);

  /// No description provided for @achievementsProgress.
  ///
  /// In en, this message translates to:
  /// **'{current}/{target}'**
  String achievementsProgress(Object current, Object target);

  /// No description provided for @achievementsRarityCommon.
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get achievementsRarityCommon;

  /// No description provided for @achievementsRarityRare.
  ///
  /// In en, this message translates to:
  /// **'Rare'**
  String get achievementsRarityRare;

  /// No description provided for @achievementsRarityEpic.
  ///
  /// In en, this message translates to:
  /// **'Epic'**
  String get achievementsRarityEpic;

  /// No description provided for @achievementsRarityLegendary.
  ///
  /// In en, this message translates to:
  /// **'Legendary'**
  String get achievementsRarityLegendary;

  /// No description provided for @achievementsBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get achievementsBack;

  /// No description provided for @achievementsCompletionPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String achievementsCompletionPercent(Object percent);

  /// No description provided for @achievementsProgressBar.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String achievementsProgressBar(Object percent);

  /// No description provided for @tutorialSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tutorials'**
  String get tutorialSettingsTitle;

  /// No description provided for @tutorialSettingsHeader.
  ///
  /// In en, this message translates to:
  /// **'Tutorial management'**
  String get tutorialSettingsHeader;

  /// No description provided for @tutorialSettingsHeaderDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage tutorial display for each screen. Tutorials marked as \'Seen\' will no longer show automatically.'**
  String get tutorialSettingsHeaderDesc;

  /// No description provided for @tutorialSettingsHome.
  ///
  /// In en, this message translates to:
  /// **'Home screen'**
  String get tutorialSettingsHome;

  /// No description provided for @tutorialSettingsModeSelection.
  ///
  /// In en, this message translates to:
  /// **'Mode selection'**
  String get tutorialSettingsModeSelection;

  /// No description provided for @tutorialSettingsTeamSelection.
  ///
  /// In en, this message translates to:
  /// **'Team selection'**
  String get tutorialSettingsTeamSelection;

  /// No description provided for @tutorialSettingsGameSolo.
  ///
  /// In en, this message translates to:
  /// **'Solo game'**
  String get tutorialSettingsGameSolo;

  /// No description provided for @tutorialSettingsGameMulti.
  ///
  /// In en, this message translates to:
  /// **'Multiplayer game'**
  String get tutorialSettingsGameMulti;

  /// No description provided for @tutorialSettingsTournament.
  ///
  /// In en, this message translates to:
  /// **'Tournament mode'**
  String get tutorialSettingsTournament;

  /// No description provided for @tutorialSettingsHomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Guide to main features'**
  String get tutorialSettingsHomeDesc;

  /// No description provided for @tutorialSettingsModeSelectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Explanation of game modes'**
  String get tutorialSettingsModeSelectionDesc;

  /// No description provided for @tutorialSettingsTeamSelectionDesc.
  ///
  /// In en, this message translates to:
  /// **'How to choose your teams'**
  String get tutorialSettingsTeamSelectionDesc;

  /// No description provided for @tutorialSettingsGameSoloDesc.
  ///
  /// In en, this message translates to:
  /// **'Gameplay against AI'**
  String get tutorialSettingsGameSoloDesc;

  /// No description provided for @tutorialSettingsGameMultiDesc.
  ///
  /// In en, this message translates to:
  /// **'Two-player game'**
  String get tutorialSettingsGameMultiDesc;

  /// No description provided for @tutorialSettingsTournamentDesc.
  ///
  /// In en, this message translates to:
  /// **'Tournament navigation'**
  String get tutorialSettingsTournamentDesc;

  /// No description provided for @tutorialSettingsSeen.
  ///
  /// In en, this message translates to:
  /// **'Seen'**
  String get tutorialSettingsSeen;

  /// No description provided for @tutorialSettingsNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get tutorialSettingsNew;

  /// No description provided for @tutorialSettingsWillShow.
  ///
  /// In en, this message translates to:
  /// **'Will show automatically'**
  String get tutorialSettingsWillShow;

  /// No description provided for @tutorialSettingsReactivate.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get tutorialSettingsReactivate;

  /// No description provided for @tutorialSettingsResetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset all tutorials'**
  String get tutorialSettingsResetAll;

  /// No description provided for @tutorialSettingsResetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm reset'**
  String get tutorialSettingsResetConfirmTitle;

  /// No description provided for @tutorialSettingsResetConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all tutorials? They will show again on your next visits.'**
  String get tutorialSettingsResetConfirmContent;

  /// No description provided for @tutorialSettingsResetCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get tutorialSettingsResetCancel;

  /// No description provided for @tutorialSettingsResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get tutorialSettingsResetConfirm;

  /// No description provided for @tutorialSettingsResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'All tutorials have been reset'**
  String get tutorialSettingsResetSuccess;

  /// No description provided for @tutorialSettingsResetSingle.
  ///
  /// In en, this message translates to:
  /// **'Tutorial \'{title}\' reset'**
  String tutorialSettingsResetSingle(Object title);

  /// No description provided for @tutorialSettingsWidgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Tutorials'**
  String get tutorialSettingsWidgetTitle;

  /// No description provided for @tutorialSettingsWidgetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage guide display'**
  String get tutorialSettingsWidgetSubtitle;

  /// No description provided for @audioSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio Settings'**
  String get audioSettingsTitle;

  /// No description provided for @audioSettingsSound.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get audioSettingsSound;

  /// No description provided for @audioSettingsMusic.
  ///
  /// In en, this message translates to:
  /// **'Background music'**
  String get audioSettingsMusic;

  /// No description provided for @audioSettingsBackground.
  ///
  /// In en, this message translates to:
  /// **'Continue music in background'**
  String get audioSettingsBackground;

  /// No description provided for @audioSettingsBackgroundDesc.
  ///
  /// In en, this message translates to:
  /// **'Music continues when you leave the app'**
  String get audioSettingsBackgroundDesc;

  /// No description provided for @audioSettingsVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get audioSettingsVolume;

  /// No description provided for @coinShopTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get coinShopTitle;

  /// No description provided for @coinShopLoading.
  ///
  /// In en, this message translates to:
  /// **'Connecting to store\n(Loading...)'**
  String get coinShopLoading;

  /// No description provided for @coinShopSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get coinShopSuccessTitle;

  /// No description provided for @coinShopSuccessCoins.
  ///
  /// In en, this message translates to:
  /// **'+{coins} Coins added'**
  String coinShopSuccessCoins(Object coins);

  /// No description provided for @coinShopSuccessThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your support!'**
  String get coinShopSuccessThanks;

  /// No description provided for @coinShopSuccessButton.
  ///
  /// In en, this message translates to:
  /// **'AWESOME!'**
  String get coinShopSuccessButton;

  /// No description provided for @coinShopClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get coinShopClose;

  /// No description provided for @coinShopBestOffer.
  ///
  /// In en, this message translates to:
  /// **'BEST OFFER'**
  String get coinShopBestOffer;

  /// No description provided for @coinShopBonus10.
  ///
  /// In en, this message translates to:
  /// **'+10% BONUS'**
  String get coinShopBonus10;

  /// No description provided for @coinShopPromo17.
  ///
  /// In en, this message translates to:
  /// **'+17% PROMO'**
  String get coinShopPromo17;

  /// No description provided for @goalkeeperSwipeLabel.
  ///
  /// In en, this message translates to:
  /// **'SLIDE THE GOALKEEPER'**
  String get goalkeeperSwipeLabel;

  /// No description provided for @goalkeeperSwipeLeft.
  ///
  /// In en, this message translates to:
  /// **'DIVE LEFT'**
  String get goalkeeperSwipeLeft;

  /// No description provided for @goalkeeperSwipeSlightLeft.
  ///
  /// In en, this message translates to:
  /// **'SLIGHTLY LEFT'**
  String get goalkeeperSwipeSlightLeft;

  /// No description provided for @goalkeeperSwipeRight.
  ///
  /// In en, this message translates to:
  /// **'DIVE RIGHT'**
  String get goalkeeperSwipeRight;

  /// No description provided for @goalkeeperSwipeSlightRight.
  ///
  /// In en, this message translates to:
  /// **'SLIGHTLY RIGHT'**
  String get goalkeeperSwipeSlightRight;

  /// No description provided for @goalkeeperSwipeCenter.
  ///
  /// In en, this message translates to:
  /// **'CENTER'**
  String get goalkeeperSwipeCenter;

  /// No description provided for @goalkeeperSwipeDived.
  ///
  /// In en, this message translates to:
  /// **'DIVED!'**
  String get goalkeeperSwipeDived;

  /// No description provided for @goalkeeperSwipeZoneLeft.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get goalkeeperSwipeZoneLeft;

  /// No description provided for @goalkeeperSwipeZoneCenter.
  ///
  /// In en, this message translates to:
  /// **'C'**
  String get goalkeeperSwipeZoneCenter;

  /// No description provided for @goalkeeperSwipeZoneRight.
  ///
  /// In en, this message translates to:
  /// **'R'**
  String get goalkeeperSwipeZoneRight;

  /// No description provided for @rewindLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Limit reached'**
  String get rewindLimitTitle;

  /// No description provided for @rewindLimitDesc.
  ///
  /// In en, this message translates to:
  /// **'You have used all your allowed rewinds for this match.'**
  String get rewindLimitDesc;

  /// No description provided for @rewindLimitInfo.
  ///
  /// In en, this message translates to:
  /// **'Information:'**
  String get rewindLimitInfo;

  /// No description provided for @rewindLimitMax.
  ///
  /// In en, this message translates to:
  /// **'• Maximum {max} rewinds per match'**
  String rewindLimitMax(Object max);

  /// No description provided for @rewindLimitUsed.
  ///
  /// In en, this message translates to:
  /// **'• Used: {used}/{max}'**
  String rewindLimitUsed(Object max, Object used);

  /// No description provided for @rewindLimitTotal.
  ///
  /// In en, this message translates to:
  /// **'• Total rewinds: {total}'**
  String rewindLimitTotal(Object total);

  /// No description provided for @rewindLimitReset.
  ///
  /// In en, this message translates to:
  /// **'Your rewinds will reset for the next match!'**
  String get rewindLimitReset;

  /// No description provided for @rewindLimitUnderstood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get rewindLimitUnderstood;

  /// No description provided for @rewindLimitRefill.
  ///
  /// In en, this message translates to:
  /// **'Refill'**
  String get rewindLimitRefill;

  /// No description provided for @coinsNeededTitle.
  ///
  /// In en, this message translates to:
  /// **'Need Coins?'**
  String get coinsNeededTitle;

  /// No description provided for @coinsNeededDesc.
  ///
  /// In en, this message translates to:
  /// **'Watch an ad to earn {amount} coins!'**
  String coinsNeededDesc(Object amount);

  /// No description provided for @coinsEarnedSnack.
  ///
  /// In en, this message translates to:
  /// **'+{amount} coins earned!'**
  String coinsEarnedSnack(Object amount);

  /// No description provided for @adUnavailableSnack.
  ///
  /// In en, this message translates to:
  /// **'Ad not available'**
  String get adUnavailableSnack;

  /// No description provided for @coinSystemTitle.
  ///
  /// In en, this message translates to:
  /// **'Coin System'**
  String get coinSystemTitle;

  /// No description provided for @coinSystemDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage your virtual currency:'**
  String get coinSystemDesc;

  /// No description provided for @coinSystemBalance.
  ///
  /// In en, this message translates to:
  /// **'📊 Your balance'**
  String get coinSystemBalance;

  /// No description provided for @coinSystemRewindCost.
  ///
  /// In en, this message translates to:
  /// **'🔄 Rewind cost'**
  String get coinSystemRewindCost;

  /// No description provided for @coinSystemAdReward.
  ///
  /// In en, this message translates to:
  /// **'🎥 Ad reward'**
  String get coinSystemAdReward;

  /// No description provided for @freeAdButton.
  ///
  /// In en, this message translates to:
  /// **'Free Ad'**
  String get freeAdButton;

  /// No description provided for @buyCoinsButton.
  ///
  /// In en, this message translates to:
  /// **'Buy Coins'**
  String get buyCoinsButton;

  /// No description provided for @buyRewindButton.
  ///
  /// In en, this message translates to:
  /// **'Buy Replay'**
  String get buyRewindButton;

  /// No description provided for @swipeShotHint.
  ///
  /// In en, this message translates to:
  /// **'SWIPE UP'**
  String get swipeShotHint;

  /// No description provided for @swipeShotEffectNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get swipeShotEffectNormal;

  /// No description provided for @swipeShotEffectCurve.
  ///
  /// In en, this message translates to:
  /// **'Curve'**
  String get swipeShotEffectCurve;

  /// No description provided for @swipeShotEffectLob.
  ///
  /// In en, this message translates to:
  /// **'Lob'**
  String get swipeShotEffectLob;

  /// No description provided for @swipeShotEffectKnuckle.
  ///
  /// In en, this message translates to:
  /// **'Knuckle'**
  String get swipeShotEffectKnuckle;

  /// No description provided for @teamFrance.
  ///
  /// In en, this message translates to:
  /// **'France'**
  String get teamFrance;

  /// No description provided for @teamGermany.
  ///
  /// In en, this message translates to:
  /// **'Germany'**
  String get teamGermany;

  /// No description provided for @teamSpain.
  ///
  /// In en, this message translates to:
  /// **'Spain'**
  String get teamSpain;

  /// No description provided for @teamItaly.
  ///
  /// In en, this message translates to:
  /// **'Italy'**
  String get teamItaly;

  /// No description provided for @teamRussia.
  ///
  /// In en, this message translates to:
  /// **'Russia'**
  String get teamRussia;

  /// No description provided for @teamEngland.
  ///
  /// In en, this message translates to:
  /// **'England'**
  String get teamEngland;

  /// No description provided for @teamPortugal.
  ///
  /// In en, this message translates to:
  /// **'Portugal'**
  String get teamPortugal;

  /// No description provided for @teamBelgium.
  ///
  /// In en, this message translates to:
  /// **'Belgium'**
  String get teamBelgium;

  /// No description provided for @teamArgentina.
  ///
  /// In en, this message translates to:
  /// **'Argentina'**
  String get teamArgentina;

  /// No description provided for @teamBrazil.
  ///
  /// In en, this message translates to:
  /// **'Brazil'**
  String get teamBrazil;

  /// No description provided for @teamUSA.
  ///
  /// In en, this message translates to:
  /// **'USA'**
  String get teamUSA;

  /// No description provided for @teamCanada.
  ///
  /// In en, this message translates to:
  /// **'Canada'**
  String get teamCanada;

  /// No description provided for @teamBenin.
  ///
  /// In en, this message translates to:
  /// **'Benin'**
  String get teamBenin;

  /// No description provided for @teamNigeria.
  ///
  /// In en, this message translates to:
  /// **'Nigeria'**
  String get teamNigeria;

  /// No description provided for @teamTogo.
  ///
  /// In en, this message translates to:
  /// **'Togo'**
  String get teamTogo;

  /// No description provided for @teamNiger.
  ///
  /// In en, this message translates to:
  /// **'Niger'**
  String get teamNiger;

  /// No description provided for @teamGhana.
  ///
  /// In en, this message translates to:
  /// **'Ghana'**
  String get teamGhana;

  /// No description provided for @teamIvoryCoast.
  ///
  /// In en, this message translates to:
  /// **'Ivory Coast'**
  String get teamIvoryCoast;

  /// No description provided for @teamJapan.
  ///
  /// In en, this message translates to:
  /// **'Japan'**
  String get teamJapan;

  /// No description provided for @teamSouthKorea.
  ///
  /// In en, this message translates to:
  /// **'South Korea'**
  String get teamSouthKorea;

  /// No description provided for @teamChina.
  ///
  /// In en, this message translates to:
  /// **'China'**
  String get teamChina;

  /// No description provided for @teamSaudiArabia.
  ///
  /// In en, this message translates to:
  /// **'Saudi Arabia'**
  String get teamSaudiArabia;

  /// No description provided for @teamAustralia.
  ///
  /// In en, this message translates to:
  /// **'Australia'**
  String get teamAustralia;

  /// No description provided for @continentEurope.
  ///
  /// In en, this message translates to:
  /// **'Europe'**
  String get continentEurope;

  /// No description provided for @continentAmerica.
  ///
  /// In en, this message translates to:
  /// **'America'**
  String get continentAmerica;

  /// No description provided for @continentAfrica.
  ///
  /// In en, this message translates to:
  /// **'Africa'**
  String get continentAfrica;

  /// No description provided for @continentAsia.
  ///
  /// In en, this message translates to:
  /// **'Asia'**
  String get continentAsia;

  /// No description provided for @continentOceania.
  ///
  /// In en, this message translates to:
  /// **'Oceania'**
  String get continentOceania;

  /// No description provided for @tutorialGameSoloTitle1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the pitch!'**
  String get tutorialGameSoloTitle1;

  /// No description provided for @tutorialGameSoloDesc1.
  ///
  /// In en, this message translates to:
  /// **'Swipe from the ball upward to shoot! Speed = power.'**
  String get tutorialGameSoloDesc1;

  /// No description provided for @tutorialGameSoloSwipeLabel.
  ///
  /// In en, this message translates to:
  /// **'Swipe to score!'**
  String get tutorialGameSoloSwipeLabel;

  /// No description provided for @tutorialGameSoloTitle2.
  ///
  /// In en, this message translates to:
  /// **'Rewind & Reward ↩️'**
  String get tutorialGameSoloTitle2;

  /// No description provided for @tutorialGameSoloDesc2.
  ///
  /// In en, this message translates to:
  /// **'If you miss a shot, use a **Rewind** to go back.'**
  String get tutorialGameSoloDesc2;

  /// No description provided for @tutorialGameSoloTip2a.
  ///
  /// In en, this message translates to:
  /// **'Earn more by watching an ad.'**
  String get tutorialGameSoloTip2a;

  /// No description provided for @tutorialGameSoloTip2b.
  ///
  /// In en, this message translates to:
  /// **'Use it wisely.'**
  String get tutorialGameSoloTip2b;

  /// No description provided for @tutorialGameSoloTitle3.
  ///
  /// In en, this message translates to:
  /// **'The scoreboard'**
  String get tutorialGameSoloTitle3;

  /// No description provided for @tutorialGameSoloDesc3.
  ///
  /// In en, this message translates to:
  /// **'Track both teams\' scores here.'**
  String get tutorialGameSoloDesc3;

  /// No description provided for @tutorialGameSoloTitle4.
  ///
  /// In en, this message translates to:
  /// **'Choose your effect'**
  String get tutorialGameSoloTitle4;

  /// No description provided for @tutorialGameSoloDesc4.
  ///
  /// In en, this message translates to:
  /// **'Normal, Curve, Lob or Knuckle — select before shooting.'**
  String get tutorialGameSoloDesc4;

  /// No description provided for @tutorialGameSoloEffectNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal: classic shot'**
  String get tutorialGameSoloEffectNormal;

  /// No description provided for @tutorialGameSoloEffectCurve.
  ///
  /// In en, this message translates to:
  /// **'Curve: curved trajectory'**
  String get tutorialGameSoloEffectCurve;

  /// No description provided for @tutorialGameSoloEffectLob.
  ///
  /// In en, this message translates to:
  /// **'Lob: over the goalkeeper'**
  String get tutorialGameSoloEffectLob;

  /// No description provided for @tutorialGameSoloEffectKnuckle.
  ///
  /// In en, this message translates to:
  /// **'Knuckle: unpredictable trajectory'**
  String get tutorialGameSoloEffectKnuckle;

  /// No description provided for @tutorialGameMultiTitle1.
  ///
  /// In en, this message translates to:
  /// **'Multiplayer Mode!'**
  String get tutorialGameMultiTitle1;

  /// No description provided for @tutorialGameMultiDesc1.
  ///
  /// In en, this message translates to:
  /// **'You\'re playing against a friend! Take turns.'**
  String get tutorialGameMultiDesc1;

  /// No description provided for @tutorialGameMultiTitle2.
  ///
  /// In en, this message translates to:
  /// **'Swipe to shoot'**
  String get tutorialGameMultiTitle2;

  /// No description provided for @tutorialGameMultiDesc2.
  ///
  /// In en, this message translates to:
  /// **'Swipe from the ball upward — direction and speed matter!'**
  String get tutorialGameMultiDesc2;

  /// No description provided for @tutorialGameMultiTitle3.
  ///
  /// In en, this message translates to:
  /// **'Rewind ↩️'**
  String get tutorialGameMultiTitle3;

  /// No description provided for @tutorialGameMultiDesc3.
  ///
  /// In en, this message translates to:
  /// **'Use a **Rewind** to cancel a missed shot.'**
  String get tutorialGameMultiDesc3;

  /// No description provided for @challengeWinTitle.
  ///
  /// In en, this message translates to:
  /// **'Win the match'**
  String get challengeWinTitle;

  /// No description provided for @challengeWinDesc.
  ///
  /// In en, this message translates to:
  /// **'Win the penalty shootout.'**
  String get challengeWinDesc;

  /// No description provided for @challengeKnuckleTitle.
  ///
  /// In en, this message translates to:
  /// **'Score a Knuckle goal'**
  String get challengeKnuckleTitle;

  /// No description provided for @challengeKnuckleDesc.
  ///
  /// In en, this message translates to:
  /// **'Score at least 1 goal with the Knuckle effect.'**
  String get challengeKnuckleDesc;

  /// No description provided for @challengePowerTitle.
  ///
  /// In en, this message translates to:
  /// **'All goals with power > 80'**
  String get challengePowerTitle;

  /// No description provided for @challengePowerDesc.
  ///
  /// In en, this message translates to:
  /// **'Every goal scored must be shot with power above 80.'**
  String get challengePowerDesc;

  /// No description provided for @challengeConcedeLessTitle.
  ///
  /// In en, this message translates to:
  /// **'Concede max 2 goals'**
  String get challengeConcedeLessTitle;

  /// No description provided for @challengeConcedeLessDesc.
  ///
  /// In en, this message translates to:
  /// **'Do not let the opponent score more than 2 goals.'**
  String get challengeConcedeLessDesc;

  /// No description provided for @challengeAllLobTitle.
  ///
  /// In en, this message translates to:
  /// **'All goals in Lob'**
  String get challengeAllLobTitle;

  /// No description provided for @challengeAllLobDesc.
  ///
  /// In en, this message translates to:
  /// **'Every goal scored must be shot with the Lob effect.'**
  String get challengeAllLobDesc;

  /// No description provided for @challengeCurveTitle.
  ///
  /// In en, this message translates to:
  /// **'Score 2 Curve goals'**
  String get challengeCurveTitle;

  /// No description provided for @challengeCurveDesc.
  ///
  /// In en, this message translates to:
  /// **'Score at least 2 goals with the Curve effect.'**
  String get challengeCurveDesc;

  /// No description provided for @challengeLobTitle.
  ///
  /// In en, this message translates to:
  /// **'Score 3 Lob goals'**
  String get challengeLobTitle;

  /// No description provided for @challengeLobDesc.
  ///
  /// In en, this message translates to:
  /// **'Score at least 3 goals with the Lob effect.'**
  String get challengeLobDesc;

  /// No description provided for @challengeSaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Make at least 1 save'**
  String get challengeSaveTitle;

  /// No description provided for @challengeSaveDesc.
  ///
  /// In en, this message translates to:
  /// **'Your goalkeeper must stop at least one opponent shot.'**
  String get challengeSaveDesc;

  /// No description provided for @heroResultStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'MATCH STATS'**
  String get heroResultStatsTitle;

  /// No description provided for @heroResultStatShots.
  ///
  /// In en, this message translates to:
  /// **'Shots attempted'**
  String get heroResultStatShots;

  /// No description provided for @heroResultStatGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals scored'**
  String get heroResultStatGoals;

  /// No description provided for @heroResultStatSaves.
  ///
  /// In en, this message translates to:
  /// **'Saves made'**
  String get heroResultStatSaves;

  /// No description provided for @heroResultStatConceded.
  ///
  /// In en, this message translates to:
  /// **'Goals conceded'**
  String get heroResultStatConceded;

  /// No description provided for @heroResultStatGoalsEffect.
  ///
  /// In en, this message translates to:
  /// **'{effect} goals'**
  String heroResultStatGoalsEffect(String effect);

  /// No description provided for @heroResultReplay.
  ///
  /// In en, this message translates to:
  /// **'REPLAY'**
  String get heroResultReplay;

  /// No description provided for @shotEffectNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get shotEffectNormal;

  /// No description provided for @shotEffectCurve.
  ///
  /// In en, this message translates to:
  /// **'Curve'**
  String get shotEffectCurve;

  /// No description provided for @shotEffectLob.
  ///
  /// In en, this message translates to:
  /// **'Lob'**
  String get shotEffectLob;

  /// No description provided for @shotEffectKnuckle.
  ///
  /// In en, this message translates to:
  /// **'Knuckle'**
  String get shotEffectKnuckle;

  /// No description provided for @achievementTournament1Title.
  ///
  /// In en, this message translates to:
  /// **'First Trophy'**
  String get achievementTournament1Title;

  /// No description provided for @achievementTournament1Desc.
  ///
  /// In en, this message translates to:
  /// **'Win your first championship'**
  String get achievementTournament1Desc;

  /// No description provided for @achievementTournament5Title.
  ///
  /// In en, this message translates to:
  /// **'Cup Collector'**
  String get achievementTournament5Title;

  /// No description provided for @achievementTournament5Desc.
  ///
  /// In en, this message translates to:
  /// **'Win 5 championships'**
  String get achievementTournament5Desc;

  /// No description provided for @achievementTournament10Title.
  ///
  /// In en, this message translates to:
  /// **'Championship Emperor'**
  String get achievementTournament10Title;

  /// No description provided for @achievementTournament10Desc.
  ///
  /// In en, this message translates to:
  /// **'Win 10 championships'**
  String get achievementTournament10Desc;

  /// No description provided for @achievementHeroLevel5Title.
  ///
  /// In en, this message translates to:
  /// **'Hero in the Making'**
  String get achievementHeroLevel5Title;

  /// No description provided for @achievementHeroLevel5Desc.
  ///
  /// In en, this message translates to:
  /// **'Reach level 5 in Hero mode'**
  String get achievementHeroLevel5Desc;

  /// No description provided for @achievementHeroLevel10Title.
  ///
  /// In en, this message translates to:
  /// **'Confirmed Hero'**
  String get achievementHeroLevel10Title;

  /// No description provided for @achievementHeroLevel10Desc.
  ///
  /// In en, this message translates to:
  /// **'Reach level 10 in Hero mode'**
  String get achievementHeroLevel10Desc;

  /// No description provided for @achievementHero3stars4Title.
  ///
  /// In en, this message translates to:
  /// **'Perfectionist'**
  String get achievementHero3stars4Title;

  /// No description provided for @achievementHero3stars4Desc.
  ///
  /// In en, this message translates to:
  /// **'Get 3 stars on 4 different Hero mode levels'**
  String get achievementHero3stars4Desc;

  /// No description provided for @achievementHero3stars10Title.
  ///
  /// In en, this message translates to:
  /// **'Super Perfectionist'**
  String get achievementHero3stars10Title;

  /// No description provided for @achievementHero3stars10Desc.
  ///
  /// In en, this message translates to:
  /// **'Get 3 stars on 10 different Hero mode levels'**
  String get achievementHero3stars10Desc;

  /// No description provided for @achievementHeroAllStarsTitle.
  ///
  /// In en, this message translates to:
  /// **'Hero Legend'**
  String get achievementHeroAllStarsTitle;

  /// No description provided for @achievementHeroAllStarsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get all stars on every Hero mode level'**
  String get achievementHeroAllStarsDesc;

  /// No description provided for @rarityCommon.
  ///
  /// In en, this message translates to:
  /// **'COMMON'**
  String get rarityCommon;

  /// No description provided for @rarityRare.
  ///
  /// In en, this message translates to:
  /// **'RARE'**
  String get rarityRare;

  /// No description provided for @rarityEpic.
  ///
  /// In en, this message translates to:
  /// **'EPIC'**
  String get rarityEpic;

  /// No description provided for @rarityLegendary.
  ///
  /// In en, this message translates to:
  /// **'LEGENDARY'**
  String get rarityLegendary;
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

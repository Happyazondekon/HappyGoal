import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  String get appTitle;
  String get welcomeMessage;
  String get chooseCountry;
  String get startAdventure;
  String get swipeUp;
  String get shots;
  String get goal;
  String get miss;
  String get team;
  String get settings;
  String get language;
  String get french;
  String get english;
  String get shop;
  String get shopDescription;
  String get dailyGift;
  String get dailyGiftDescription;
  String get achievements;
  String get achievementsDescription;
  String get subtitle;
  String get invite;
  String get rules;
  String get playButton;
  String get splashTitle;
  String get splashSubtitle;
  String get splashLoading;
  String get splashRequiredUpdateTitle;
  String get splashRequiredUpdateContent;
  String get splashRequiredUpdateButton;
  String get modeSelectionTitle;
  String get modeSelectionSubtitle;
  String get modeHeroTitle;
  String get modeHeroSubtitle;
  String get modeMultiplayerTitle;
  String get modeMultiplayerSubtitle;
  String get modeTournamentTitle;
  String get modeTournamentSubtitle;
  String get modeBack;
  String get heroModeTitle;
  String get heroModeEnd;
  String get heroModeStart;
  String get heroModeResetTitle;
  String get heroModeResetContent;
  String get heroModeResetCancel;
  String get heroModeResetConfirm;
  String heroModeRewardTitle(Object level);
  String heroModeRewardDescription(Object coins);
  String heroModeRewardAdded(Object coins);
  String get heroModeRewardAdUnavailable;
  String get heroTeamSelectHeader1;
  String get heroTeamSelectHeader2;
  String get heroTeamSelectSubtitle;
  String get heroTeamSelectStart;
  String heroTransitionChapter(Object level);
  String get heroTransitionVS;
  String get heroTransitionYou;
  String get heroTransitionBestResult;
  String get heroTransitionStart;
  String heroTransitionStoryStart(Object myTeam, Object opponent);
  String heroTransitionStoryEnd(Object opponent);
  String heroTransitionStoryLevel(Object level, Object myTeam, Object opponent);
  String heroResultChapter(Object level);
  String get heroResultVictory;
  String get heroResultDefeat;
  String get heroResultVictorySubtitle;
  String get heroResultDefeatSubtitle;
  String get heroResultYou;
  String get heroResultOpponent;
  String heroResultLevel(Object level);
  String get heroResultObjectives;
  String get heroResultNextLevel;
  String get heroResultBack;
  String get teamSelectionTitle;
  String get teamSelectionModeSolo;
  String get teamSelectionModeMulti;
  String get teamSelectionModeTournament;
  String get teamSelectionChooseTeams;
  String get teamSelectionTeam1;
  String get teamSelectionTeam2;
  String get teamSelectionYourTeam;
  String get teamSelectionAITeam;
  String get teamSelectionToSelect;
  String get teamSelectionStart;
  String get teamSelectionSelectTwo;
  String get resultGreat;
  String get resultDefeat;
  String get resultVictory;
  String get resultDefeatSubtitle;
  String get resultVictorySubtitle;
  String get resultCoin;
  String get resultRematch;
  String get resultBackToMenu;
  String get resultChangeTeam;
  String get resultShots;
  String resultLastShots(Object count);
  String get tournamentStatsTitle;
  String tournamentStatsLast(Object date);
  String get tournamentStatsPlayed;
  String get tournamentStatsWon;
  String get tournamentStatsVictory;
  String get tournamentStatsRewinds;
  String get tournamentStatsGoals;
  String get tournamentStatsMatches;
  String get tournamentStatsReset;
  String get tournamentStatsResetTitle;
  String get tournamentStatsResetContent;
  String get tournamentStatsResetCancel;
  String get tournamentStatsResetConfirm;
  String get tournamentStatsResetSuccess;
  String get tournamentStatsClickToView;
  String get tournamentStatsMotivationStart;
  String get tournamentStatsMotivationChampion;
  String get tournamentStatsMotivationGood;
  String get tournamentStatsMotivationOpportunity;
  String get tournamentStatsMotivationPerseverance;
  String get tournamentHappyTitle;
  String get tournamentPathToGlory;
  String get tournamentPhaseRoundOf16;
  String get tournamentPhaseQuarterFinals;
  String get tournamentPhaseSemiFinals;
  String get tournamentPhaseFinal;
  String get tournamentYourTeam;
  String get tournamentReadyToFight;
  String get tournamentFourMatches;
  String get tournamentChooseTeam;
  String get tournamentChangeTeam;
  String get tournamentNotEnoughTeams;
  String get tournamentStart;
  String get tournamentResultChampion;
  String get tournamentResultGoodPerformance;
  String get tournamentResultDefeat;
  String get tournamentResultTournamentWon;
  String get tournamentResultEliminated;
  String get tournamentResultEndOfJourney;
  String get tournamentResultCoins;
  String get tournamentResultResultsTitle;
  String get tournamentResultChampionBadge;
  String get tournamentResultFighterBadge;
  String get tournamentResultEliminatedBadge;
  String get tournamentResultWins;
  String get tournamentResultLosses;
  String get tournamentResultTotal;
  String get tournamentResultBackHome;
  String get tournamentResultNewTournament;
  String get tournamentResultAchievementsUnlocked;
  String get tournamentResultSuccessGreat;
  String get tournamentResultSnackChampion;
  String get gameResultLob;
  String get gameResultCurve;
  String get gameResultKnuckle;
  String get gameResultSoft;
  String get gameResultGoal;
  String get gameResultWeakShot;
  String get gameResultSaved;
  String gameNextMatch(Object phase);
  String get gameMissedShot;
  String get gameSecondChance;
  String gameUseRewind(Object count);
  String get gameContinue;
  String get gameRewind;
  String get gameRewindSuccess;
  String get gameRewindFailed;
  String get gameRoundReset;
  String get gameGoalScored;
  String get gameGoalSaved;
  String get gameWhistle;
  String get gameSuddenDeath;
  String get gameAIShootingPrompt;
  String get gameAITurnWait;
  String get coinInfoTitle;
  String get coinInfoBalance;
  String get coinInfoAdReward;
  String get coinInfoShop;
  String coinInfoShopAdded(Object coins);
  String get coinInfoShopUnavailable;
  String get coinInfoShopGift;
  String coinInfoShopGiftDesc(Object coins);
  String get coinInfoShopPubFree;
  String get coinInfoShopUseCoins;
  String get settingsOptions;
  String get settingsClose;
  String get rulesTitle;
  String get rules1;
  String get rules2;
  String get rules3;
  String get rules4;
  String get rulesUnderstood;
  String get inviteShareText;
  String get inviteShareSubject;
  String get achievementsTitle;
  String achievementsUnlocked(Object total, Object unlocked);
  String get achievementsCategoryMatches;
  String get achievementsCategoryGoals;
  String get achievementsCategoryTournaments;
  String get achievementsCategorySpecial;
  String get achievementsCategorySkills;
  String get achievementsStatWins;
  String get achievementsProgressGlobal;
  String get achievementsNone;
  String get achievementsClaimed;
  String achievementsReward(Object coins);
  String achievementsSnackClaimed(Object coins);
  String achievementsProgress(Object current, Object target);
  String get achievementsRarityCommon;
  String get achievementsRarityRare;
  String get achievementsRarityEpic;
  String get achievementsRarityLegendary;
  String get achievementsBack;
  String achievementsCompletionPercent(Object percent);
  String achievementsProgressBar(Object percent);
  String get tutorialSettingsTitle;
  String get tutorialSettingsHeader;
  String get tutorialSettingsHeaderDesc;
  String get tutorialSettingsHome;
  String get tutorialSettingsModeSelection;
  String get tutorialSettingsTeamSelection;
  String get tutorialSettingsGameSolo;
  String get tutorialSettingsGameMulti;
  String get tutorialSettingsTournament;
  String get tutorialSettingsHomeDesc;
  String get tutorialSettingsModeSelectionDesc;
  String get tutorialSettingsTeamSelectionDesc;
  String get tutorialSettingsGameSoloDesc;
  String get tutorialSettingsGameMultiDesc;
  String get tutorialSettingsTournamentDesc;
  String get tutorialSettingsSeen;
  String get tutorialSettingsNew;
  String get tutorialSettingsWillShow;
  String get tutorialSettingsReactivate;
  String get tutorialSettingsResetAll;
  String get tutorialSettingsResetConfirmTitle;
  String get tutorialSettingsResetConfirmContent;
  String get tutorialSettingsResetCancel;
  String get tutorialSettingsResetConfirm;
  String get tutorialSettingsResetSuccess;
  String tutorialSettingsResetSingle(Object title);
  String get tutorialSettingsWidgetTitle;
  String get tutorialSettingsWidgetSubtitle;
  String get audioSettingsTitle;
  String get audioSettingsSound;
  String get audioSettingsMusic;
  String get audioSettingsBackground;
  String get audioSettingsBackgroundDesc;
  String get audioSettingsVolume;
  String get coinShopTitle;
  String get coinShopLoading;
  String get coinShopSuccessTitle;
  String coinShopSuccessCoins(Object coins);
  String get coinShopSuccessThanks;
  String get coinShopSuccessButton;
  String get coinShopClose;
  String get coinShopBestOffer;
  String get coinShopBonus10;
  String get coinShopPromo17;
  String get goalkeeperSwipeLabel;
  String get goalkeeperSwipeLeft;
  String get goalkeeperSwipeSlightLeft;
  String get goalkeeperSwipeRight;
  String get goalkeeperSwipeSlightRight;
  String get goalkeeperSwipeCenter;
  String get goalkeeperSwipeDived;
  String get goalkeeperSwipeZoneLeft;
  String get goalkeeperSwipeZoneCenter;
  String get goalkeeperSwipeZoneRight;
  String get rewindLimitTitle;
  String get rewindLimitDesc;
  String get rewindLimitInfo;
  String rewindLimitMax(Object max);
  String rewindLimitUsed(Object max, Object used);
  String rewindLimitTotal(Object total);
  String get rewindLimitReset;
  String get rewindLimitUnderstood;
  String get rewindLimitRefill;
  String get coinsNeededTitle;
  String coinsNeededDesc(Object amount);
  String coinsEarnedSnack(Object amount);
  String get adUnavailableSnack;
  String get coinSystemTitle;
  String get coinSystemDesc;
  String get coinSystemBalance;
  String get coinSystemRewindCost;
  String get coinSystemAdReward;
  String get freeAdButton;
  String get buyCoinsButton;
  String get buyRewindButton;
  String get swipeShotHint;
  String get swipeShotEffectNormal;
  String get swipeShotEffectCurve;
  String get swipeShotEffectLob;
  String get swipeShotEffectKnuckle;

  // ── Tutorial game screen ──────────────────────────────────────────────────
  String get tutorialGameSoloTitle1;
  String get tutorialGameSoloDesc1;
  String get tutorialGameSoloSwipeLabel;
  String get tutorialGameSoloTitle2;
  String get tutorialGameSoloDesc2;
  String get tutorialGameSoloTip2a;
  String get tutorialGameSoloTip2b;
  String get tutorialGameSoloTitle3;
  String get tutorialGameSoloDesc3;
  String get tutorialGameSoloTitle4;
  String get tutorialGameSoloDesc4;
  String get tutorialGameSoloEffectNormal;
  String get tutorialGameSoloEffectCurve;
  String get tutorialGameSoloEffectLob;
  String get tutorialGameSoloEffectKnuckle;
  String get tutorialGameMultiTitle1;
  String get tutorialGameMultiDesc1;
  String get tutorialGameMultiTitle2;
  String get tutorialGameMultiDesc2;
  String get tutorialGameMultiTitle3;
  String get tutorialGameMultiDesc3;
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
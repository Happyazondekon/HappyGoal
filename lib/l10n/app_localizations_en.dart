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

  @override
  String get tournamentStatsTitle => 'TOURNAMENT STATISTICS';

  @override
  String tournamentStatsLast(Object date) {
    return 'Last: $date';
  }

  @override
  String get tournamentStatsPlayed => 'Played';

  @override
  String get tournamentStatsWon => 'Won';

  @override
  String get tournamentStatsVictory => 'Victory';

  @override
  String get tournamentStatsRewinds => 'Rewinds';

  @override
  String get tournamentStatsGoals => 'Goals';

  @override
  String get tournamentStatsMatches => 'Matches';

  @override
  String get tournamentStatsReset => 'Reset';

  @override
  String get tournamentStatsResetTitle => 'Reset statistics';

  @override
  String get tournamentStatsResetContent => 'Are you sure you want to reset all your tournament statistics? This action is irreversible.';

  @override
  String get tournamentStatsResetCancel => 'Cancel';

  @override
  String get tournamentStatsResetConfirm => 'Reset';

  @override
  String get tournamentStatsResetSuccess => 'Statistics successfully reset';

  @override
  String get tournamentStatsClickToView => 'Click to view your performance';

  @override
  String get tournamentStatsMotivationStart => 'Start your first tournament! 🚀';

  @override
  String get tournamentStatsMotivationChampion => 'Excellent win rate! You are a champion! 🏆';

  @override
  String get tournamentStatsMotivationGood => 'Good win rate! Keep it up! 💪';

  @override
  String get tournamentStatsMotivationOpportunity => 'Every tournament is a new opportunity! 🔥';

  @override
  String get tournamentStatsMotivationPerseverance => 'Perseverance is the key to success! Never give up! ⚽';

  @override
  String get tournamentHappyTitle => 'HAPPY TOURNAMENT';

  @override
  String get tournamentPathToGlory => 'Path to glory';

  @override
  String get tournamentPhaseRoundOf16 => 'ROUND OF 16';

  @override
  String get tournamentPhaseQuarterFinals => 'QUARTER FINALS';

  @override
  String get tournamentPhaseSemiFinals => 'SEMI-FINALS';

  @override
  String get tournamentPhaseFinal => 'GRAND FINAL';

  @override
  String get tournamentYourTeam => 'YOUR TEAM';

  @override
  String get tournamentReadyToFight => 'READY TO FIGHT';

  @override
  String get tournamentFourMatches => '⚡ 4 MATCHES FOR VICTORY ⚡';

  @override
  String get tournamentChooseTeam => 'CHOOSE YOUR TEAM';

  @override
  String get tournamentChangeTeam => 'CHANGE TEAM';

  @override
  String get tournamentNotEnoughTeams => 'Not enough teams for a full tournament';

  @override
  String get tournamentStart => 'START TOURNAMENT';

  @override
  String get tournamentResultChampion => 'CHAMPION!';

  @override
  String get tournamentResultGoodPerformance => 'GOOD PERFORMANCE!';

  @override
  String get tournamentResultDefeat => 'DEFEAT';

  @override
  String get tournamentResultTournamentWon => 'TOURNAMENT WON';

  @override
  String get tournamentResultEliminated => 'ELIMINATED';

  @override
  String get tournamentResultEndOfJourney => 'END OF JOURNEY';

  @override
  String get tournamentResultCoins => '+25 COINS';

  @override
  String get tournamentResultResultsTitle => 'TOURNAMENT RESULTS';

  @override
  String get tournamentResultChampionBadge => '🏆 CHAMPION';

  @override
  String get tournamentResultFighterBadge => '⚔️ FIGHTER';

  @override
  String get tournamentResultEliminatedBadge => '💔 ELIMINATED';

  @override
  String get tournamentResultWins => 'WINS';

  @override
  String get tournamentResultLosses => 'LOSSES';

  @override
  String get tournamentResultTotal => 'TOTAL';

  @override
  String get tournamentResultBackHome => 'BACK TO HOME';

  @override
  String get tournamentResultNewTournament => 'NEW TOURNAMENT';

  @override
  String get tournamentResultAchievementsUnlocked => 'Achievements Unlocked!';

  @override
  String get tournamentResultSuccessGreat => 'GREAT!';

  @override
  String get tournamentResultSnackChampion => 'CHAMPION! +25 COINS WON!';

  @override
  String get gameResultLob => 'GOAL on LOB 🎯';

  @override
  String get gameResultCurve => 'GOAL with CURVE 🔥';

  @override
  String get gameResultKnuckle => 'KNUCKLE GOAL ⚡';

  @override
  String get gameResultSoft => 'SOFT GOAL 💨';

  @override
  String get gameResultGoal => 'GOOOAL!';

  @override
  String get gameResultWeakShot => 'SHOT TOO WEAK 😢';

  @override
  String get gameResultSaved => 'GOALKEEPER SAVE!';

  @override
  String gameNextMatch(Object phase) {
    return 'Next match: $phase';
  }

  @override
  String get gameMissedShot => 'MISSED SHOT!';

  @override
  String get gameSecondChance => 'Second chance available';

  @override
  String gameUseRewind(Object count) {
    return 'Use a rewind?\n(Remaining: $count)';
  }

  @override
  String get gameContinue => 'Continue';

  @override
  String get gameRewind => 'Rewind';

  @override
  String get gameRewindSuccess => 'Shot rewound!';

  @override
  String get gameRewindFailed => 'Rewind failed!';

  @override
  String get gameRoundReset => 'Round reset!';

  @override
  String get gameGoalScored => 'Goal scored!';

  @override
  String get gameGoalSaved => 'Goal saved!';

  @override
  String get gameWhistle => 'Whistle!';

  @override
  String get coinInfoTitle => 'Treasury';

  @override
  String get coinInfoBalance => 'Your Balance';

  @override
  String get coinInfoAdReward => 'Ad Reward';

  @override
  String get coinInfoShop => 'SHOP';

  @override
  String coinInfoShopAdded(Object coins) {
    return '+$coins coins added!';
  }

  @override
  String get coinInfoShopUnavailable => 'Ad unavailable.';

  @override
  String get coinInfoShopGift => 'Daily Gift';

  @override
  String coinInfoShopGiftDesc(Object coins) {
    return 'Watch a video to earn $coins coins!';
  }

  @override
  String get coinInfoShopPubFree => 'Free Ad';

  @override
  String get coinInfoShopUseCoins => 'Use your coins to buy rewinds!';

  @override
  String get settingsOptions => 'Options';

  @override
  String get settingsClose => 'Close';

  @override
  String get rulesTitle => 'Game Rules';

  @override
  String get rules1 => '1. Choose a direction to shoot.';

  @override
  String get rules2 => '2. The goalkeeper dives randomly.';

  @override
  String get rules3 => '3. Score 5 goals to win!';

  @override
  String get rules4 => '4. Use rewinds if you miss.';

  @override
  String get rulesUnderstood => 'Got it!';

  @override
  String get inviteShareText => 'HappyGoal! ⚽\n\nCome take penalties and challenge me!\nDownload: https://play.google.com/store/apps/details?id=com.heyhappy.happygoal';

  @override
  String get inviteShareSubject => 'HappyGoal';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String achievementsUnlocked(Object total, Object unlocked) {
    return '$unlocked / $total unlocked';
  }

  @override
  String get achievementsCategoryMatches => 'Matches';

  @override
  String get achievementsCategoryGoals => 'Goals';

  @override
  String get achievementsCategoryTournaments => 'Tournaments';

  @override
  String get achievementsCategorySpecial => 'Special';

  @override
  String get achievementsCategorySkills => 'Skills';

  @override
  String get achievementsStatWins => 'Wins';

  @override
  String get achievementsProgressGlobal => 'Global Progress';

  @override
  String get achievementsNone => 'No achievements in this category';

  @override
  String get achievementsClaimed => 'Claimed';

  @override
  String achievementsReward(Object coins) {
    return '+$coins coins';
  }

  @override
  String achievementsSnackClaimed(Object coins) {
    return '+$coins coins claimed!';
  }

  @override
  String achievementsProgress(Object current, Object target) {
    return '$current/$target';
  }

  @override
  String get achievementsRarityCommon => 'Common';

  @override
  String get achievementsRarityRare => 'Rare';

  @override
  String get achievementsRarityEpic => 'Epic';

  @override
  String get achievementsRarityLegendary => 'Legendary';

  @override
  String get achievementsBack => 'Back';

  @override
  String achievementsCompletionPercent(Object percent) {
    return '$percent%';
  }

  @override
  String achievementsProgressBar(Object percent) {
    return '$percent%';
  }

  @override
  String get tutorialSettingsTitle => 'Tutorials';

  @override
  String get tutorialSettingsHeader => 'Tutorial management';

  @override
  String get tutorialSettingsHeaderDesc => 'Manage tutorial display for each screen. Tutorials marked as \'Seen\' will no longer show automatically.';

  @override
  String get tutorialSettingsHome => 'Home screen';

  @override
  String get tutorialSettingsModeSelection => 'Mode selection';

  @override
  String get tutorialSettingsTeamSelection => 'Team selection';

  @override
  String get tutorialSettingsGameSolo => 'Solo game';

  @override
  String get tutorialSettingsGameMulti => 'Multiplayer game';

  @override
  String get tutorialSettingsTournament => 'Tournament mode';

  @override
  String get tutorialSettingsHomeDesc => 'Guide to main features';

  @override
  String get tutorialSettingsModeSelectionDesc => 'Explanation of game modes';

  @override
  String get tutorialSettingsTeamSelectionDesc => 'How to choose your teams';

  @override
  String get tutorialSettingsGameSoloDesc => 'Gameplay against AI';

  @override
  String get tutorialSettingsGameMultiDesc => 'Two-player game';

  @override
  String get tutorialSettingsTournamentDesc => 'Tournament navigation';

  @override
  String get tutorialSettingsSeen => 'Seen';

  @override
  String get tutorialSettingsNew => 'New';

  @override
  String get tutorialSettingsWillShow => 'Will show automatically';

  @override
  String get tutorialSettingsReactivate => 'Reactivate';

  @override
  String get tutorialSettingsResetAll => 'Reset all tutorials';

  @override
  String get tutorialSettingsResetConfirmTitle => 'Confirm reset';

  @override
  String get tutorialSettingsResetConfirmContent => 'Are you sure you want to reset all tutorials? They will show again on your next visits.';

  @override
  String get tutorialSettingsResetCancel => 'Cancel';

  @override
  String get tutorialSettingsResetConfirm => 'Confirm';

  @override
  String get tutorialSettingsResetSuccess => 'All tutorials have been reset';

  @override
  String tutorialSettingsResetSingle(Object title) {
    return 'Tutorial \'$title\' reset';
  }

  @override
  String get tutorialSettingsWidgetTitle => 'Tutorials';

  @override
  String get tutorialSettingsWidgetSubtitle => 'Manage guide display';

  @override
  String get audioSettingsTitle => 'Audio Settings';

  @override
  String get audioSettingsSound => 'Sound effects';

  @override
  String get audioSettingsMusic => 'Background music';

  @override
  String get audioSettingsBackground => 'Continue music in background';

  @override
  String get audioSettingsBackgroundDesc => 'Music continues when you leave the app';

  @override
  String get audioSettingsVolume => 'Volume';

  @override
  String get coinShopTitle => 'Shop';

  @override
  String get coinShopLoading => 'Connecting to store\n(Loading...)';

  @override
  String get coinShopSuccessTitle => 'Payment Successful!';

  @override
  String coinShopSuccessCoins(Object coins) {
    return '+$coins Coins added';
  }

  @override
  String get coinShopSuccessThanks => 'Thank you for your support!';

  @override
  String get coinShopSuccessButton => 'AWESOME!';

  @override
  String get coinShopClose => 'Close';

  @override
  String get coinShopBestOffer => 'BEST OFFER';

  @override
  String get coinShopBonus10 => '+10% BONUS';

  @override
  String get coinShopPromo17 => '+17% PROMO';

  @override
  String get goalkeeperSwipeLabel => 'SLIDE THE GOALKEEPER';

  @override
  String get goalkeeperSwipeLeft => 'DIVE LEFT';

  @override
  String get goalkeeperSwipeSlightLeft => 'SLIGHTLY LEFT';

  @override
  String get goalkeeperSwipeRight => 'DIVE RIGHT';

  @override
  String get goalkeeperSwipeSlightRight => 'SLIGHTLY RIGHT';

  @override
  String get goalkeeperSwipeCenter => 'CENTER';

  @override
  String get goalkeeperSwipeDived => 'DIVED!';

  @override
  String get goalkeeperSwipeZoneLeft => 'L';

  @override
  String get goalkeeperSwipeZoneCenter => 'C';

  @override
  String get goalkeeperSwipeZoneRight => 'R';

  @override
  String get rewindLimitTitle => 'Limit reached';

  @override
  String get rewindLimitDesc => 'You have used all your allowed rewinds for this match.';

  @override
  String get rewindLimitInfo => 'Information:';

  @override
  String rewindLimitMax(Object max) {
    return '• Maximum $max rewinds per match';
  }

  @override
  String rewindLimitUsed(Object max, Object used) {
    return '• Used: $used/$max';
  }

  @override
  String rewindLimitTotal(Object total) {
    return '• Total rewinds: $total';
  }

  @override
  String get rewindLimitReset => 'Your rewinds will reset for the next match!';

  @override
  String get rewindLimitUnderstood => 'Understood';

  @override
  String get rewindLimitRefill => 'Refill';

  @override
  String get coinsNeededTitle => 'Need Coins?';

  @override
  String coinsNeededDesc(Object amount) {
    return 'Watch an ad to earn $amount coins!';
  }

  @override
  String coinsEarnedSnack(Object amount) {
    return '+$amount coins earned!';
  }

  @override
  String get adUnavailableSnack => 'Ad not available';

  @override
  String get coinSystemTitle => 'Coin System';

  @override
  String get coinSystemDesc => 'Manage your virtual currency:';

  @override
  String get coinSystemBalance => '📊 Your balance';

  @override
  String get coinSystemRewindCost => '🔄 Rewind cost';

  @override
  String get coinSystemAdReward => '🎥 Ad reward';

  @override
  String get freeAdButton => 'Free Ad';

  @override
  String get buyCoinsButton => 'Buy Coins';

  @override
  String get buyRewindButton => 'Buy Replay';

  @override
  String get swipeShotHint => 'SWIPE UP';

  @override
  String get swipeShotEffectNormal => 'Normal';

  @override
  String get swipeShotEffectCurve => 'Curve';

  @override
  String get swipeShotEffectLob => 'Lob';

  @override
  String get swipeShotEffectKnuckle => 'Knuckle';
}

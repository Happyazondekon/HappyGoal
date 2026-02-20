// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'HappyGoal';

  @override
  String get welcomeMessage => 'Bienvenue sur HappyGoal !';

  @override
  String get chooseCountry => 'Choisissez le pays que vous représenterez dans votre aventure Hero';

  @override
  String get startAdventure => 'Prêt pour une série de tirs au but ?';

  @override
  String get swipeUp => 'GLISSE VERS LE HAUT';

  @override
  String get shots => 'TIRS';

  @override
  String get goal => 'But !';

  @override
  String get miss => 'Raté !';

  @override
  String get team => 'Équipe';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get french => 'Français';

  @override
  String get english => 'Anglais';

  @override
  String get shop => 'Boutique';

  @override
  String get shopDescription => 'Vos coins sont ici. Touchez pour ouvrir la boutique !';

  @override
  String get dailyGift => 'Cadeau Quotidien';

  @override
  String get dailyGiftDescription => 'Récupérez vos coins gratuits ici !';

  @override
  String get achievements => 'SUCCÈS';

  @override
  String get achievementsDescription => 'Consultez vos achievements et récupérez vos récompenses !';

  @override
  String get subtitle => 'LE DÉFI DES TIRS AU BUT';

  @override
  String get invite => 'Inviter';

  @override
  String get rules => 'Règles';

  @override
  String get playButton => 'JOUER';

  @override
  String get splashTitle => 'HappyGoal';

  @override
  String get splashSubtitle => 'Le défi des tirs au but';

  @override
  String get splashLoading => 'Chargement...';

  @override
  String get splashRequiredUpdateTitle => 'Mise à jour requise';

  @override
  String get splashRequiredUpdateContent => 'Une nouvelle version de HappyGoal est disponible.\n\nCette mise à jour est obligatoire pour profiter des fonctionnalités en ligne et des tournois.\n\nVeuillez mettre à jour pour continuer.';

  @override
  String get splashRequiredUpdateButton => 'METTRE À JOUR MAINTENANT';

  @override
  String get modeSelectionTitle => 'Choisir un mode';

  @override
  String get modeSelectionSubtitle => 'Sélectionnez votre défi';

  @override
  String get modeHeroTitle => 'MODE HERO';

  @override
  String get modeHeroSubtitle => 'Progressez à travers 100 niveaux';

  @override
  String get modeMultiplayerTitle => 'MODE MULTIJOUEUR';

  @override
  String get modeMultiplayerSubtitle => 'Défiez un ami';

  @override
  String get modeTournamentTitle => 'MODE TOURNOI';

  @override
  String get modeTournamentSubtitle => 'Remportez le championnat';

  @override
  String get modeBack => 'Retour';

  @override
  String get heroModeTitle => 'HERO MODE';

  @override
  String get heroModeEnd => 'END';

  @override
  String get heroModeStart => 'START';

  @override
  String get heroModeResetTitle => 'Changer de pays ?';

  @override
  String get heroModeResetContent => 'Vous perdrez votre progression. Voulez-vous recommencer ?';

  @override
  String get heroModeResetCancel => 'Annuler';

  @override
  String get heroModeResetConfirm => 'Recommencer';

  @override
  String heroModeRewardTitle(Object level) {
    return 'Récompense niveau $level';
  }

  @override
  String heroModeRewardDescription(Object coins) {
    return 'Regardez une vidéo pour gagner $coins coins !';
  }

  @override
  String heroModeRewardAdded(Object coins) {
    return '+$coins coins ajoutés !';
  }

  @override
  String get heroModeRewardAdUnavailable => 'Publicité indisponible ou erreur de chargement.';

  @override
  String get heroTeamSelectHeader1 => 'CHOISISSEZ';

  @override
  String get heroTeamSelectHeader2 => 'VOTRE PAYS';

  @override
  String get heroTeamSelectSubtitle => 'Choisissez le pays que vous représenterez dans votre aventure Hero';

  @override
  String get heroTeamSelectStart => 'COMMENCER L\'AVENTURE';

  @override
  String heroTransitionChapter(Object level) {
    return 'CHAPITRE $level';
  }

  @override
  String get heroTransitionVS => 'VS';

  @override
  String get heroTransitionYou => 'VOUS';

  @override
  String get heroTransitionBestResult => 'VOTRE MEILLEUR RÉSULTAT';

  @override
  String get heroTransitionStart => 'COMMENCER LE MATCH';

  @override
  String heroTransitionStoryStart(Object myTeam, Object opponent) {
    return 'L\'aventure commence ! Tu représentes $myTeam et ton premier adversaire est $opponent. Montre ton talent !';
  }

  @override
  String heroTransitionStoryEnd(Object opponent) {
    return 'Le défi ultime ! Après un parcours légendaire, tu affrontes $opponent pour la gloire éternelle.';
  }

  @override
  String heroTransitionStoryLevel(Object level, Object myTeam, Object opponent) {
    return 'Niveau $level : $myTeam affronte $opponent dans un duel décisif. Prouve ta valeur !';
  }

  @override
  String heroResultChapter(Object level) {
    return 'CHAPITRE $level';
  }

  @override
  String get heroResultVictory => 'VICTOIRE !';

  @override
  String get heroResultDefeat => 'DÉFAITE';

  @override
  String get heroResultVictorySubtitle => 'Félicitations pour cette victoire !';

  @override
  String get heroResultDefeatSubtitle => 'L\'IA a remporté cette séance';

  @override
  String get heroResultYou => 'VOUS';

  @override
  String get heroResultOpponent => 'ADV.';

  @override
  String heroResultLevel(Object level) {
    return 'Niveau $level';
  }

  @override
  String get heroResultObjectives => 'OBJECTIFS';

  @override
  String get heroResultNextLevel => 'NIVEAU SUIVANT';

  @override
  String get heroResultBack => 'RETOUR';

  @override
  String get teamSelectionTitle => 'Sélection des équipes';

  @override
  String get teamSelectionModeSolo => 'Mode Solo';

  @override
  String get teamSelectionModeMulti => 'Mode Multijoueur';

  @override
  String get teamSelectionModeTournament => 'Mode Tournoi';

  @override
  String get teamSelectionChooseTeams => 'Choisissez votre équipe et l\'équipe adverse contrôlée par l\'ordinateur';

  @override
  String get teamSelectionTeam1 => 'Équipe 1';

  @override
  String get teamSelectionTeam2 => 'Équipe 2';

  @override
  String get teamSelectionYourTeam => 'Votre Équipe';

  @override
  String get teamSelectionAITeam => 'Équipe IA';

  @override
  String get teamSelectionToSelect => 'À sélectionner';

  @override
  String get teamSelectionStart => 'COMMENCER LE MATCH';

  @override
  String get teamSelectionSelectTwo => 'Veuillez sélectionner deux équipes';

  @override
  String get resultGreat => 'GÉNIAL !';

  @override
  String get resultDefeat => 'Défaite';

  @override
  String get resultVictory => 'Victoire !';

  @override
  String get resultDefeatSubtitle => 'L\'IA a remporté cette séance';

  @override
  String get resultVictorySubtitle => 'Félicitations pour cette victoire !';

  @override
  String get resultCoin => '+1 COIN GAGNÉ !';

  @override
  String get resultRematch => 'Revanche';

  @override
  String get resultBackToMenu => 'Retour au menu';

  @override
  String get resultChangeTeam => 'Changer d\'équipe';

  @override
  String get resultShots => 'Tirs';

  @override
  String resultLastShots(Object count) {
    return 'Derniers $count tirs';
  }

  @override
  String get tournamentStatsTitle => 'STATISTIQUES DU TOURNOI';

  @override
  String tournamentStatsLast(Object date) {
    return 'Dernier: $date';
  }

  @override
  String get tournamentStatsPlayed => 'Joués';

  @override
  String get tournamentStatsWon => 'Gagnés';

  @override
  String get tournamentStatsVictory => 'Victoire';

  @override
  String get tournamentStatsRewinds => 'Rewinds';

  @override
  String get tournamentStatsGoals => 'Buts';

  @override
  String get tournamentStatsMatches => 'Matchs';

  @override
  String get tournamentStatsReset => 'Réinitialiser';

  @override
  String get tournamentStatsResetTitle => 'Réinitialiser les statistiques';

  @override
  String get tournamentStatsResetContent => 'Êtes-vous sûr de vouloir réinitialiser toutes vos statistiques de tournoi ? Cette action est irréversible.';

  @override
  String get tournamentStatsResetCancel => 'Annuler';

  @override
  String get tournamentStatsResetConfirm => 'Réinitialiser';

  @override
  String get tournamentStatsResetSuccess => 'Statistiques réinitialisées avec succès';

  @override
  String get tournamentStatsClickToView => 'Cliquez pour voir vos performances';

  @override
  String get tournamentStatsMotivationStart => 'Commencez votre premier tournoi ! 🚀';

  @override
  String get tournamentStatsMotivationChampion => 'Excellent taux de victoire ! Vous êtes un champion ! 🏆';

  @override
  String get tournamentStatsMotivationGood => 'Bon taux de victoire ! Continuez comme ça ! 💪';

  @override
  String get tournamentStatsMotivationOpportunity => 'Chaque tournoi est une nouvelle opportunité ! 🔥';

  @override
  String get tournamentStatsMotivationPerseverance => 'La persévérance est la clé du succès ! Ne lâchez rien ! ⚽';

  @override
  String get tournamentHappyTitle => 'TOURNOI HAPPY';

  @override
  String get tournamentPathToGlory => 'Parcours vers la gloire';

  @override
  String get tournamentPhaseRoundOf16 => 'HUITIÈMES DE FINALE';

  @override
  String get tournamentPhaseQuarterFinals => 'QUARTS DE FINALE';

  @override
  String get tournamentPhaseSemiFinals => 'DEMI-FINALES';

  @override
  String get tournamentPhaseFinal => 'GRANDE FINALE';

  @override
  String get tournamentYourTeam => 'VOTRE ÉQUIPE';

  @override
  String get tournamentReadyToFight => 'PRÊT AU COMBAT';

  @override
  String get tournamentFourMatches => '⚡ 4 MATCHES POUR LA VICTOIRE ⚡';

  @override
  String get tournamentChooseTeam => 'CHOISIR VOTRE ÉQUIPE';

  @override
  String get tournamentChangeTeam => 'CHANGER D\'ÉQUIPE';

  @override
  String get tournamentNotEnoughTeams => 'Pas assez d\'équipes pour un tournoi complet';

  @override
  String get tournamentStart => 'LANCER LE TOURNOI';

  @override
  String get tournamentResultChampion => 'CHAMPION!';

  @override
  String get tournamentResultGoodPerformance => 'BONNE PERFORMANCE!';

  @override
  String get tournamentResultDefeat => 'DÉFAITE';

  @override
  String get tournamentResultTournamentWon => 'TOURNOI REMPORTÉ';

  @override
  String get tournamentResultEliminated => 'ÉLIMINÉ';

  @override
  String get tournamentResultEndOfJourney => 'FIN DU PARCOURS';

  @override
  String get tournamentResultCoins => '+25 COINS';

  @override
  String get tournamentResultResultsTitle => 'RÉSULTATS DU TOURNOI';

  @override
  String get tournamentResultChampionBadge => '🏆 CHAMPION';

  @override
  String get tournamentResultFighterBadge => '⚔️ COMBATTANT';

  @override
  String get tournamentResultEliminatedBadge => '💔 ÉLIMINÉ';

  @override
  String get tournamentResultWins => 'VICTOIRES';

  @override
  String get tournamentResultLosses => 'DÉFAITES';

  @override
  String get tournamentResultTotal => 'TOTAL';

  @override
  String get tournamentResultBackHome => 'RETOUR À L\'ACCUEIL';

  @override
  String get tournamentResultNewTournament => 'NOUVEAU TOURNOI';

  @override
  String get tournamentResultAchievementsUnlocked => 'Succès Débloqués !';

  @override
  String get tournamentResultSuccessGreat => 'GÉNIAL !';

  @override
  String get tournamentResultSnackChampion => 'CHAMPION! +25 COINS GAGNÉS!';

  @override
  String get gameResultLob => 'BUT sur LOB 🎯';

  @override
  String get gameResultCurve => 'BUT avec EFFET 🔥';

  @override
  String get gameResultKnuckle => 'BUT KNUCKLE ⚡';

  @override
  String get gameResultSoft => 'BUT en douceur 💨';

  @override
  String get gameResultGoal => 'BUUUUT!';

  @override
  String get gameResultWeakShot => 'TIR TROP FAIBLE 😢';

  @override
  String get gameResultSaved => 'ARRÊT DU GARDIEN!';

  @override
  String gameNextMatch(Object phase) {
    return 'Prochain match: $phase';
  }

  @override
  String get gameMissedShot => 'TIR RATÉ !';

  @override
  String get gameSecondChance => 'Seconde chance disponible';

  @override
  String gameUseRewind(Object count) {
    return 'Utiliser un rembobinage ?\n(Restants: $count)';
  }

  @override
  String get gameContinue => 'Continuer';

  @override
  String get gameRewind => 'Rembobiner';

  @override
  String get gameRewindSuccess => 'Tir rembobiné !';

  @override
  String get gameRewindFailed => 'Échec du rembobinage !';

  @override
  String get gameRoundReset => 'Manche réinitialisée !';

  @override
  String get gameGoalScored => 'But marqué !';

  @override
  String get gameGoalSaved => 'Arrêt du gardien !';

  @override
  String get gameWhistle => 'Coup de sifflet !';

  @override
  String get gameSuddenDeath => 'MORT SUBITE';

  @override
  String get gameAIShootingPrompt => 'L\'IA va tirer - Choisissez votre plongée !';

  @override
  String get gameAITurnWait => 'Tour de l\'IA - Patientez...';

  @override
  String get coinInfoTitle => 'Trésorerie';

  @override
  String get coinInfoBalance => 'Votre Solde';

  @override
  String get coinInfoAdReward => 'Gain Pub';

  @override
  String get coinInfoShop => 'BOUTIQUE';

  @override
  String coinInfoShopAdded(Object coins) {
    return '+$coins coins ajoutés !';
  }

  @override
  String get coinInfoShopUnavailable => 'La publicité est indisponible.';

  @override
  String get coinInfoShopGift => 'Cadeau quotidien';

  @override
  String coinInfoShopGiftDesc(Object coins) {
    return 'Regardez une vidéo pour gagner $coins coins !';
  }

  @override
  String get coinInfoShopPubFree => 'Pub Gratuit';

  @override
  String get coinInfoShopUseCoins => 'Utilisez vos coins pour acheter des rembobinages !';

  @override
  String get settingsOptions => 'Options';

  @override
  String get settingsClose => 'Fermer';

  @override
  String get rulesTitle => 'Règles du Jeu';

  @override
  String get rules1 => '1. Choisissez une direction pour tirer.';

  @override
  String get rules2 => '2. Le gardien plonge aléatoirement.';

  @override
  String get rules3 => '3. Marquez 5 buts pour gagner !';

  @override
  String get rules4 => '4. Utilisez les rembobinages si vous ratez.';

  @override
  String get rulesUnderstood => 'Compris !';

  @override
  String get inviteShareText => 'HappyGoal ! ⚽\n\nViens tirer des penalties et défie-moi !\nTélécharge : https://play.google.com/store/apps/details?id=com.heyhappy.happygoal';

  @override
  String get inviteShareSubject => 'HappyGoal';

  @override
  String get achievementsTitle => 'Succès';

  @override
  String achievementsUnlocked(Object total, Object unlocked) {
    return '$unlocked / $total débloqués';
  }

  @override
  String get achievementsCategoryMatches => 'Matchs';

  @override
  String get achievementsCategoryGoals => 'Buts';

  @override
  String get achievementsCategoryTournaments => 'Tournois';

  @override
  String get achievementsCategorySpecial => 'Spéciaux';

  @override
  String get achievementsCategorySkills => 'Compétences';

  @override
  String get achievementsStatWins => 'Victoires';

  @override
  String get achievementsProgressGlobal => 'Progression globale';

  @override
  String get achievementsNone => 'Aucun succès dans cette catégorie';

  @override
  String get achievementsClaimed => 'Réclamé';

  @override
  String achievementsReward(Object coins) {
    return '+$coins coins';
  }

  @override
  String achievementsSnackClaimed(Object coins) {
    return '+$coins coins réclamés !';
  }

  @override
  String achievementsProgress(Object current, Object target) {
    return '$current/$target';
  }

  @override
  String get achievementsRarityCommon => 'Commun';

  @override
  String get achievementsRarityRare => 'Rare';

  @override
  String get achievementsRarityEpic => 'Épique';

  @override
  String get achievementsRarityLegendary => 'Légendaire';

  @override
  String get achievementsBack => 'Retour';

  @override
  String achievementsCompletionPercent(Object percent) {
    return '$percent%';
  }

  @override
  String achievementsProgressBar(Object percent) {
    return '$percent%';
  }

  @override
  String get tutorialSettingsTitle => 'Tutoriels';

  @override
  String get tutorialSettingsHeader => 'Gestion des tutoriels';

  @override
  String get tutorialSettingsHeaderDesc => 'Gérez l\'affichage des tutoriels pour chaque écran. Les tutoriels marqués comme \'Vu\' ne s\'afficheront plus automatiquement.';

  @override
  String get tutorialSettingsHome => 'Écran d\'accueil';

  @override
  String get tutorialSettingsModeSelection => 'Sélection du mode';

  @override
  String get tutorialSettingsTeamSelection => 'Sélection des équipes';

  @override
  String get tutorialSettingsGameSolo => 'Jeu solo';

  @override
  String get tutorialSettingsGameMulti => 'Jeu multijoueur';

  @override
  String get tutorialSettingsTournament => 'Mode tournoi';

  @override
  String get tutorialSettingsHomeDesc => 'Guide des fonctionnalités principales';

  @override
  String get tutorialSettingsModeSelectionDesc => 'Explication des différents modes de jeu';

  @override
  String get tutorialSettingsTeamSelectionDesc => 'Comment choisir vos équipes';

  @override
  String get tutorialSettingsGameSoloDesc => 'Mécaniques de jeu contre l\'IA';

  @override
  String get tutorialSettingsGameMultiDesc => 'Jeu à deux joueurs';

  @override
  String get tutorialSettingsTournamentDesc => 'Navigation dans le tournoi';

  @override
  String get tutorialSettingsSeen => 'Vu';

  @override
  String get tutorialSettingsNew => 'Nouveau';

  @override
  String get tutorialSettingsWillShow => 'S\'affichera automatiquement';

  @override
  String get tutorialSettingsReactivate => 'Réactiver';

  @override
  String get tutorialSettingsResetAll => 'Réinitialiser tous les tutoriels';

  @override
  String get tutorialSettingsResetConfirmTitle => 'Confirmer la réinitialisation';

  @override
  String get tutorialSettingsResetConfirmContent => 'Êtes-vous sûr de vouloir réinitialiser tous les tutoriels ? Ils s\'afficheront à nouveau lors de vos prochaines visites.';

  @override
  String get tutorialSettingsResetCancel => 'Annuler';

  @override
  String get tutorialSettingsResetConfirm => 'Confirmer';

  @override
  String get tutorialSettingsResetSuccess => 'Tous les tutoriels ont été réinitialisés';

  @override
  String tutorialSettingsResetSingle(Object title) {
    return 'Tutoriel \'$title\' réinitialisé';
  }

  @override
  String get tutorialSettingsWidgetTitle => 'Tutoriels';

  @override
  String get tutorialSettingsWidgetSubtitle => 'Gérer l\'affichage des guides';

  @override
  String get audioSettingsTitle => 'Paramètres audio';

  @override
  String get audioSettingsSound => 'Effets sonores';

  @override
  String get audioSettingsMusic => 'Musique de fond';

  @override
  String get audioSettingsBackground => 'Continuer la musique en arrière-plan';

  @override
  String get audioSettingsBackgroundDesc => 'La musique continue lorsque vous quittez l\'application';

  @override
  String get audioSettingsVolume => 'Volume';

  @override
  String get coinShopTitle => 'Boutique';

  @override
  String get coinShopLoading => 'Connexion au magasin\n(Chargement...)';

  @override
  String get coinShopSuccessTitle => 'Paiement Réussi !';

  @override
  String coinShopSuccessCoins(Object coins) {
    return '+$coins Coins ajoutés';
  }

  @override
  String get coinShopSuccessThanks => 'Merci pour votre soutien !';

  @override
  String get coinShopSuccessButton => 'SUPER !';

  @override
  String get coinShopClose => 'Fermer';

  @override
  String get coinShopBestOffer => 'MEILLEURE OFFRE';

  @override
  String get coinShopBonus10 => '+10% BONUS';

  @override
  String get coinShopPromo17 => '+17% PROMO';

  @override
  String get goalkeeperSwipeLabel => 'GLISSE LE GARDIEN';

  @override
  String get goalkeeperSwipeLeft => 'PLONGEON GAUCHE';

  @override
  String get goalkeeperSwipeSlightLeft => 'LÉGÈREMENT GAUCHE';

  @override
  String get goalkeeperSwipeRight => 'PLONGEON DROITE';

  @override
  String get goalkeeperSwipeSlightRight => 'LÉGÈREMENT DROITE';

  @override
  String get goalkeeperSwipeCenter => 'CENTRE';

  @override
  String get goalkeeperSwipeDived => 'PLONGÉE !';

  @override
  String get goalkeeperSwipeZoneLeft => 'G';

  @override
  String get goalkeeperSwipeZoneCenter => 'C';

  @override
  String get goalkeeperSwipeZoneRight => 'D';

  @override
  String get rewindLimitTitle => 'Limite atteinte';

  @override
  String get rewindLimitDesc => 'Vous avez utilisé tous vos rembobinages autorisés pour ce match.';

  @override
  String get rewindLimitInfo => 'Informations:';

  @override
  String rewindLimitMax(Object max) {
    return '• Maximum $max rembobinages par match';
  }

  @override
  String rewindLimitUsed(Object max, Object used) {
    return '• Utilisés: $used/$max';
  }

  @override
  String rewindLimitTotal(Object total) {
    return '• Rembobinages totaux: $total';
  }

  @override
  String get rewindLimitReset => 'Vos rembobinages se réinitialiseront au prochain match !';

  @override
  String get rewindLimitUnderstood => 'Compris';

  @override
  String get rewindLimitRefill => 'Faire le plein';

  @override
  String get coinsNeededTitle => 'Besoin de Coins ?';

  @override
  String coinsNeededDesc(Object amount) {
    return 'Regardez une publicité pour gagner $amount coins !';
  }

  @override
  String coinsEarnedSnack(Object amount) {
    return '+$amount coins gagnés !';
  }

  @override
  String get adUnavailableSnack => 'Publicité non disponible';

  @override
  String get coinSystemTitle => 'Système de Coins';

  @override
  String get coinSystemDesc => 'Gérez votre monnaie virtuelle :';

  @override
  String get coinSystemBalance => '📊 Votre solde';

  @override
  String get coinSystemRewindCost => '🔄 Coût rembobinage';

  @override
  String get coinSystemAdReward => '🎥 Gain Publicité';

  @override
  String get freeAdButton => 'Pub Gratuite';

  @override
  String get buyCoinsButton => 'Acheter Coins';

  @override
  String get buyRewindButton => 'Acheter Replay';

  @override
  String get swipeShotHint => 'GLISSE VERS LE HAUT';

  @override
  String get swipeShotEffectNormal => 'Normal';

  @override
  String get swipeShotEffectCurve => 'Effet';

  @override
  String get swipeShotEffectLob => 'Lob';

  @override
  String get swipeShotEffectKnuckle => 'Knuckle';

  @override
  String get teamFrance => 'France';

  @override
  String get teamGermany => 'Allemagne';

  @override
  String get teamSpain => 'Espagne';

  @override
  String get teamItaly => 'Italie';

  @override
  String get teamRussia => 'Russie';

  @override
  String get teamEngland => 'Angleterre';

  @override
  String get teamPortugal => 'Portugal';

  @override
  String get teamBelgium => 'Belgique';

  @override
  String get teamArgentina => 'Argentine';

  @override
  String get teamBrazil => 'Brésil';

  @override
  String get teamUSA => 'USA';

  @override
  String get teamCanada => 'Canada';

  @override
  String get teamBenin => 'Bénin';

  @override
  String get teamNigeria => 'Nigéria';

  @override
  String get teamTogo => 'Togo';

  @override
  String get teamNiger => 'Niger';

  @override
  String get teamGhana => 'Ghana';

  @override
  String get teamIvoryCoast => 'Côte d\'Ivoire';

  @override
  String get teamJapan => 'Japon';

  @override
  String get teamSouthKorea => 'Corée du Sud';

  @override
  String get teamChina => 'Chine';

  @override
  String get teamSaudiArabia => 'Arabie Saoudite';

  @override
  String get teamAustralia => 'Australie';

  @override
  String get continentEurope => 'Europe';

  @override
  String get continentAmerica => 'Amérique';

  @override
  String get continentAfrica => 'Afrique';

  @override
  String get continentAsia => 'Asie';

  @override
  String get continentOceania => 'Océanie';

  @override
  String get tutorialGameSoloTitle1 => 'Bienvenue sur le terrain !';

  @override
  String get tutorialGameSoloDesc1 => 'Glisse depuis le ballon vers le haut pour tirer ! La vitesse = la puissance.';

  @override
  String get tutorialGameSoloSwipeLabel => 'Swipe pour marquer !';

  @override
  String get tutorialGameSoloTitle2 => 'Rembobiner et Récompense ↩️';

  @override
  String get tutorialGameSoloDesc2 => 'Si vous ratez un tir, utilisez un **Rembobinage** pour revenir en arrière.';

  @override
  String get tutorialGameSoloTip2a => 'Gagnez plus en regardant une pub.';

  @override
  String get tutorialGameSoloTip2b => 'Utilisez-le judicieusement.';

  @override
  String get tutorialGameSoloTitle3 => 'Le tableau de score';

  @override
  String get tutorialGameSoloDesc3 => 'Suivez ici les scores des deux équipes.';

  @override
  String get tutorialGameSoloTitle4 => 'Choisir l\'effet';

  @override
  String get tutorialGameSoloDesc4 => 'Normal, Effet (curve), Lob ou Knuckle — sélectionnez avant de tirer.';

  @override
  String get tutorialGameSoloEffectNormal => 'Normal : tir classique';

  @override
  String get tutorialGameSoloEffectCurve => 'Effet : trajectoire courbée';

  @override
  String get tutorialGameSoloEffectLob => 'Lob : par-dessus le gardien';

  @override
  String get tutorialGameSoloEffectKnuckle => 'Knuckle : trajectoire imprévisible';

  @override
  String get tutorialGameMultiTitle1 => 'Mode Multijoueur !';

  @override
  String get tutorialGameMultiDesc1 => 'Vous jouez contre un ami ! Chacun votre tour.';

  @override
  String get tutorialGameMultiTitle2 => 'Glissez pour tirer';

  @override
  String get tutorialGameMultiDesc2 => 'Swipez depuis le ballon vers le haut — direction et vitesse comptent !';

  @override
  String get tutorialGameMultiTitle3 => 'Rembobiner ↩️';

  @override
  String get tutorialGameMultiDesc3 => 'Utilisez un **Rembobinage** pour annuler un tir raté.';

  @override
  String get challengeWinTitle => 'Gagner le match';

  @override
  String get challengeWinDesc => 'Remportez la séance de tirs au but.';

  @override
  String get challengeKnuckleTitle => 'Marquer un but en Knuckle';

  @override
  String get challengeKnuckleDesc => 'Marquez au moins 1 but avec l\'effet Knuckle.';

  @override
  String get challengePowerTitle => 'Tous les buts puissance > 80';

  @override
  String get challengePowerDesc => 'Chaque but marqué doit avoir été tiré avec une puissance supérieure à 80.';

  @override
  String get challengeConcedeLessTitle => 'Encaisser maximum 2 buts';

  @override
  String get challengeConcedeLessDesc => 'Ne laissez pas l\'adversaire marquer plus de 2 buts.';

  @override
  String get challengeAllLobTitle => 'Tous les buts en Lob';

  @override
  String get challengeAllLobDesc => 'Chaque but marqué doit avoir été tiré avec l\'effet Lob.';

  @override
  String get challengeCurveTitle => 'Marquer 2 buts en Curve';

  @override
  String get challengeCurveDesc => 'Marquez au moins 2 buts avec l\'effet Curve.';

  @override
  String get challengeLobTitle => 'Marquer 3 buts en Lob';

  @override
  String get challengeLobDesc => 'Marquez au moins 3 buts avec l\'effet Lob.';

  @override
  String get challengeSaveTitle => 'Réaliser au moins 1 arrêt';

  @override
  String get challengeSaveDesc => 'Votre gardien doit stopper au moins un tir adverse.';

  @override
  String get heroResultStatsTitle => 'STATS DU MATCH';

  @override
  String get heroResultStatShots => 'Tirs tentés';

  @override
  String get heroResultStatGoals => 'Buts marqués';

  @override
  String get heroResultStatSaves => 'Arrêts réalisés';

  @override
  String get heroResultStatConceded => 'Buts encaissés';

  @override
  String heroResultStatGoalsEffect(String effect) {
    return 'Buts $effect';
  }

  @override
  String get heroResultReplay => 'REJOUER';

  @override
  String get shotEffectNormal => 'Normal';

  @override
  String get shotEffectCurve => 'Curve';

  @override
  String get shotEffectLob => 'Lob';

  @override
  String get shotEffectKnuckle => 'Knuckle';
}

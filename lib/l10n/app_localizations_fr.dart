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
}

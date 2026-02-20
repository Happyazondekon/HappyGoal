// tournament_mode_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:happygoal/screens/game_screen.dart';
import 'package:happygoal/models/team.dart';
import 'package:happygoal/models/game_state.dart';
import 'mode_selection_screen.dart';
import 'team_selection_screen.dart';
import 'package:happygoal/constants.dart';
import 'package:happygoal/utils/responsive_helper.dart';
import 'dart:convert'; // Pour json.encode et json.decode
import 'package:happygoal/l10n/app_localizations.dart';

class TournamentModeScreen extends StatefulWidget {
  const TournamentModeScreen({Key? key}) : super(key: key);

  @override
  _TournamentModeScreenState createState() => _TournamentModeScreenState();
}

class _TournamentModeScreenState extends State<TournamentModeScreen> {
  Team? selectedTeam;
  TournamentStats _tournamentStats = TournamentStats();
  bool _showStats = false;

  @override
  void initState() {
    super.initState();
    _loadTournamentStats();
  }

  Future<void> _loadTournamentStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString('tournament_stats');

      if (statsJson != null) {
        final Map<String, dynamic> statsMap = Map<String, dynamic>.from(json.decode(statsJson));
        setState(() {
          _tournamentStats = TournamentStats.fromJson(statsMap);
        });
        print('✅ Statistiques chargées: ${_tournamentStats.tournamentsPlayed} tournois joués, ${_tournamentStats.tournamentsWon} gagnés');
      } else {
        print('📊 Aucune statistique trouvée, initialisation des valeurs par défaut');
        _tournamentStats = TournamentStats();
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des statistiques: $e');
      _tournamentStats = TournamentStats();
    }
  }

  Future<void> _saveTournamentStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = json.encode(_tournamentStats.toJson());
      await prefs.setString('tournament_stats', statsJson);
      print('💾 Statistiques sauvegardées: ${_tournamentStats.tournamentsPlayed} tournois');
    } catch (e) {
      print('❌ Erreur lors de la sauvegarde des statistiques: $e');
    }
  }

  Widget _buildStatsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.scale(context, 20), vertical: ResponsiveHelper.scale(context, 12)),
      padding: EdgeInsets.all(ResponsiveHelper.scale(context, 20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blueAccent.withOpacity(0.25),
            Colors.deepPurpleAccent.withOpacity(0.25),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _showStats = !_showStats),
            child: Row(
              children: [
                Icon(Icons.analytics, color: Colors.white, size: ResponsiveHelper.scale(context, 24)),
                SizedBox(width: ResponsiveHelper.scale(context, 12)),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.tournamentStatsTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveHelper.textScale(context, 18),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _showStats ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                  size: ResponsiveHelper.scale(context, 22),
                ),
              ],
            ),
          ),
          if (_showStats) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white54),
            const SizedBox(height: 14),
            _buildCompactStatsGrid(),
            if (_tournamentStats.lastTournamentDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  AppLocalizations.of(context)!.tournamentStatsLast(_formatDate(_tournamentStats.lastTournamentDate!)),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  Icon(
                    _tournamentStats.winRate > 0.5 ? Icons.emoji_events : Icons.trending_up,
                    color: _tournamentStats.winRate > 0.5 ? Colors.amberAccent : Colors.lightGreenAccent,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getMotivationalMessage(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (_tournamentStats.tournamentsPlayed > 0) ...[
              const SizedBox(height: 18),
              Center(
                child: ElevatedButton(
                  onPressed: _resetStats,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 6,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.tournamentStatsReset,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ] else ...[
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.tournamentStatsClickToView,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildCompactStatItem('🏆', AppLocalizations.of(context)!.tournamentStatsPlayed, '${_tournamentStats.tournamentsPlayed}')),
            Expanded(child: _buildCompactStatItem('✅', AppLocalizations.of(context)!.tournamentStatsWon, '${_tournamentStats.tournamentsWon}')),
            Expanded(child: _buildCompactStatItem('📈', AppLocalizations.of(context)!.tournamentStatsVictory, _tournamentStats.getFormattedWinRate())),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildCompactStatItem('↩️', AppLocalizations.of(context)!.tournamentStatsRewinds, '${_tournamentStats.totalRewindsUsed}')),
            Expanded(child: _buildCompactStatItem('⚽', AppLocalizations.of(context)!.tournamentStatsGoals, '${_tournamentStats.totalGoalsScored}')),
            Expanded(child: _buildCompactStatItem('💪', AppLocalizations.of(context)!.tournamentStatsMatches, '${_tournamentStats.totalMatchesWon}')),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactStatItem(String emoji, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getMotivationalMessage() {
    if (_tournamentStats.tournamentsPlayed == 0) {
      return AppLocalizations.of(context)!.tournamentStatsMotivationStart;
    } else if (_tournamentStats.winRate > 0.7) {
      return AppLocalizations.of(context)!.tournamentStatsMotivationChampion;
    } else if (_tournamentStats.winRate > 0.5) {
      return AppLocalizations.of(context)!.tournamentStatsMotivationGood;
    } else if (_tournamentStats.winRate > 0.3) {
      return AppLocalizations.of(context)!.tournamentStatsMotivationOpportunity;
    } else {
      return AppLocalizations.of(context)!.tournamentStatsMotivationPerseverance;
    }
  }

  void _resetStats() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          AppLocalizations.of(context)!.tournamentStatsResetTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          AppLocalizations.of(context)!.tournamentStatsResetContent,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.tournamentStatsResetCancel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _tournamentStats = TournamentStats();
              });
              _saveTournamentStats();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.tournamentStatsResetSuccess),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              AppLocalizations.of(context)!.tournamentStatsResetConfirm,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentPhase(String emoji, String phase1, String phase2, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: phase1,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' $phase2',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startTournament() {
    List<Team> allTeams = Team.getPredefinedTeams();

    if (allTeams.length < 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pas assez d\'équipes pour un tournoi complet'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final tournamentState = TournamentState(
      allTeams: allTeams,
      userTeam: selectedTeam,
    );

    tournamentState.startTournament();

    final gameState = GameState(
      team1: selectedTeam,
      team2: tournamentState.currentOpponent,
      isSoloMode: true,
      isTournamentMode: true,
      currentPhase: GamePhase.playerShooting,
    );

    gameState.tournamentState = tournamentState;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(gameState: gameState),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/stadium_background.jpg'),
                fit: BoxFit.fill,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ModeSelectionScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  AppLocalizations.of(context)!.tournamentHappyTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(2.0, 2.0),
                                        blurRadius: 4.0,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          _buildStatsSection(),

                          const SizedBox(height: 20),

                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.tournamentPathToGlory,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                _buildTournamentPhase('🥅', AppLocalizations.of(context)!.tournamentPhaseRoundOf16, '', Colors.blue),
                                const SizedBox(height: 8),
                                _buildTournamentPhase('⚽', AppLocalizations.of(context)!.tournamentPhaseQuarterFinals, '', Colors.green),
                                const SizedBox(height: 8),
                                _buildTournamentPhase('🏆', AppLocalizations.of(context)!.tournamentPhaseSemiFinals, '', Colors.orange),
                                const SizedBox(height: 8),
                                _buildTournamentPhase('👑', AppLocalizations.of(context)!.tournamentPhaseFinal, '', Colors.amber),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          if (selectedTeam != null)
                            Container(
                              padding: const EdgeInsets.all(18),
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.white.withOpacity(0.9), Colors.grey[200]!],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.18),
                                    blurRadius: 18,
                                    offset: const Offset(0, 7),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.sports_soccer, color: selectedTeam!.color, size: 28),
                                      const SizedBox(width: 14),
                                      Flexible(
                                        child: Text(
                                          AppLocalizations.of(context)!.tournamentYourTeam,
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: selectedTeam!.color.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(color: selectedTeam!.color.withOpacity(0.4)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.12),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(14),
                                          child: Image.asset(
                                            selectedTeam!.flagImage,
                                            height: 56,
                                            width: 84,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                selectedTeam!.name,
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: selectedTeam!.color,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: selectedTeam!.color,
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  AppLocalizations.of(context)!.tournamentReadyToFight,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 20),

                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TeamSelectionScreen(
                                      isSoloMode: true,
                                      isTournamentMode: true,
                                      onTeamSelected: (team) {
                                        setState(() {
                                          selectedTeam = team;
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedTeam == null ? AppColors.primary : Colors.orangeAccent,
                                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    selectedTeam == null ? Icons.add_circle_outline : Icons.swap_horiz,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      selectedTeam == null
                                        ? AppLocalizations.of(context)!.tournamentChooseTeam
                                        : AppLocalizations.of(context)!.tournamentChangeTeam,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          if (selectedTeam != null)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.amber.withOpacity(0.5)),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.tournamentFourMatches,
                                      style: const TextStyle(
                                        color: Colors.amber,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  ElevatedButton(
                                    onPressed: _startTournament,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.greenAccent.shade700,
                                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(36),
                                      ),
                                      elevation: 12,
                                      shadowColor: Colors.greenAccent.shade400,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                                        const SizedBox(width: 12),
                                        Flexible(
                                          child: Text(
                                            AppLocalizations.of(context)!.tournamentStart,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.2,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

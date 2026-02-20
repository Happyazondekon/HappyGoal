// tournament_mode_screen.dart
import 'dart:math' as math;
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

class _TournamentModeScreenState extends State<TournamentModeScreen>
    with TickerProviderStateMixin {
  Team? selectedTeam;
  TournamentStats _tournamentStats = TournamentStats();
  bool _showStats = false;

  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 1.0, end: 1.15).animate(_pulseController);
    _glowAnimation =
        Tween<double>(begin: 0.5, end: 1.0).animate(_glowController);
    _loadTournamentStats();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
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
          // Grass background inspired by Hero Mode
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2D5016),
                  Color(0xFF1B3A0F),
                  Color(0xFF0A1F00),
                ],
              ),
            ),
          ),

          // Grass texture stripes
          CustomPaint(
            size: Size.infinite,
            painter: _GrassStripePainter(),
          ),

          // Top decorative border
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBorder(),
          ),

          // Bottom decorative border
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBorder(),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        children: [
                          _buildTournamentBadge(),
                          const SizedBox(height: 20),
                          _buildStatsSection(),
                          const SizedBox(height: 20),
                          _buildPhaseSection(),
                          const SizedBox(height: 20),
                          if (selectedTeam == null)
                            _buildTeamSelectionButton()
                          else
                            _buildSelectedTeamCard(),
                          const SizedBox(height: 20),
                          if (selectedTeam != null) _buildStartButton(),
                          const SizedBox(height: 20),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ModeSelectionScreen(),
                ),
              );
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child:
                  const Icon(Icons.arrow_back, color: Colors.white, size: 22),
            ),
          ),

          // Title
          Text(
            AppLocalizations.of(context)!.tournamentModeTitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveHelper.textScale(context, 24),
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),

          // Trophy icon with glow
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFF57F17)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700)
                          .withOpacity(0.4 * _glowAnimation.value),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(Icons.emoji_events, color: Colors.white, size: 22),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopBorder() {
    return Container(
      height: ResponsiveHelper.scale(context, 30),
      decoration: const BoxDecoration(
        color: Color(0xFFF5E6C8),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          12,
          (i) => Container(
            width: ResponsiveHelper.scale(context, 20),
            height: ResponsiveHelper.scale(context, 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFDAAE50), Color(0xFFA67C52)],
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBorder() {
    return Container(
      height: ResponsiveHelper.scale(context, 30),
      decoration: const BoxDecoration(
        color: Color(0xFF8B4513),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
    );
  }

  Widget _buildTournamentBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFF57F17)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text(
            AppLocalizations.of(context)!.tournamentModeDescription,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.star, color: Colors.white, size: 20),
        ],
      ),
    );
  }

  Widget _buildPhaseSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.tournamentPathToGlory,
            style: TextStyle(
              color: const Color(0xFFFFD700),
              fontSize: ResponsiveHelper.textScale(context, 18),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 15),
          _buildTournamentPhase('🥅', AppLocalizations.of(context)!.tournamentPhaseRoundOf16, Colors.blue),
          const SizedBox(height: 8),
          _buildTournamentPhase('⚽', AppLocalizations.of(context)!.tournamentPhaseQuarterFinals, Colors.green),
          const SizedBox(height: 8),
          _buildTournamentPhase('🏆', AppLocalizations.of(context)!.tournamentPhaseSemiFinals, Colors.orange),
          const SizedBox(height: 8),
          _buildTournamentPhase('👑', AppLocalizations.of(context)!.tournamentPhaseFinal, Colors.amber),
        ],
      ),
    );
  }

  Widget _buildTournamentPhase(String emoji, String phaseName, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              phaseName,
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveHelper.textScale(context, 14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSelectionButton() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
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
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.tournamentChooseTeam,
                    style: const TextStyle(
                      fontSize: 15,
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
      ),
    );
  }

  Widget _buildSelectedTeamCard() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.12),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.sports_soccer, color: Color(0xFFFFD700), size: 24),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)!.tournamentYourTeam,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.textScale(context, 16),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selectedTeam!.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: selectedTeam!.color.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      selectedTeam!.flagImage,
                      height: 50,
                      width: 75,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedTeam!.name,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.textScale(context, 18),
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: selectedTeam!.color.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.tournamentReadyToFight,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
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
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: const Icon(
                        Icons.swap_horiz,
                        color: Color(0xFFFFD700),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: _startTournament,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 0,
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFF57F17)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.tournamentStart,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GrassStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final stripeHeight = size.height / 10;
    for (int i = 0; i < 10; i++) {
      paint.color = i % 2 == 0
          ? Colors.black.withOpacity(0.04)
          : Colors.transparent;
      canvas.drawRect(
        Rect.fromLTWH(0, i * stripeHeight, size.width, stripeHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

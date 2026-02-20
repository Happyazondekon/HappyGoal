// lib/screens/team_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:happygoal/l10n/app_localizations.dart';
import 'package:happygoal/models/team.dart';
import 'package:happygoal/models/game_state.dart';
import 'game_screen.dart';
import 'package:happygoal/models/ai_opponent.dart';
import 'package:happygoal/utils/responsive_helper.dart';
import 'package:happygoal/constants.dart';

class TeamSelectionScreen extends StatefulWidget {
  final bool isSoloMode;
  final bool isTournamentMode;
  final Function(Team)? onTeamSelected;
  final double? aiIntelligence;
  final Team? preSelectedTeam1;
  final Team? preSelectedTeam2;
  final bool startDirectly;

  const TeamSelectionScreen({
    Key? key,
    this.isSoloMode = false,
    this.isTournamentMode = false,
    this.aiIntelligence,
    this.preSelectedTeam1,
    this.preSelectedTeam2,
    this.startDirectly = false,
    this.onTeamSelected,
  }) : super(key: key);

  @override
  State<TeamSelectionScreen> createState() => _TeamSelectionScreenState();
}

class _TeamSelectionScreenState extends State<TeamSelectionScreen>
    with TickerProviderStateMixin {
  Team? selectedTeam1;
  Team? selectedTeam2;
  late final Map<String, List<Team>> _teamsByContinent;
  String? _selectedContinent;
  late AnimationController _headerController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();

    // Grouper les équipes par continent
    _teamsByContinent = _groupTeamsByContinent(Team.getPredefinedTeams());

    if (widget.preSelectedTeam1 != null) {
      selectedTeam1 = widget.preSelectedTeam1;
    }
    if (widget.preSelectedTeam2 != null) {
      selectedTeam2 = widget.preSelectedTeam2;
    }

    if (widget.startDirectly && selectedTeam1 != null && selectedTeam2 != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startGame();
      });
    }

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutBack,
    );
  }

  // Méthode pour regrouper les équipes par continent
  Map<String, List<Team>> _groupTeamsByContinent(List<Team> allTeams) {
    Map<String, List<Team>> map = {};
    for (var team in allTeams) {
      if (!map.containsKey(team.continent)) {
        map[team.continent] = [];
      }
      map[team.continent]!.add(team);
    }
    return map;
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  void _handleTeamSelection(Team team) {
    setState(() {
      if (team == selectedTeam1) {
        selectedTeam1 = null;
      } else if (team == selectedTeam2) {
        selectedTeam2 = null;
      } else if (selectedTeam1 == null) {
        selectedTeam1 = team;
      } else if (selectedTeam2 == null && team != selectedTeam1) {
        selectedTeam2 = team;
      }
    });
    if (widget.isTournamentMode) {
      widget.onTeamSelected?.call(team);
      Navigator.pop(context);
      return;
    }
  }

  void _startGame() {
    if (selectedTeam1 != null && selectedTeam2 != null) {
      final gameState = GameState(
        team1: selectedTeam1!,
        team2: selectedTeam2!,
        currentPhase: GamePhase.playerShooting,
        isSoloMode: widget.isSoloMode,
        isTournamentMode: widget.isTournamentMode,
      );

      if (widget.isSoloMode && widget.aiIntelligence != null) {
        gameState.aiOpponent = AIOpponent(intelligence: widget.aiIntelligence!);
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(gameState: gameState),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.teamSelectionSelectTwo)),
      );
    }
  }

  String _getModeTitle(AppLocalizations l10n) {
    if (widget.isTournamentMode) return l10n.teamSelectionModeTournament;
    return widget.isSoloMode ? l10n.teamSelectionModeSolo : l10n.teamSelectionModeMulti;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final teams = Team.getPredefinedTeams();

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient matching game aesthetic
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D1F12),
                  Color(0xFF1A3A22),
                  Color(0xFF0F2916),
                ],
              ),
            ),
          ),

          // Decorative field lines
          CustomPaint(
            size: Size.infinite,
            painter: _FieldDecorPainter(),
          ),

          SafeArea(
            child: _selectedContinent == null
                ? _buildContinentView(context, l10n, teams)
                : _buildTeamsGridView(context, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildContinentView(BuildContext context, AppLocalizations l10n, List<Team> teams) {
    return Column(
      children: [
        // Header
        ScaleTransition(
          scale: _headerAnimation,
          child: _buildHeader(context, l10n),
        ),

        SizedBox(height: ResponsiveHelper.scale(context, 16)),

        // Selected teams preview
        if (selectedTeam1 != null || selectedTeam2 != null)
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.scale(context, 16)),
            child: _buildSelectedTeamsPreview(context, l10n),
          ),

        SizedBox(height: ResponsiveHelper.scale(context, 16)),

        // Continents list
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.scale(context, 16),
                vertical: ResponsiveHelper.scale(context, 8)),
            itemCount: _teamsByContinent.keys.length,
            itemBuilder: (context, index) {
              final continent = _teamsByContinent.keys.toList()[index];
              final continentTeams = _teamsByContinent[continent]!;
              final displayTeam =
                  continentTeams.isNotEmpty ? continentTeams.first : null;

              return _buildContinentCard(
                  context, continent, displayTeam, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(ResponsiveHelper.scale(context, 16)),
      child: Column(
        children: [
          Text(
            l10n.teamSelectionTitle,
            style: TextStyle(
              fontSize: ResponsiveHelper.textScale(context, 26),
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
              shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
            ),
          ),
          SizedBox(height: ResponsiveHelper.scale(context, 8)),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.scale(context, 12),
                vertical: ResponsiveHelper.scale(context, 6)),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                  ResponsiveHelper.scale(context, 20)),
            ),
            child: Text(
              _getModeTitle(l10n),
              style: TextStyle(
                fontSize: ResponsiveHelper.textScale(context, 13),
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTeamsPreview(
      BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.scale(context, 16),
          vertical: ResponsiveHelper.scale(context, 12)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius:
            BorderRadius.circular(ResponsiveHelper.scale(context, 16)),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.teamSelectionChooseTeams,
            style: TextStyle(
              color: Colors.white60,
              fontSize: ResponsiveHelper.textScale(context, 12),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: ResponsiveHelper.scale(context, 8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSelectedTeamPreview(
                context,
                selectedTeam1,
                l10n.teamSelectionTeam1,
                Color(0xFF2196F3),
              ),
              Icon(Icons.compare_arrows,
                  color: Colors.white38,
                  size: ResponsiveHelper.scale(context, 24)),
              _buildSelectedTeamPreview(
                context,
                selectedTeam2,
                l10n.teamSelectionTeam2,
                Color(0xFFFF5722),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTeamPreview(
    BuildContext context,
    Team? team,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white54,
            fontSize: ResponsiveHelper.textScale(context, 11),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: ResponsiveHelper.scale(context, 4)),
        if (team != null)
          ClipRRect(
            borderRadius:
                BorderRadius.circular(ResponsiveHelper.scale(context, 4)),
            child: Image.asset(
              team.flagImage,
              width: ResponsiveHelper.scale(context, 40),
              height: ResponsiveHelper.scale(context, 28),
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            width: ResponsiveHelper.scale(context, 40),
            height: ResponsiveHelper.scale(context, 28),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(ResponsiveHelper.scale(context, 4)),
            ),
            child: Icon(Icons.flag_outlined,
                color: Colors.white38,
                size: ResponsiveHelper.scale(context, 14)),
          ),
      ],
    );
  }

  Widget _buildContinentCard(BuildContext context, String continent,
      Team? displayTeam, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + index * 50),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedContinent = continent;
          });
        },
        child: Container(
          margin: EdgeInsets.only(bottom: ResponsiveHelper.scale(context, 12)),
          padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.scale(context, 16),
              vertical: ResponsiveHelper.scale(context, 14)),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(ResponsiveHelper.scale(context, 16)),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.03),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: ResponsiveHelper.scale(context, 8),
                offset: Offset(0, ResponsiveHelper.scale(context, 3)),
              )
            ],
          ),
          child: Row(
            children: [
              if (displayTeam != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                      ResponsiveHelper.scale(context, 8)),
                  child: Image.asset(
                    displayTeam.flagImage,
                    height: ResponsiveHelper.scale(context, 50),
                    width: ResponsiveHelper.scale(context, 80),
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(width: ResponsiveHelper.scale(context, 16)),
              Expanded(
                child: Text(
                  continent,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.textScale(context, 18),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  color: Colors.white54,
                  size: ResponsiveHelper.scale(context, 18)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamsGridView(BuildContext context, AppLocalizations l10n) {
    final teams = _teamsByContinent[_selectedContinent]!;

    return Column(
      children: [
        // Back button header
        Padding(
          padding: EdgeInsets.fromLTRB(
            ResponsiveHelper.scale(context, 16),
            ResponsiveHelper.scale(context, 16),
            ResponsiveHelper.scale(context, 16),
            0,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedContinent = null;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(ResponsiveHelper.scale(context, 10)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        ResponsiveHelper.scale(context, 12)),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Icon(Icons.arrow_back,
                      color: Colors.white,
                      size: ResponsiveHelper.scale(context, 20)),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    _selectedContinent ?? '',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.textScale(context, 20),
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(color: Colors.black54, blurRadius: 8)
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveHelper.scale(context, 42)),
            ],
          ),
        ),

        SizedBox(height: ResponsiveHelper.scale(context, 16)),

        // Teams grid
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.scale(context, 16),
                vertical: ResponsiveHelper.scale(context, 8)),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: ResponsiveHelper.scale(context, 12),
              mainAxisSpacing: ResponsiveHelper.scale(context, 12),
              childAspectRatio: 0.85,
            ),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              final isSelected =
                  team == selectedTeam1 || team == selectedTeam2;
              return _buildTeamCard(context, team, isSelected, index);
            },
          ),
        ),

        // Validate button
        if (selectedTeam1 != null && selectedTeam2 != null)
          Padding(
            padding: EdgeInsets.all(ResponsiveHelper.scale(context, 20)),
            child: _buildValidateButton(context, l10n),
          ),
      ],
    );
  }

  Widget _buildTeamCard(
      BuildContext context, Team team, bool isSelected, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + index * 30),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () => _handleTeamSelection(team),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(ResponsiveHelper.scale(context, 16)),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFFD700)
                  : Colors.white.withOpacity(0.12),
              width: isSelected
                  ? ResponsiveHelper.scale(context, 2.5)
                  : ResponsiveHelper.scale(context, 1),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? [
                    const Color(0xFFFFD700).withOpacity(0.2),
                    const Color(0xFFFFA000).withOpacity(0.1),
                  ]
                  : [
                    Colors.white.withOpacity(0.07),
                    Colors.white.withOpacity(0.03),
                  ],
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.3),
                      blurRadius: ResponsiveHelper.scale(context, 16),
                      spreadRadius: ResponsiveHelper.scale(context, 2),
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Flag
              Container(
                width: ResponsiveHelper.scale(context, 60),
                height: ResponsiveHelper.scale(context, 40),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(ResponsiveHelper.scale(context, 6)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black38,
                        blurRadius: ResponsiveHelper.scale(context, 6),
                        offset: Offset(
                            0, ResponsiveHelper.scale(context, 3)))
                  ],
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(ResponsiveHelper.scale(context, 6)),
                  child: Image.asset(team.flagImage, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: ResponsiveHelper.scale(context, 8)),
              Text(
                team.name,
                style: TextStyle(
                  fontSize: ResponsiveHelper.textScale(context, 11),
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? const Color(0xFFFFD700) : Colors.white70,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (isSelected) ...[
                SizedBox(height: ResponsiveHelper.scale(context, 4)),
                Icon(Icons.check_circle,
                    color: Color(0xFFFFD700),
                    size: ResponsiveHelper.scale(context, 16)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValidateButton(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.scale(context, 16),
              vertical: ResponsiveHelper.scale(context, 10)),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius:
                BorderRadius.circular(ResponsiveHelper.scale(context, 14)),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(ResponsiveHelper.scale(context, 4)),
                child: Image.asset(selectedTeam1!.flagImage,
                    width: ResponsiveHelper.scale(context, 36),
                    height: ResponsiveHelper.scale(context, 24),
                    fit: BoxFit.cover),
              ),
              SizedBox(width: ResponsiveHelper.scale(context, 8)),
              Text(
                selectedTeam1!.name,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveHelper.textScale(context, 12)),
              ),
              SizedBox(width: ResponsiveHelper.scale(context, 10)),
              Icon(Icons.compare_arrows,
                  color: Colors.white54,
                  size: ResponsiveHelper.scale(context, 20)),
              SizedBox(width: ResponsiveHelper.scale(context, 10)),
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(ResponsiveHelper.scale(context, 4)),
                child: Image.asset(selectedTeam2!.flagImage,
                    width: ResponsiveHelper.scale(context, 36),
                    height: ResponsiveHelper.scale(context, 24),
                    fit: BoxFit.cover),
              ),
              SizedBox(width: ResponsiveHelper.scale(context, 8)),
              Expanded(
                child: Text(
                  selectedTeam2!.name,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveHelper.textScale(context, 12)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: ResponsiveHelper.scale(context, 12)),
        SizedBox(
          width: double.infinity,
          height: ResponsiveHelper.scale(context, 56),
          child: ElevatedButton(
            onPressed: _startGame,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(ResponsiveHelper.scale(context, 16))),
              elevation: 0,
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFF57F17)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius:
                    BorderRadius.circular(ResponsiveHelper.scale(context, 16)),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sports_soccer,
                        color: Colors.white,
                        size: ResponsiveHelper.scale(context, 22)),
                    SizedBox(width: ResponsiveHelper.scale(context, 10)),
                    Text(
                      l10n.teamSelectionStart,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.textScale(context, 15),
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
      ],
    );
  }
}

class _FieldDecorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Center circle
    canvas.drawCircle(
        Offset(size.width / 2, size.height * 0.5), 80, paint);
    // Half line
    canvas.drawLine(Offset(0, size.height * 0.5),
        Offset(size.width, size.height * 0.5), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
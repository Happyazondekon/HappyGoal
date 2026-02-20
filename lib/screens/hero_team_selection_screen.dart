
import 'package:flutter/material.dart';
import 'package:happygoal/l10n/app_localizations.dart';
import 'package:happygoal/models/team.dart';
import 'package:happygoal/utils/responsive_helper.dart';

class HeroTeamSelectionScreen extends StatefulWidget {
  final Function(String countryCode) onCountrySelected;
  final String? selectedCountryCode;

  const HeroTeamSelectionScreen({
    Key? key,
    required this.onCountrySelected,
    this.selectedCountryCode,
  }) : super(key: key);

  @override
  State<HeroTeamSelectionScreen> createState() =>
      _HeroTeamSelectionScreenState();
}

class _HeroTeamSelectionScreenState extends State<HeroTeamSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerAnimation;
  String? _hovered;
  String? _localSelected;

  @override
  void initState() {
    super.initState();
    _localSelected = widget.selectedCountryCode;
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              children: [
                // Header
                ScaleTransition(
                  scale: _headerAnimation,
                  child: _buildHeader(context),
                ),

                SizedBox(height: ResponsiveHelper.scale(context, 16)),

                // Subtitle
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.scale(context, 24)),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.scale(context, 16),
                        vertical: ResponsiveHelper.scale(context, 10)),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(ResponsiveHelper.scale(context, 16)),
                      border:
                      Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.white54,
                            size: ResponsiveHelper.scale(context, 16)),
                        SizedBox(width: ResponsiveHelper.scale(context, 8)),
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context)!.heroTeamSelectSubtitle,
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: ResponsiveHelper.textScale(context, 13),
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: ResponsiveHelper.scale(context, 16)),

                // Team grid
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.scale(context, 16),
                        vertical: ResponsiveHelper.scale(context, 8)),
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: ResponsiveHelper.scale(context, 12),
                      mainAxisSpacing: ResponsiveHelper.scale(context, 12),
                      childAspectRatio: 0.85,
                    ),
                    itemCount: teams.length,
                    itemBuilder: (context, index) {
                      final team = teams[index];
                      final isSelected = _localSelected == team.name;
                      return _buildTeamCard(context, team, isSelected, index);
                    },
                  ),
                ),

                // Validate button
                if (_localSelected != null)
                  Padding(
                    padding: EdgeInsets.all(ResponsiveHelper.scale(context, 20)),
                    child: _buildValidateButton(context),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ResponsiveHelper.scale(context, 16),
        ResponsiveHelper.scale(context, 16),
        ResponsiveHelper.scale(context, 16),
        0,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(ResponsiveHelper.scale(context, 10)),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ResponsiveHelper.scale(context, 12)),
                border: Border.all(color: Colors.white24),
              ),
              child: Icon(Icons.arrow_back,
                  color: Colors.white,
                  size: ResponsiveHelper.scale(context, 20)),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.heroTeamSelectHeader1,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.textScale(context, 22),
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 3,
                      shadows: [
                        Shadow(color: Colors.black54, blurRadius: 8)
                      ],
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.heroTeamSelectHeader2,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.textScale(context, 14),
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF4CAF50),
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: ResponsiveHelper.scale(context, 42)), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildTeamCard(BuildContext context, Team team, bool isSelected, int index) {
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
        onTap: () {
          setState(() => _localSelected = team.name);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ResponsiveHelper.scale(context, 16)),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFFD700)
                  : Colors.white.withOpacity(0.12),
              width: isSelected ? ResponsiveHelper.scale(context, 2.5) : ResponsiveHelper.scale(context, 1),
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
                  borderRadius: BorderRadius.circular(ResponsiveHelper.scale(context, 6)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black38,
                        blurRadius: ResponsiveHelper.scale(context, 6),
                        offset: Offset(0, ResponsiveHelper.scale(context, 3)))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(ResponsiveHelper.scale(context, 6)),
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

  Widget _buildValidateButton(BuildContext context) {
    final teams = Team.getPredefinedTeams();
    final selectedTeam =
    teams.firstWhere((t) => t.name == _localSelected);

    return Column(
      children: [
        // Selected team preview
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.scale(context, 16),
              vertical: ResponsiveHelper.scale(context, 10)),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(ResponsiveHelper.scale(context, 14)),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(ResponsiveHelper.scale(context, 4)),
                child: Image.asset(selectedTeam.flagImage,
                    width: ResponsiveHelper.scale(context, 36),
                    height: ResponsiveHelper.scale(context, 24),
                    fit: BoxFit.cover),
              ),
              SizedBox(width: ResponsiveHelper.scale(context, 10)),
              Text(
                selectedTeam.name,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveHelper.textScale(context, 13)),
              ),
              SizedBox(width: ResponsiveHelper.scale(context, 10)),
              Icon(Icons.check,
                  color: Color(0xFF4CAF50),
                  size: ResponsiveHelper.scale(context, 18)),
            ],
          ),
        ),
        SizedBox(height: ResponsiveHelper.scale(context, 12)),
        SizedBox(
          width: double.infinity,
          height: ResponsiveHelper.scale(context, 56),
          child: ElevatedButton(
            onPressed: () => widget.onCountrySelected(_localSelected!),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveHelper.scale(context, 16))),
              elevation: 0,
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFF57F17)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(ResponsiveHelper.scale(context, 16)),
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
                      AppLocalizations.of(context)!.heroTeamSelectStart,
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
        Offset(size.width / 2, size.height * 0.7), 80, paint);
    // Half line
    canvas.drawLine(Offset(0, size.height * 0.7),
        Offset(size.width, size.height * 0.7), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
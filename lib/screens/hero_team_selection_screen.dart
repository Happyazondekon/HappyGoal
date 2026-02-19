import 'package:flutter/material.dart';
import 'package:happygoal/models/team.dart';

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
                  child: _buildHeader(),
                ),

                const SizedBox(height: 16),

                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(16),
                      border:
                      Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.white54, size: 16),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Choisissez le pays que vous représenterez dans votre aventure Hero',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Team grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: teams.length,
                    itemBuilder: (context, index) {
                      final team = teams[index];
                      final isSelected = _localSelected == team.name;
                      return _buildTeamCard(team, isSelected, index);
                    },
                  ),
                ),

                // Validate button
                if (_localSelected != null)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildValidateButton(),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child:
              const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const Expanded(
            child: Center(
              child: Column(
                children: [
                  Text(
                    'CHOISISSEZ',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 3,
                      shadows: [
                        Shadow(color: Colors.black54, blurRadius: 8)
                      ],
                    ),
                  ),
                  Text(
                    'VOTRE PAYS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF4CAF50),
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 42), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildTeamCard(Team team, bool isSelected, int index) {
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
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFFD700)
                  : Colors.white.withOpacity(0.12),
              width: isSelected ? 2.5 : 1,
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
                blurRadius: 16,
                spreadRadius: 2,
              )
            ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Flag
              Container(
                width: 60,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black38,
                        blurRadius: 6,
                        offset: Offset(0, 3))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(team.flagImage, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                team.name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? const Color(0xFFFFD700) : Colors.white70,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (isSelected) ...[
                const SizedBox(height: 4),
                const Icon(Icons.check_circle,
                    color: Color(0xFFFFD700), size: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValidateButton() {
    final teams = Team.getPredefinedTeams();
    final selectedTeam =
    teams.firstWhere((t) => t.name == _localSelected);

    return Column(
      children: [
        // Selected team preview
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(selectedTeam.flagImage,
                    width: 36, height: 24, fit: BoxFit.cover),
              ),
              const SizedBox(width: 10),
              Text(
                selectedTeam.name,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.check, color: Color(0xFF4CAF50), size: 18),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => widget.onCountrySelected(_localSelected!),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFF57F17)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sports_soccer,
                        color: Colors.white, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'COMMENCER L\'AVENTURE',
                      style: TextStyle(
                        fontSize: 15,
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
// lib/widgets/goalkeeper_swipe_widget.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:happygoal/models/game_state.dart';

/// Callback identique à l'ancien widget gardien.
typedef OnDiveCallback = void Function(int direction);

class GoalkeeperSwipeWidget extends StatefulWidget {
  final OnDiveCallback onDive;

  const GoalkeeperSwipeWidget({Key? key, required this.onDive})
      : super(key: key);

  @override
  State<GoalkeeperSwipeWidget> createState() => _GoalkeeperSwipeWidgetState();
}

class _GoalkeeperSwipeWidgetState extends State<GoalkeeperSwipeWidget>
    with TickerProviderStateMixin {
  // ── Position du gardien ──────────────────────────────────────────────────
  // 0.0 = gauche extrême, 0.5 = centre, 1.0 = droite extrême
  double _goalkeeperPosition = 0.5;
  bool _isDragging = false;
  bool _diveSent = false;

  // ── Pour calculer la position depuis le drag ─────────────────────────────
  double _trackWidth = 0;
  double _dragStartX = 0;
  double _positionAtDragStart = 0.5;

  // ── Animations ───────────────────────────────────────────────────────────
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  late AnimationController _diveController;
  late Animation<double> _diveAnim;

  late AnimationController _hintController;
  late Animation<double> _hintAnim;

  // Direction finale calculée
  int? _lastDirection;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.10).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _diveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _diveAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _diveController, curve: Curves.easeIn),
    );

    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _hintAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hintController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _diveController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  // ── Conversion position → direction ─────────────────────────────────────
  // Zone morte centrale : entre 0.35 et 0.65 → centre
  int _positionToDirection(double pos) {
    if (pos < 0.35) return ShotDirection.left;
    if (pos > 0.65) return ShotDirection.right;
    return ShotDirection.center;
  }

  // ── Couleur de la zone de plongée ────────────────────────────────────────
  Color _zoneColor(double pos) {
    final dist = (pos - 0.5).abs(); // 0 = centre, 0.5 = extrême
    if (dist < 0.15) return const Color(0xFF4CAF50); // vert = centre
    if (dist < 0.30) return const Color(0xFFFFD600); // jaune = mi-chemin
    return const Color(0xFFE53935);                  // rouge = extrême
  }

  void _onPanStart(DragStartDetails details, double trackWidth) {
    if (_diveSent) return;
    _trackWidth = trackWidth;
    _dragStartX = details.localPosition.dx;
    _positionAtDragStart = _goalkeeperPosition;
    setState(() => _isDragging = true);
    _pulseController.stop();
    _hintController.stop();
    HapticFeedback.lightImpact();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging || _diveSent || _trackWidth == 0) return;
    final dx = details.localPosition.dx - _dragStartX;
    final delta = dx / _trackWidth;
    setState(() {
      _goalkeeperPosition = (_positionAtDragStart + delta).clamp(0.0, 1.0);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDragging || _diveSent) return;

    final direction = _positionToDirection(_goalkeeperPosition);
    _lastDirection = direction;

    // Feedback haptique selon l'intensité
    final dist = (_goalkeeperPosition - 0.5).abs();
    if (dist > 0.3) {
      HapticFeedback.heavyImpact();
    } else if (dist > 0.15) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }

    setState(() {
      _diveSent = true;
      _isDragging = false;
    });

    _diveController.forward().then((_) {
      widget.onDive(direction);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label contextuel ─────────────────────────────────────────────
        AnimatedOpacity(
          opacity: _diveSent ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildLabel(),
          ),
        ),

        // ── Piste de glissement ──────────────────────────────────────────
        LayoutBuilder(
          builder: (context, constraints) {
            final trackWidth = constraints.maxWidth - 48;
            return GestureDetector(
              onPanStart: (d) => _onPanStart(d, trackWidth),
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // ── Zone de glissement avec gardien ──────────────────
                    _buildTrack(trackWidth),
                    const SizedBox(height: 8),
                    // ── Indicateur de direction ───────────────────────────
                    _buildDirectionIndicator(),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLabel() {
    return AnimatedBuilder(
      animation: _hintAnim,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Flèche gauche animée
            Opacity(
              opacity: 0.4 + _hintAnim.value * 0.6,
              child: Transform.translate(
                offset: Offset(-4 * (1 - _hintAnim.value), 0),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 14),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(20),
                border:
                Border.all(color: Colors.white.withOpacity(0.2), width: 1),
              ),
              child: const Text(
                'GLISSE LE GARDIEN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Flèche droite animée
            Opacity(
              opacity: 0.4 + _hintAnim.value * 0.6,
              child: Transform.translate(
                offset: Offset(4 * (1 - _hintAnim.value), 0),
                child: const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white, size: 14),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrack(double trackWidth) {
    const double goalkeeperSize = 56.0;
    final double goalkeeperX = _goalkeeperPosition * trackWidth;
    final Color zoneColor = _zoneColor(_goalkeeperPosition);
    final int direction = _positionToDirection(_goalkeeperPosition);

    return SizedBox(
      height: 90,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Rail de la piste ──────────────────────────────────────────
          Positioned(
            top: 44,
            left: 0,
            right: 0,
            child: _buildRail(trackWidth, goalkeeperX, zoneColor),
          ),

          // ── Zones colorées gauche/droite/centre ───────────────────────
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: _buildZoneMarkers(trackWidth),
          ),

          // ── Gardien glissant ──────────────────────────────────────────
          Positioned(
            top: 0,
            left: goalkeeperX - goalkeeperSize / 2,
            child: AnimatedBuilder(
              animation: Listenable.merge(
                  [_pulseAnim, _diveAnim]),
              builder: (_, child) {
                final scale =
                _isDragging ? 1.08 : (_diveSent ? 1.0 : _pulseAnim.value);
                final opacity = _diveSent ? _diveAnim.value : 1.0;

                // Inclinaison selon la direction de glissement
                final tilt = (_goalkeeperPosition - 0.5) * 0.4;

                return Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Transform.rotate(
                      angle: tilt,
                      child: child,
                    ),
                  ),
                );
              },
              child: _buildGoalkeeperIcon(goalkeeperSize, zoneColor),
            ),
          ),

          // ── Traînée de mouvement ───────────────────────────────────────
          if (_isDragging)
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: CustomPaint(
                painter: _DragTrailPainter(
                  position: _goalkeeperPosition,
                  trackWidth: trackWidth,
                  color: zoneColor,
                ),
                size: Size(trackWidth, 50),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRail(double trackWidth, double goalkeeperX, Color zoneColor) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: Colors.white.withOpacity(0.12),
      ),
      child: Stack(
        children: [
          // Portion active (du centre vers la position du gardien)
          Positioned(
            left: _goalkeeperPosition < 0.5
                ? goalkeeperX
                : trackWidth * 0.5,
            width: (_goalkeeperPosition - 0.5).abs() * trackWidth,
            top: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: zoneColor.withOpacity(0.7),
              ),
            ),
          ),
          // Marqueur centre
          Positioned(
            left: trackWidth * 0.5 - 2,
            top: -2,
            child: Container(
              width: 4,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneMarkers(double trackWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _zoneMarker('G', const Color(0xFF2196F3)),
        _zoneMarker('C', const Color(0xFF4CAF50)),
        _zoneMarker('D', const Color(0xFF2196F3)),
      ],
    );
  }

  Widget _zoneMarker(String label, Color color) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.25),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildGoalkeeperIcon(double size, Color zoneColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            zoneColor.withOpacity(0.35),
            zoneColor.withOpacity(0.08),
          ],
        ),
        border: Border.all(
          color: _isDragging ? zoneColor : Colors.white.withOpacity(0.4),
          width: _isDragging ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: zoneColor.withOpacity(_isDragging ? 0.5 : 0.2),
            blurRadius: _isDragging ? 18 : 8,
            spreadRadius: _isDragging ? 3 : 1,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/players/goalkeeper.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildDirectionIndicator() {
    final direction = _positionToDirection(_goalkeeperPosition);
    final dist = (_goalkeeperPosition - 0.5).abs();

    String label;
    IconData icon;
    Color color;

    if (direction == ShotDirection.left) {
      label = dist > 0.3 ? 'PLONGEON GAUCHE' : 'LÉGÈREMENT GAUCHE';
      icon = Icons.arrow_back_rounded;
      color = const Color(0xFF2196F3);
    } else if (direction == ShotDirection.right) {
      label = dist > 0.3 ? 'PLONGEON DROITE' : 'LÉGÈREMENT DROITE';
      icon = Icons.arrow_forward_rounded;
      color = const Color(0xFF2196F3);
    } else {
      label = 'CENTRE';
      icon = Icons.arrow_upward_rounded;
      color = const Color(0xFF4CAF50);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            _diveSent ? 'PLONGÉE !' : label,
            style: TextStyle(
              color: _diveSent ? Colors.white : color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Peintre pour la traînée de glissement ─────────────────────────────────────
class _DragTrailPainter extends CustomPainter {
  final double position;   // 0.0 → 1.0
  final double trackWidth;
  final Color color;

  _DragTrailPainter({
    required this.position,
    required this.trackWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = trackWidth * 0.5;
    final goalkeeperX = trackWidth * position;

    if ((goalkeeperX - centerX).abs() < 4) return;

    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Quelques traînées décalées pour l'effet de mouvement
    for (int i = 1; i <= 3; i++) {
      final opacity = (1.0 - i * 0.25).clamp(0.0, 1.0);
      final offset = (goalkeeperX > centerX ? -i : i) * 6.0;
      paint.color = color.withOpacity(opacity * 0.25);

      canvas.drawLine(
        Offset(goalkeeperX + offset, 25),
        Offset(goalkeeperX + offset + (goalkeeperX > centerX ? -20 : 20), 25),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DragTrailPainter old) =>
      old.position != position || old.color != color;
}
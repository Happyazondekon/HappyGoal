import 'package:happygoal/l10n/app_localizations.dart';
// lib/widgets/swipe_shot_widget.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:happygoal/models/game_state.dart';
import 'package:happygoal/l10n/app_localizations.dart';


/// Callback appelé quand l'utilisateur a terminé son swipe.
/// [direction] : ShotDirection.left / center / right
/// [power]     : 0 à 100
/// [effect]    : ShotEffect.normal / curve / lob / knuckle
typedef OnSwipeShoot = void Function(int direction, int power, String effect);

class SwipeShotWidget extends StatefulWidget {
  final OnSwipeShoot onShoot;

  const SwipeShotWidget({Key? key, required this.onShoot}) : super(key: key);

  @override
  State<SwipeShotWidget> createState() => _SwipeShotWidgetState();
}

class _SwipeShotWidgetState extends State<SwipeShotWidget>
    with TickerProviderStateMixin {
  // ── Swipe state ──────────────────────────────────────────────────────────
  Offset? _startPos;
  Offset? _currentPos;
  bool _isSwiping = false;
  bool _shotFired = false;

  // ── Effect selector ──────────────────────────────────────────────────────
  String _selectedEffect = ShotEffect.normal;

  // ── Animation pour le pulse du joueur ───────────────────────────────────
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // ── Animation pour le feedback au tir ───────────────────────────────────
  late AnimationController _fireController;
  late Animation<double> _fireAnim;

  // ── Animation de hint (flèche qui monte) ────────────────────────────────
  late AnimationController _hintController;
  late Animation<double> _hintAnim;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fireController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fireAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fireController, curve: Curves.easeOut),
    );

    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _hintAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hintController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fireController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  // ── Calcul de la puissance (vitesse du swipe) ────────────────────────────
  int _calculatePower(Offset start, Offset end) {
    final distance = (end - start).distance;
    // Max distance considérée : 280 pixels
    final power = ((distance / 280.0) * 100).clamp(5.0, 100.0).toInt();
    return power;
  }

  // ── Calcul de la direction ───────────────────────────────────────────────
  int _calculateDirection(Offset start, Offset end) {
    final dx = end.dx - start.dx;
    // Zone morte centrale : ±40px
    if (dx.abs() < 40) return ShotDirection.center;
    return dx < 0 ? ShotDirection.left : ShotDirection.right;
  }

  // ── Couleur de la trajectoire selon la puissance ─────────────────────────
  Color _powerColor(int power) {
    if (power < 35) return const Color(0xFF4CAF50); // vert
    if (power < 65) return const Color(0xFFFFD600); // jaune
    if (power < 85) return const Color(0xFFFF9800); // orange
    return const Color(0xFFE53935);                 // rouge
  }

  // ── Icône de l'effet ─────────────────────────────────────────────────────
  IconData _effectIcon(String effect) {
    switch (effect) {
      case ShotEffect.curve:   return Icons.rotate_right;
      case ShotEffect.lob:     return Icons.arrow_upward;
      case ShotEffect.knuckle: return Icons.bolt;
      default:                 return Icons.sports_soccer;
    }
  }

  String _effectLabel(String effect) {
    switch (effect) {
      case ShotEffect.curve:
        return AppLocalizations.of(context)!.swipeShotEffectCurve;
      case ShotEffect.lob:
        return AppLocalizations.of(context)!.swipeShotEffectLob;
      case ShotEffect.knuckle:
        return AppLocalizations.of(context)!.swipeShotEffectKnuckle;
      default:
        return AppLocalizations.of(context)!.swipeShotEffectNormal;
    }
  }

  Color _effectColor(String effect) {
    switch (effect) {
      case ShotEffect.curve:   return const Color(0xFF2196F3);
      case ShotEffect.lob:     return const Color(0xFF9C27B0);
      case ShotEffect.knuckle: return const Color(0xFFFFD600);
      default:                 return const Color(0xFF4CAF50);
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (_shotFired) return;
    setState(() {
      _startPos = details.localPosition;
      _currentPos = details.localPosition;
      _isSwiping = true;
    });
    _pulseController.stop();
    _hintController.stop();
    HapticFeedback.lightImpact();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isSwiping || _shotFired) return;
    setState(() {
      _currentPos = details.localPosition;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isSwiping || _shotFired || _startPos == null || _currentPos == null) return;

    final start = _startPos!;
    final end = _currentPos!;
    final dy = end.dy - start.dy;

    // Le swipe doit aller vers le HAUT (dy négatif) d'au moins 40px
    if (dy > -40) {
      // Swipe trop court ou mauvaise direction → annuler
      setState(() {
        _isSwiping = false;
        _startPos = null;
        _currentPos = null;
      });
      _pulseController.repeat(reverse: true);
      _hintController.repeat(reverse: true);
      return;
    }

    final power = _calculatePower(start, end);
    final direction = _calculateDirection(start, end);

    // Feedback haptique selon la puissance
    if (power > 75) {
      HapticFeedback.heavyImpact();
    } else if (power > 40) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }

    setState(() {
      _shotFired = true;
    });

    _fireController.forward().then((_) {
      widget.onShoot(direction, power, _selectedEffect);
      // Reset après un délai
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isSwiping = false;
            _startPos = null;
            _currentPos = null;
            _shotFired = false;
          });
          _fireController.reset();
          _pulseController.repeat(reverse: true);
          _hintController.repeat(reverse: true);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Sélecteur d'effet ──────────────────────────────────────────────
        _buildEffectSelector(screenWidth),
        const SizedBox(height: 12),
        // ── Zone de swipe ──────────────────────────────────────────────────
        _buildSwipeZone(screenWidth),
      ],
    );
  }

  Widget _buildEffectSelector(double screenWidth) {
    final effects = [
      ShotEffect.normal,
      ShotEffect.curve,
      ShotEffect.lob,
      ShotEffect.knuckle,
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: effects.map((effect) {
          final isSelected = _selectedEffect == effect;
          final color = _effectColor(effect);
          return GestureDetector(
            onTap: () {
              if (!_isSwiping) {
                setState(() => _selectedEffect = effect);
                HapticFeedback.selectionClick();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 16 : 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.9) : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _effectIcon(effect),
                    size: 16,
                    color: isSelected ? Colors.white : Colors.white54,
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 5),
                    Text(
                      _effectLabel(effect),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSwipeZone(double screenWidth) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: SizedBox(
        width: screenWidth,
        height: 140,
        child: CustomPaint(
          painter: _SwipeTrailPainter(
            startPos: _startPos,
            currentPos: _currentPos,
            isSwiping: _isSwiping,
            shotFired: _shotFired,
            fireProgress: _fireAnim,
            selectedEffect: _selectedEffect,
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // ── Hint arrows ──────────────────────────────────────────────
              if (!_isSwiping && !_shotFired)
                AnimatedBuilder(
                  animation: _hintAnim,
                  builder: (_, __) => _buildHintArrows(),
                ),

              // ── Joueur avec zone de tir ──────────────────────────────────
              Positioned(
                bottom: 8,
                child: _buildPlayerZone(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHintArrows() {
    return Positioned(
      bottom: 55,
      child: Column(
        children: List.generate(3, (i) {
          final opacity = (((_hintAnim.value - i * 0.25) % 1.0).clamp(0.0, 1.0));
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Opacity(
              opacity: opacity * 0.7,
              child: const Icon(
                Icons.keyboard_arrow_up_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPlayerZone() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, child) {
        return Transform.scale(
          scale: _isSwiping ? 0.95 : _pulseAnim.value,
          child: child,
        );
      },
      child: Column(
        children: [
          // Label indicatif
          if (!_isSwiping && !_shotFired)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Text(
                AppLocalizations.of(context)!.swipeShotHint,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),

          // Zone de départ du swipe
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _effectColor(_selectedEffect).withOpacity(0.4),
                  _effectColor(_selectedEffect).withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
              border: Border.all(
                color: _isSwiping
                    ? _effectColor(_selectedEffect)
                    : Colors.white.withOpacity(0.3),
                width: _isSwiping ? 2 : 1,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.sports_soccer,
                color: _isSwiping
                    ? _effectColor(_selectedEffect)
                    : Colors.white.withOpacity(0.8),
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom Painter pour la trajectoire du swipe ───────────────────────────────
class _SwipeTrailPainter extends CustomPainter {
  final Offset? startPos;
  final Offset? currentPos;
  final bool isSwiping;
  final bool shotFired;
  final Animation<double> fireProgress;
  final String selectedEffect;

  _SwipeTrailPainter({
    required this.startPos,
    required this.currentPos,
    required this.isSwiping,
    required this.shotFired,
    required this.fireProgress,
    required this.selectedEffect,
  }) : super(repaint: fireProgress);

  Color get _effectColor {
    switch (selectedEffect) {
      case ShotEffect.curve:   return const Color(0xFF2196F3);
      case ShotEffect.lob:     return const Color(0xFF9C27B0);
      case ShotEffect.knuckle: return const Color(0xFFFFD600);
      default:                 return const Color(0xFF4CAF50);
    }
  }

  Color _powerColor(double distance) {
    final ratio = (distance / 280.0).clamp(0.0, 1.0);
    if (ratio < 0.35) return const Color(0xFF4CAF50);
    if (ratio < 0.65) return const Color(0xFFFFD600);
    if (ratio < 0.85) return const Color(0xFFFF9800);
    return const Color(0xFFE53935);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (startPos == null || currentPos == null) return;

    final start = startPos!;
    final current = currentPos!;
    final distance = (current - start).distance;
    final dy = current.dy - start.dy;

    // Seulement si le swipe va vers le haut
    if (dy > 0 && !shotFired) return;

    final color = shotFired ? _effectColor : _powerColor(distance);
    final opacity = shotFired ? fireProgress.value : 1.0;

    // ── Trajectoire principale ────────────────────────────────────────────
    final trailPaint = Paint()
      ..color = color.withOpacity(0.85 * opacity)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Point de contrôle pour courbe de Bézier
    final controlPoint = Offset(
      (start.dx + current.dx) / 2 + (current.dx - start.dx) * 0.2,
      start.dy - distance * 0.3,
    );

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        current.dx,
        current.dy,
      );

    // Ombre de la trajectoire
    final shadowPaint = Paint()
      ..color = color.withOpacity(0.25 * opacity)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, trailPaint);

    // ── Pointillés d'énergie le long de la trajectoire ───────────────────
    _drawEnergyDots(canvas, path, color, opacity);

    // ── Indicateur de puissance en bout de swipe ──────────────────────────
    if (!shotFired) {
      _drawPowerIndicator(canvas, current, distance, color);
    }

    // ── Indicateur de direction ───────────────────────────────────────────
    if (!shotFired && dy < -40) {
      _drawDirectionArrow(canvas, current, color, opacity);
    }
  }

  void _drawEnergyDots(Canvas canvas, Path path, Color color, double opacity) {
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      final total = metric.length;
      if (total < 20) return;

      final dotCount = (total / 18).floor();
      for (int i = 1; i <= dotCount; i++) {
        final t = i / (dotCount + 1);
        final tangent = metric.getTangentForOffset(total * t);
        if (tangent == null) continue;

        final dotOpacity = (1.0 - (1.0 - t) * 0.6) * opacity;
        final dotSize = 3.0 + t * 2.5;

        final dotPaint = Paint()
          ..color = color.withOpacity(dotOpacity * 0.7)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(tangent.position, dotSize, dotPaint);
      }
    }
  }

  void _drawPowerIndicator(Canvas canvas, Offset pos, double distance, Color color) {
    final power = ((distance / 280.0) * 100).clamp(5.0, 100.0).toInt();

    final bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.65)
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(pos.dx, pos.dy - 22),
        width: 64,
        height: 22,
      ),
      const Radius.circular(11),
    );
    canvas.drawRRect(rrect, bgPaint);

    // Barre de puissance
    final barWidth = 48.0;
    final barFill = barWidth * (power / 100.0);

    final barBgPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx - barWidth / 2, pos.dy - 30, barWidth, 6),
        const Radius.circular(3),
      ),
      barBgPaint,
    );

    final barPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx - barWidth / 2, pos.dy - 30, barFill, 6),
        const Radius.circular(3),
      ),
      barPaint,
    );

    // Texte puissance
    final tp = TextPainter(
      text: TextSpan(
        text: '$power%',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - 21));
  }

  void _drawDirectionArrow(Canvas canvas, Offset pos, Color color, double opacity) {
    final arrowPaint = Paint()
      ..color = color.withOpacity(0.9 * opacity)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Petite flèche au bout de la trajectoire
    const arrowSize = 12.0;
    canvas.drawLine(
      Offset(pos.dx - arrowSize, pos.dy + arrowSize),
      pos,
      arrowPaint,
    );
    canvas.drawLine(
      Offset(pos.dx + arrowSize, pos.dy + arrowSize),
      pos,
      arrowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SwipeTrailPainter old) =>
      old.startPos != startPos ||
          old.currentPos != currentPos ||
          old.isSwiping != isSwiping ||
          old.shotFired != shotFired ||
          old.selectedEffect != selectedEffect;
}
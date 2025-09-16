import 'dart:ui';
import 'package:flutter/material.dart';

// Classe pour définir chaque étape du tutoriel
class TutorialStep {
  final String title;
  final String description;
  final GlobalKey targetKey;
  final TutorialPosition position;
  final Widget? customContent;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final bool showSkip;

  TutorialStep({
    required this.title,
    required this.description,
    required this.targetKey,
    this.position = TutorialPosition.bottom,
    this.customContent,
    this.onNext,
    this.onPrevious,
    this.showSkip = true,
  });
}

// Position de l'infobulle par rapport à l'élément ciblé
enum TutorialPosition {
  top,
  bottom,
  left,
  right,
  center,
}

// Widget principal de l'overlay de tutoriel
class TutorialOverlay extends StatefulWidget {
  final List<TutorialStep> steps;
  final VoidCallback onComplete;
  final VoidCallback? onSkip;
  final Color backgroundColor;
  final Color highlightColor;
  final Duration animationDuration;

  const TutorialOverlay({
    Key? key,
    required this.steps,
    required this.onComplete,
    this.onSkip,
    this.backgroundColor = Colors.black54,
    this.highlightColor = Colors.white,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> with TickerProviderStateMixin {
  int currentStepIndex = 0;
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  Offset _tooltipPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetTooltipPosition();
    });
  }

  @override
  void didUpdateWidget(TutorialOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.steps.length > currentStepIndex && oldWidget.steps[currentStepIndex].targetKey != widget.steps[currentStepIndex].targetKey) {
      _resetTooltipPosition();
    }
  }

  void _resetTooltipPosition() {
    final currentStep = widget.steps[currentStepIndex];
    final targetRect = _getTargetRect(currentStep.targetKey);
    final screenSize = MediaQuery.of(context).size;

    if (targetRect == null) return;

    double tooltipX = 0;
    double tooltipY = 0;
    final tooltipWidth = screenSize.width * 0.85;
    final tooltipHeightEstimate = 200.0;
    final tooltipPadding = 20.0;

    // Positionnement par défaut
    bool isTopPositioning = targetRect.top > screenSize.height / 2;
    if (currentStep.position == TutorialPosition.bottom) {
      isTopPositioning = false;
    } else if (currentStep.position == TutorialPosition.top) {
      isTopPositioning = true;
    }

    if (isTopPositioning) {
      tooltipY = targetRect.top - tooltipHeightEstimate - tooltipPadding;
    } else {
      tooltipY = targetRect.bottom + tooltipPadding;
    }

    tooltipX = targetRect.center.dx - tooltipWidth / 2;

    tooltipX = tooltipX.clamp(10.0, screenSize.width - tooltipWidth - 10);
    tooltipY = tooltipY.clamp(
        50.0, screenSize.height - tooltipHeightEstimate - 50);

    setState(() {
      _tooltipPosition = Offset(tooltipX, tooltipY);
    });
  }


  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (currentStepIndex < widget.steps.length - 1) {
      _animationController.reverse().then((_) {
        setState(() {
          currentStepIndex++;
          _resetTooltipPosition();
        });
        _animationController.forward();
      });
      widget.steps[currentStepIndex].onNext?.call();
    } else {
      _complete();
    }
  }

  void _previousStep() {
    if (currentStepIndex > 0) {
      _animationController.reverse().then((_) {
        setState(() {
          currentStepIndex--;
          _resetTooltipPosition();
        });
        _animationController.forward();
      });
      widget.steps[currentStepIndex].onPrevious?.call();
    }
  }

  void _complete() {
    _animationController.reverse().then((_) {
      widget.onComplete();
    });
  }

  void _skip() {
    _animationController.reverse().then((_) {
      widget.onSkip?.call();
      widget.onComplete();
    });
  }

  Rect? _getTargetRect(GlobalKey key) {
    final RenderObject? renderObject = key.currentContext?.findRenderObject();
    if (renderObject is RenderBox) {
      final offset = renderObject.localToGlobal(Offset.zero);
      return Rect.fromLTWH(
        offset.dx,
        offset.dy,
        renderObject.size.width,
        renderObject.size.height,
      );
    }
    return null;
  }

  Widget _buildTooltip(TutorialStep step, Size screenSize) {
    return Positioned(
      left: _tooltipPosition.dx,
      top: _tooltipPosition.dy,
      child: Draggable(
        feedback: _tooltipContent(step, screenSize, isDragging: true),
        childWhenDragging: Container(),
        onDragEnd: (details) {
          setState(() {
            _tooltipPosition = details.offset;
          });
        },
        child: _tooltipContent(step, screenSize),
      ),
    );
  }

  Widget _tooltipContent(TutorialStep step, Size screenSize, {bool isDragging = false}) {
    final tooltipWidth = screenSize.width * 0.85;
    final tooltipMinHeight = 150.0;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: isDragging ? 0.7 : 1.0,
            child: Container(
              width: tooltipWidth,
              constraints: BoxConstraints(minHeight: tooltipMinHeight),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2E8B4B),
                    Color(0xFF1B6B3A),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            step.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        if (step.showSkip)
                          TextButton(
                            onPressed: _skip,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            child: const Text(
                              'Passer',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white70,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (step.customContent != null)
                      step.customContent!
                    else
                      Text(
                        step.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: List.generate(
                            widget.steps.length,
                                (index) => Container(
                              margin: const EdgeInsets.only(right: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index == currentStepIndex
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            if (currentStepIndex > 0)
                              ElevatedButton(
                                onPressed: _previousStep,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.15),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.all(12),
                                  shape: const CircleBorder(),
                                ),
                                child: const Icon(Icons.arrow_back_ios_new_rounded),
                              ),
                            const SizedBox(width: 8),
                            if (currentStepIndex < widget.steps.length - 1)
                              ElevatedButton(
                                onPressed: _nextStep,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.15),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.all(12),
                                  shape: const CircleBorder(),
                                ),
                                child: Transform.rotate(
                                  angle: 3.14,
                                  child: const Icon(Icons.arrow_back_ios_new_rounded),
                                ),
                              )
                            else
                              ElevatedButton.icon(
                                onPressed: _complete,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D4A2D),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                icon: const Icon(Icons.done_all_rounded, size: 20),
                                label: const Text('Terminer'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = widget.steps[currentStepIndex];
    final targetRect = _getTargetRect(currentStep.targetKey);
    final screenSize = MediaQuery.of(context).size;

    if (targetRect == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                // Overlay sombre avec découpe
                CustomPaint(
                  size: screenSize,
                  painter: TutorialOverlayPainter(
                    targetRect: targetRect,
                    backgroundColor: widget.backgroundColor,
                  ),
                ),

                // Effet de pulsation sur l'élément ciblé
                Positioned(
                  // Utilisation d'un décalage calculé dynamiquement
                  left: targetRect.left - 5,
                  top: targetRect.top - 55,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: targetRect.width + 10,
                          height: targetRect.height + 10,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 2.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Tooltip flottant
                _buildTooltip(currentStep, screenSize),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TutorialOverlayPainter extends CustomPainter {
  final Rect targetRect;
  final Color backgroundColor;

  TutorialOverlayPainter({
    required this.targetRect,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = backgroundColor;
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(
          targetRect.left - 5,              // comme ton Positioned
          targetRect.top - 55,              // comme ton Positioned
          targetRect.width + 10,            // comme ton Container
          targetRect.height + 10,           // comme ton Container
        ),
        const Radius.circular(8),
      ))

      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
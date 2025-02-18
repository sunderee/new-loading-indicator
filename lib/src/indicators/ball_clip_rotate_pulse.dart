import 'dart:math';

import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays a rotating ring with a pulsing circle at its center.
///
/// This indicator combines two animated elements:
/// 1. An outer ring that rotates while scaling up and down
/// 2. A central circle that pulses in size
///
/// The animation uses a custom cubic curve for smooth, natural motion and consists of:
/// - Outer ring: Full 360° rotation while scaling between 100% and 60%
/// - Inner circle: Pulsing between 100% and 30% with asymmetric timing (30% shrink, 70% expand)
final class BallClipRotatePulse extends StatefulWidget {
  /// Creates a ball clip rotate pulse loading indicator.
  const BallClipRotatePulse({super.key});

  @override
  State<BallClipRotatePulse> createState() => _BallClipRotatePulseState();
}

final class _BallClipRotatePulseState extends State<BallClipRotatePulse>
    with SingleTickerProviderStateMixin, IndicatorController {
  /// The main animation controller that drives all animations.
  late AnimationController _animationController;

  /// Animation for scaling the outer ring (1.0 -> 0.6 -> 1.0).
  late Animation<double> _outCircleScale;

  /// Animation for rotating the outer ring (0 -> π -> 2π).
  late Animation<double> _outCircleRotate;

  /// Animation for scaling the inner circle (1.0 -> 0.3 -> 1.0).
  late Animation<double> _innerCircle;

  @override
  List<AnimationController> get animationControllers => [_animationController];

  @override
  void initState() {
    super.initState();
    // Custom cubic curve for smooth animation
    const cubic = Cubic(0.09, 0.57, 0.49, 0.9);

    // Initialize the main animation controller with 1-second duration
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Create outer ring scale animation
    _outCircleScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _animationController, curve: cubic));

    // Create outer ring rotation animation
    _outCircleRotate = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: pi), weight: 1),
      TweenSequenceItem(tween: Tween(begin: pi, end: 2 * pi), weight: 1),
    ]).animate(CurvedAnimation(parent: _animationController, curve: cubic));

    // Create inner circle scale animation with asymmetric timing
    _innerCircle = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 70),
    ]).animate(CurvedAnimation(parent: _animationController, curve: cubic));

    // Start the repeating animation
    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder:
          (_, child) => Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: <Widget>[
              // Outer rotating ring
              Transform(
                alignment: Alignment.center,
                transform:
                    Matrix4.identity()
                      ..scale(_outCircleScale.value)
                      ..rotateZ(_outCircleRotate.value),
                child: const IndicatorShapeWidget(
                  shape: Shape.ringTwoHalfVertical,
                  index: 0,
                ),
              ),
              // Inner pulsing circle
              Transform.scale(
                scale: _innerCircle.value * 0.3,
                child: const IndicatorShapeWidget(
                  shape: Shape.circle,
                  index: 1,
                ),
              ),
            ],
          ),
    );
  }
}

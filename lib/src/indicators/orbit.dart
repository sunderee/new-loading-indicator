import 'dart:math';

import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays a dynamic orbital system with expanding rings and a satellite.
///
/// The animation consists of several synchronized components:
/// - A core circle that pulses in size
/// - Two concentric rings that expand outward while fading
/// - A satellite circle that orbits around the core
///
/// The animation creates a space-like effect with the following timing details:
/// - Core: Pulses between 100% and 130% size over 1.9 seconds
/// - Ring 1: Expands from 0% to 200% size while fading out (starts at 450ms)
/// - Ring 2: Expands from 0% to 210% size while fading out (starts at 550ms)
/// - Satellite: Completes one full orbit every 1.9 seconds
///
/// The animation runs continuously until the widget is disposed, creating a
/// mesmerizing effect that combines orbital motion with pulsing and expansion.
class Orbit extends StatefulWidget {
  /// Creates an Orbit loading indicator.
  const Orbit({super.key});

  @override
  State<Orbit> createState() => _OrbitState();
}

/// The state for the [Orbit] widget.
///
/// This state manages the animation controller and animations for all components
/// of the orbital system. It uses a combination of scale, opacity, and rotation
/// animations to create the space-like effect:
///
/// - Core Animation: Uses a sequence to pulse the central circle
/// - Ring Animations: Combine scale and opacity for expanding fade effect
/// - Satellite Animation: Uses trigonometric functions for circular orbit
class _OrbitState extends State<Orbit>
    with SingleTickerProviderStateMixin, IndicatorController {
  late AnimationController _animationController;
  late Animation<double> _ring1ScaleAnimation;
  late Animation<double> _ring1OpacityAnimation;
  late Animation<double> _ring2ScaleAnimation;
  late Animation<double> _ring2OpacityAnimation;
  late Animation<double> _coreAnimation;
  late Animation<double> _satelliteAnimation;

  @override
  List<AnimationController> get animationControllers => [_animationController];

  @override
  void initState() {
    super.initState();
    //    final cubic = Cubic(0.19, 1.0, 0.22, 1.0);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );

    // Ring 1 animations - starts at 450ms, expands to 200% while fading
    _ring1ScaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 0.01),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 2.0), weight: 100),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.45, 1.0, curve: Curves.linear),
      ),
    );
    _ring1OpacityAnimation = Tween(begin: 0.8, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.45, 1.0, curve: Curves.linear),
      ),
    );

    // Ring 2 animations - starts at 550ms, expands to 210% while fading
    _ring2ScaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 0.01),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 2.1), weight: 100),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.55, 1.0, curve: Curves.linear),
      ),
    );
    _ring2OpacityAnimation = Tween(begin: 0.70, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.55, 0.65, curve: Curves.linear),
      ),
    );

    // Core animation - pulses between 100% and 130% size
    _coreAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.3), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 45),
    ]).animate(_animationController);

    // Satellite animation - completes one full orbit
    _satelliteAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: pi), weight: 1),
      TweenSequenceItem(tween: Tween(begin: pi, end: 2 * pi), weight: 1),
    ]).animate(_animationController);

    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraint) {
        const satelliteRatio = 0.25;
        const distanceRatio = 1.5;
        final coreSize =
            constraint.maxWidth / (1 + satelliteRatio + distanceRatio);
        final satelliteSize = constraint.maxWidth * satelliteRatio / 2;
        final center = Offset(
          constraint.maxWidth / 2,
          constraint.maxHeight / 2,
        );
        final deltaX = center.dx - satelliteSize / 2;
        final deltaY = center.dy - satelliteSize / 2;

        return Stack(
          children: <Widget>[
            Positioned.fromRect(
              rect: Rect.fromCircle(center: center, radius: coreSize / 2),
              child: ScaleTransition(
                scale: _coreAnimation,
                child: const IndicatorShapeWidget(
                  shape: Shape.circle,
                  index: 0,
                ),
              ),
            ),
            Positioned.fromRect(
              rect: Rect.fromCircle(center: center, radius: coreSize / 2),
              child: FadeTransition(
                opacity: _ring1OpacityAnimation,
                child: ScaleTransition(
                  scale: _ring1ScaleAnimation,
                  child: const IndicatorShapeWidget(
                    shape: Shape.circle,
                    index: 1,
                  ),
                ),
              ),
            ),
            Positioned.fromRect(
              rect: Rect.fromCircle(center: center, radius: coreSize / 2),
              child: FadeTransition(
                opacity: _ring2OpacityAnimation,
                child: ScaleTransition(
                  scale: _ring2ScaleAnimation,
                  child: const IndicatorShapeWidget(
                    shape: Shape.circle,
                    index: 2,
                  ),
                ),
              ),
            ),
            Positioned.fromRect(
              rect: Rect.fromLTWH(
                center.dx - satelliteSize / 2,
                center.dy - satelliteSize / 2,
                satelliteSize,
                satelliteSize,
              ),
              child: AnimatedBuilder(
                animation: _satelliteAnimation,
                builder: (_, child) {
                  return Transform.translate(
                    offset: Offset(
                      sin(_satelliteAnimation.value) * deltaX,
                      -cos(_satelliteAnimation.value) * deltaY,
                    ),
                    child: const IndicatorShapeWidget(
                      shape: Shape.circle,
                      index: 3,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays five circles rotating in a chasing pattern.
///
/// The animation consists of five circles that rotate around a central point while
/// scaling in size. Each circle follows a circular path with a slightly different
/// phase and scale animation, creating a smooth chasing effect.
///
/// The circles are positioned using trigonometric functions to create the circular
/// motion, and each circle's animation is controlled by a custom cubic curve for
/// a more dynamic effect. The animation runs continuously until the widget is disposed.
class BallRotateChase extends StatefulWidget {
  /// Creates a BallRotateChase loading indicator.
  const BallRotateChase({super.key});

  @override
  State<BallRotateChase> createState() => _BallRotateChaseState();
}

/// The state for the [BallRotateChase] widget.
///
/// This state manages the animation controller and animations for the five
/// rotating circles. Each circle has its own scale and translation animations
/// with specific delays and curves to create the chasing effect.
class _BallRotateChaseState extends State<BallRotateChase>
    with SingleTickerProviderStateMixin, IndicatorController {
  /// Total duration of one complete animation cycle in milliseconds.
  static const _durationInMills = 1500;

  /// Number of balls in the animation.
  static const _ballNum = 5;

  /// The main animation controller that drives all circle animations.
  late AnimationController _animationController;

  /// List of animations that control the scale of each circle.
  final List<Animation<double>> _scaleAnimations = [];

  /// List of animations that control the rotation angle of each circle.
  final List<Animation<double>> _translateAnimations = [];

  @override
  List<AnimationController> get animationControllers => [_animationController];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _durationInMills),
    );
    for (int i = 0; i < _ballNum; i++) {
      final rate = i / 5;
      // Custom cubic curve for each circle with a phase offset
      final cubic = Cubic(0.5, 0.15 + rate, 0.25, 1.0);

      // Scale animation that varies based on the circle's position
      _scaleAnimations.add(
        Tween(
          begin: 1 - rate,
          end: 0.2 + rate,
        ).animate(CurvedAnimation(parent: _animationController, curve: cubic)),
      );

      // Rotation animation from 0 to 2π (full circle)
      _translateAnimations.add(
        Tween(
          begin: 0.0,
          end: 2 * pi,
        ).animate(CurvedAnimation(parent: _animationController, curve: cubic)),
      );

      _animationController.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraint) {
        final circleSize = constraint.maxWidth / 5;

        // Calculate the radius of the circular path
        final deltaX = (constraint.maxWidth - circleSize) / 2;
        final deltaY = (constraint.maxHeight - circleSize) / 2;

        final widgets = List<Widget>.filled(_ballNum, Container());
        for (int i = 0; i < _ballNum; i++) {
          widgets[i] = Positioned.fromRect(
            rect: Rect.fromLTWH(deltaX, deltaY, circleSize, circleSize),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (_, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform:
                      Matrix4.identity()..translate(
                        // Calculate x and y positions using trigonometric functions
                        deltaX * sin(_translateAnimations[i].value),
                        deltaY * -cos(_translateAnimations[i].value),
                      ),
                  // Scale must be in child to maintain proper alignment
                  child: ScaleTransition(
                    scale: _scaleAnimations[i],
                    child: child,
                  ),
                );
              },
              child: IndicatorShapeWidget(shape: Shape.circle, index: i),
            ),
          );
        }
        return Stack(children: widgets);
      },
    );
  }
}

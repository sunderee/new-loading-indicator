import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays a 3x3 grid of circles with independent pulsing animations.
///
/// This indicator shows nine circles arranged in a grid, where each circle independently
/// scales and fades with different timings. The animation creates a dynamic pulsing effect
/// with each circle having its own unique timing and duration.
///
/// The animation consists of:
/// - Scale: Each circle scales between 100% and 50% size
/// - Opacity: Each circle fades between 100% and 70% opacity
/// - Timing: Each circle has a unique duration (720ms to 1450ms) and delay (30ms to 1110ms)
/// - Layout: Circles are arranged in a 3x3 grid with small spacing
///
/// The varying timings and separate scale/opacity animations create a complex,
/// organic pulsing pattern that makes the loading state visually interesting.
final class BallGridPulse extends StatefulWidget {
  /// Creates a ball grid pulse loading indicator.
  const BallGridPulse({super.key});

  @override
  State<BallGridPulse> createState() => _BallGridPulseState();
}

final class _BallGridPulseState extends State<BallGridPulse>
    with TickerProviderStateMixin, IndicatorController {
  /// The total number of circles in the grid (3x3).
  static const _ballNum = 9;

  /// Animation durations for each circle in milliseconds.
  ///
  /// Each circle has a unique duration to create an organic pulsing effect:
  /// - Row 1: 720ms, 1020ms, 1280ms
  /// - Row 2: 1420ms, 1450ms, 1180ms
  /// - Row 3: 870ms, 1450ms, 1060ms
  static const _durationInMills = [
    720, // Top-left
    1020, // Top-center
    1280, // Top-right
    1420, // Middle-left
    1450, // Center
    1180, // Middle-right
    870, // Bottom-left
    1450, // Bottom-center
    1060, // Bottom-right
  ];

  /// Initial delays for each circle's animation in milliseconds.
  ///
  /// Each circle starts at a different time to create a wave-like effect:
  /// - Row 1: 660ms, 250ms, 1110ms
  /// - Row 2: 480ms, 310ms, 30ms
  /// - Row 3: 460ms, 480ms, 450ms
  static const _delayInMills = [
    660, // Top-left
    250, // Top-center
    1110, // Top-right
    480, // Middle-left
    310, // Center
    30, // Middle-right
    460, // Bottom-left
    480, // Bottom-center
    450, // Bottom-right
  ];

  /// Controllers for each circle's animation.
  final List<AnimationController> _animationControllers = [];

  /// Scale animations for each circle (1.0 -> 0.5 -> 1.0).
  final List<Animation<double>> _scaleAnimations = [];

  /// Opacity animations for each circle (1.0 -> 0.7 -> 1.0).
  final List<Animation<double>> _opacityAnimations = [];

  @override
  List<AnimationController> get animationControllers => _animationControllers;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _ballNum; i++) {
      final duration = _durationInMills[i];
      final delay = _delayInMills[i];

      // Create controller with initial value set to simulate delay
      _animationControllers.add(
        AnimationController(
          value: delay / duration,
          vsync: this,
          duration: Duration(milliseconds: duration),
        ),
      );

      // Create scale animation (50% reduction)
      _scaleAnimations.add(
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 1),
        ]).animate(
          CurvedAnimation(
            parent: _animationControllers[i],
            curve: Curves.linear,
          ),
        ),
      );

      // Create opacity animation (30% reduction)
      _opacityAnimations.add(
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.7), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.7, end: 1.0), weight: 1),
        ]).animate(
          CurvedAnimation(
            parent: _animationControllers[i],
            curve: Curves.linear,
          ),
        ),
      );

      // Start repeating animation
      _animationControllers[i].repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create list of animated circles
    final widgets = List<Widget>.filled(_ballNum, Container());
    for (int i = 0; i < _ballNum; i++) {
      widgets[i] = ScaleTransition(
        alignment: Alignment.center,
        scale: _scaleAnimations[i],
        child: FadeTransition(
          opacity: _opacityAnimations[i],
          child: IndicatorShapeWidget(shape: Shape.circle, index: i),
        ),
      );
    }

    // Arrange circles in a 3x3 grid
    return GridView.count(
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      crossAxisCount: 3,
      children: widgets,
    );
  }
}

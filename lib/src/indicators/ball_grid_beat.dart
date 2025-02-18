import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays a 3x3 grid of circles that pulse with different timings.
///
/// This indicator shows nine circles arranged in a grid, where each circle independently
/// scales and fades in a repeating pattern. The animation creates a visually appealing
/// "beating" effect with each circle having its own unique timing.
///
/// The animation consists of:
/// - Scale: Each circle scales between 100% and 70% size
/// - Opacity: Each circle fades in sync with its scaling
/// - Timing: Each circle has a unique duration (820ms to 1340ms) and delay (100ms to 1080ms)
/// - Layout: Circles are arranged in a 3x3 grid with small spacing
///
/// The varying timings create an organic, wave-like visual effect that makes the
/// loading state feel dynamic and engaging.
final class BallGridBeat extends StatefulWidget {
  /// Creates a ball grid beat loading indicator.
  const BallGridBeat({super.key});

  @override
  State<BallGridBeat> createState() => _BallGridBeatState();
}

final class _BallGridBeatState extends State<BallGridBeat>
    with TickerProviderStateMixin, IndicatorController {
  /// The total number of circles in the grid (3x3).
  static const _ballNum = 9;

  /// Animation durations for each circle in milliseconds.
  ///
  /// Each circle has a unique duration to create an organic beating effect:
  /// - Row 1: 960ms, 930ms, 1190ms
  /// - Row 2: 1130ms, 1340ms, 940ms
  /// - Row 3: 1200ms, 820ms, 1190ms
  static const _durationInMills = [
    960, // Top-left
    930, // Top-center
    1190, // Top-right
    1130, // Middle-left
    1340, // Center
    940, // Middle-right
    1200, // Bottom-left
    820, // Bottom-center
    1190, // Bottom-right
  ];

  /// Initial delays for each circle's animation in milliseconds.
  ///
  /// Each circle starts at a different time to create a wave-like effect:
  /// - Row 1: 360ms, 400ms, 680ms
  /// - Row 2: 410ms, 710ms, 790ms
  /// - Row 3: 1080ms, 100ms, 320ms
  static const List<int> _delayInMills = [
    360, // Top-left
    400, // Top-center
    680, // Top-right
    410, // Middle-left
    710, // Center
    790, // Middle-right
    1080, // Bottom-left
    100, // Bottom-center
    320, // Bottom-right
  ];

  /// Controllers for each circle's animation.
  final List<AnimationController> _animationControllers = [];

  /// Scale and opacity animations for each circle.
  final List<Animation<double>> _animations = [];

  @override
  List<AnimationController> get animationControllers => _animationControllers;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _ballNum; i++) {
      // Create controller with initial value set to simulate delay
      _animationControllers.add(
        AnimationController(
          value: _delayInMills[i] / _durationInMills[i],
          vsync: this,
          duration: Duration(milliseconds: _durationInMills[i]),
        ),
      );

      // Create combined scale and opacity animation
      _animations.add(
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
        scale: _animations[i],
        child: FadeTransition(
          opacity: _animations[i],
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

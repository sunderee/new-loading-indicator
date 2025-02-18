import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays three pulsating circles.
///
/// This indicator shows three circles in a row that pulse in size and opacity,
/// creating a beating effect. The outer circles pulse in sync with each other
/// but out of phase with the middle circle, creating a visually appealing rhythm.
///
/// The animation consists of:
/// - Scale animation: circles shrink to 75% and back
/// - Opacity animation: circles fade to 20% opacity and back
/// - Timing: outer circles are delayed by 350ms relative to the middle circle
final class BallBeat extends StatefulWidget {
  /// Creates a ball beat loading indicator.
  const BallBeat({super.key});

  @override
  State<BallBeat> createState() => _BallBeatState();
}

final class _BallBeatState extends State<BallBeat>
    with TickerProviderStateMixin, IndicatorController {
  /// Duration of one complete animation cycle in milliseconds.
  static const _durationInMills = 700;

  /// Delay in milliseconds for each circle's animation start.
  /// The outer circles (index 0 and 2) are delayed by 350ms,
  /// while the middle circle (index 1) starts immediately.
  static const _delayInMills = [350, 0, 350];

  /// Controllers for the animations of each circle.
  final List<AnimationController> _animationControllers = [];

  /// Scale animations for each circle (1.0 -> 0.75 -> 1.0).
  final List<Animation<double>> _scaleAnimations = [];

  /// Opacity animations for each circle (1.0 -> 0.2 -> 1.0).
  final List<Animation<double>> _opacityAnimations = [];

  @override
  List<AnimationController> get animationControllers => _animationControllers;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  /// Initializes the animation controllers and sequences for each circle.
  void _initializeAnimations() {
    for (int i = 0; i < 3; i++) {
      // Create controller with appropriate delay
      _animationControllers.add(
        AnimationController(
          value: _delayInMills[i] / _durationInMills,
          vsync: this,
          duration: const Duration(milliseconds: _durationInMills),
        ),
      );

      // Create scale animation sequence
      _scaleAnimations.add(
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.75), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.75, end: 1.0), weight: 1),
        ]).animate(
          CurvedAnimation(
            parent: _animationControllers[i],
            curve: Curves.linear,
          ),
        ),
      );

      // Create opacity animation sequence
      _opacityAnimations.add(
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.2), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.2, end: 1.0), weight: 1),
        ]).animate(
          CurvedAnimation(
            parent: _animationControllers[i],
            curve: Curves.linear,
          ),
        ),
      );

      // Start the animation
      _animationControllers[i].repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraint) {
        // Create a list of widgets for circles and spacers
        List<Widget> widgets = List.filled(5, Container());

        // Populate the list with alternating circles and spacers
        for (int i = 0; i < 5; i++) {
          if (i.isEven) {
            // Add an animated circle
            widgets[i] = Expanded(
              child: FadeTransition(
                opacity: _opacityAnimations[i ~/ 2],
                child: ScaleTransition(
                  scale: _scaleAnimations[i ~/ 2],
                  child: IndicatorShapeWidget(
                    shape: Shape.circle,
                    index: i ~/ 2,
                  ),
                ),
              ),
            );
          } else {
            // Add a spacer between circles
            widgets[i] = const SizedBox(width: 2);
          }
        }

        // Arrange circles and spacers in a row
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widgets,
        );
      },
    );
  }
}

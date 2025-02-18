import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays three circles pulsing with scale and opacity animations.
///
/// The animation consists of three circles that scale down while slightly fading out,
/// then scale back up while returning to full opacity. Each circle's animation is
/// slightly delayed from the previous one, creating a smooth pulsing sequence.
///
/// The animation uses a custom cubic curve for a more dynamic effect and runs
/// continuously until the widget is disposed.
class BallPulse extends StatefulWidget {
  /// Creates a BallPulse loading indicator.
  const BallPulse({super.key});

  @override
  State<StatefulWidget> createState() => _BallPulseState();
}

/// The state for the [BallPulse] widget.
///
/// This state manages the animation controllers and animations for the three
/// pulsing circles. Each circle has its own animation controller with a specific
/// delay, and combines scale and opacity animations for a more dynamic effect.
class _BallPulseState extends State<BallPulse>
    with TickerProviderStateMixin, IndicatorController {
  /// Total duration of one complete animation cycle in milliseconds.
  static const _durationInMills = 750;

  /// Delays in milliseconds for each circle's animation.
  static const _delayInMills = [120, 240, 360];

  /// List of animation controllers for each circle.
  final List<AnimationController> _animationControllers = [];

  /// List of animations that control the scale of each circle.
  final List<Animation<double>> _scaleAnimations = [];

  /// List of animations that control the opacity of each circle.
  final List<Animation<double>> _opacityAnimations = [];

  @override
  List<AnimationController> get animationControllers => _animationControllers;

  @override
  void initState() {
    super.initState();
    const cubic = Cubic(0.2, 0.68, 0.18, 0.08);
    for (int i = 0; i < 3; i++) {
      _animationControllers.add(
        AnimationController(
          value: _delayInMills[i] / _durationInMills,
          vsync: this,
          duration: const Duration(milliseconds: _durationInMills),
        ),
      );
      _scaleAnimations.add(
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.1), weight: 45),
          TweenSequenceItem(tween: Tween(begin: 0.1, end: 1.0), weight: 35),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 20),
        ]).animate(
          CurvedAnimation(parent: _animationControllers[i], curve: cubic),
        ),
      );
      _opacityAnimations.add(
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.7), weight: 45),
          TweenSequenceItem(tween: Tween(begin: 0.7, end: 1.0), weight: 35),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 20),
        ]).animate(
          CurvedAnimation(parent: _animationControllers[i], curve: cubic),
        ),
      );

      _animationControllers[i].repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final widgets = List<Widget>.filled(3, Container());
    for (int i = 0; i < 3; i++) {
      widgets[i] = FadeTransition(
        opacity: _opacityAnimations[i],
        child: ScaleTransition(
          scale: _scaleAnimations[i],
          child: IndicatorShapeWidget(shape: Shape.circle, index: i),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(child: widgets[0]),
        const SizedBox(width: 2),
        Expanded(child: widgets[1]),
        const SizedBox(width: 2),
        Expanded(child: widgets[2]),
      ],
    );
  }
}

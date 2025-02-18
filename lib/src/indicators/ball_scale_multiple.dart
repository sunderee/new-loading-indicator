import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays three circles scaling up while fading out.
///
/// The animation consists of three circles that start small and invisible, then
/// scale up while briefly becoming visible before fading out. Each circle's
/// animation is delayed from the previous one, creating a ripple-like effect.
///
/// The animation runs continuously until the widget is disposed, with each circle
/// repeating its scale and fade animation in sequence.
class BallScaleMultiple extends StatefulWidget {
  /// Creates a BallScaleMultiple loading indicator.
  const BallScaleMultiple({super.key});

  @override
  State<BallScaleMultiple> createState() => _BallScaleMultipleState();
}

/// The state for the [BallScaleMultiple] widget.
///
/// This state manages the animation controllers and animations for the three
/// scaling circles. Each circle has its own scale and opacity animations with
/// specific delays to create the ripple effect.
class _BallScaleMultipleState extends State<BallScaleMultiple>
    with TickerProviderStateMixin, IndicatorController {
  /// Total duration of one complete animation cycle in milliseconds.
  static const _durationInMills = 1000;

  /// Delays in milliseconds for each circle's animation.
  static const _delayInMills = [0, 200, 400];

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
    for (int i = 0; i < 3; i++) {
      _animationControllers.add(
        AnimationController(
          value: _delayInMills[i] / _durationInMills,
          vsync: this,
          duration: const Duration(milliseconds: _durationInMills),
        ),
      );

      // Scale animation from 0 to 1 (no scale to full size)
      _scaleAnimations.add(
        Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationControllers[i],
            curve: Curves.linear,
          ),
        ),
      );

      // Opacity animation that quickly fades in then slowly fades out
      _opacityAnimations.add(
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 5),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 95),
        ]).animate(
          CurvedAnimation(
            parent: _animationControllers[i],
            curve: Curves.linear,
          ),
        ),
      );

      _animationControllers[i].repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = List.filled(3, Container());
    for (int i = 0; i < 3; i++) {
      widgets[i] = ScaleTransition(
        scale: _scaleAnimations[i],
        child: FadeTransition(
          opacity: _opacityAnimations[i],
          child: IndicatorShapeWidget(shape: Shape.circle, index: i),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: widgets,
    );
  }
}

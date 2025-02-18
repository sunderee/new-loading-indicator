import 'dart:math';

import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays eight circles arranged in a circular pattern,
/// each fading and scaling in sequence to create a spinning effect.
///
/// The animation consists of eight circles positioned equidistantly around a center point.
/// Each circle scales down while fading out, then scales back up while fading in.
/// The animations are delayed in sequence to create a smooth spinning fade effect.
///
/// The animation runs continuously until the widget is disposed, with each circle
/// repeating its fade and scale animation in a coordinated pattern.
class BallSpinFadeLoader extends StatefulWidget {
  /// Creates a BallSpinFadeLoader loading indicator.
  const BallSpinFadeLoader({super.key});

  @override
  State<BallSpinFadeLoader> createState() => _BallSpinFadeLoaderState();
}

/// The number of circles in the animation.
const int _kBallSize = 8;

/// The state for the [BallSpinFadeLoader] widget.
///
/// This state manages the animation controllers and animations for the eight
/// spinning circles. Each circle has its own scale and opacity animations with
/// specific delays to create the spinning fade effect.
class _BallSpinFadeLoaderState extends State<BallSpinFadeLoader>
    with TickerProviderStateMixin, IndicatorController {
  /// Total duration of one complete animation cycle in milliseconds.
  static const _durationInMills = 1000;

  /// Delays in milliseconds for each circle's animation, creating a sequential effect.
  /// Each circle starts its animation 120ms after the previous one.
  static const _delayInMills = [0, 120, 240, 360, 480, 600, 720, 840];

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
    for (int i = 0; i < _kBallSize; i++) {
      _animationControllers.add(
        AnimationController(
          value: _delayInMills[i] / _durationInMills,
          vsync: this,
          duration: const Duration(milliseconds: _durationInMills),
        ),
      );

      // Opacity animation that fades out to 0.3 then back to 1.0
      _opacityAnimations.add(
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 1),
        ]).animate(
          CurvedAnimation(
            parent: _animationControllers[i],
            curve: Curves.linear,
          ),
        ),
      );

      // Scale animation that scales down to 0.4 then back to 1.0
      _scaleAnimations.add(
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.4), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.0), weight: 1),
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
    return LayoutBuilder(
      builder: (ctx, constraint) {
        final circleSize = constraint.maxWidth / 3;

        final widgets = List<Widget>.filled(8, Container());
        final center = Offset(
          constraint.maxWidth / 2,
          constraint.maxHeight / 2,
        );
        for (int i = 0; i < widgets.length; i++) {
          // Calculate position using trigonometry to place circles in a circle
          final angle = pi * i / 4;
          widgets[i] = Positioned.fromRect(
            rect: Rect.fromLTWH(
              // The radius is circleSize / 4, the startX and startY need to subtract that value
              center.dx + circleSize * (sin(angle)) - circleSize / 4,
              center.dy + circleSize * (cos(angle)) - circleSize / 4,
              circleSize / 2,
              circleSize / 2,
            ),
            child: FadeTransition(
              opacity: _opacityAnimations[i],
              child: ScaleTransition(
                scale: _scaleAnimations[i],
                child: IndicatorShapeWidget(shape: Shape.circle, index: i),
              ),
            ),
          );
        }

        return Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: widgets,
        );
      },
    );
  }
}

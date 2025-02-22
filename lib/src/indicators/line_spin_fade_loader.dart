import 'dart:math';

import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays eight lines arranged in a circular pattern,
/// each fading in and out in sequence to create a spinning effect.
///
/// The animation consists of eight lines positioned equidistantly around a center point.
/// Each line rotates to maintain its orientation (perpendicular to the circle's radius)
/// while fading between 30% and 100% opacity. The animations are delayed in sequence
/// to create a smooth spinning fade effect.
///
/// The animation uses specific timings for each line:
/// - Line 1: 0ms delay
/// - Line 2: 120ms delay
/// - Line 3: 240ms delay
/// - Line 4: 360ms delay
/// - Line 5: 480ms delay
/// - Line 6: 600ms delay
/// - Line 7: 720ms delay
/// - Line 8: 840ms delay
///
/// The animation runs continuously until the widget is disposed.
class LineSpinFadeLoader extends StatefulWidget {
  /// Creates a LineSpinFadeLoader loading indicator.
  const LineSpinFadeLoader({super.key});

  @override
  State<LineSpinFadeLoader> createState() => _LineSpinFadeLoaderState();
}

/// The number of lines in the animation.
const int _kLineSize = 8;

/// The state for the [LineSpinFadeLoader] widget.
///
/// This state manages the animation controllers and animations for the eight
/// lines arranged in a circle. Each line has its own opacity animation with
/// specific delays to create the spinning fade effect. The lines are positioned
/// using trigonometric functions and rotated to maintain their orientation.
class _LineSpinFadeLoaderState extends State<LineSpinFadeLoader>
    with TickerProviderStateMixin, IndicatorController {
  /// Total duration of one complete animation cycle in milliseconds.
  static const _durationInMills = 1000;

  /// Delays in milliseconds for each line's animation, creating a sequential pattern:
  /// [0, 120, 240, 360, 480, 600, 720, 840]
  static const _delayInMills = [0, 120, 240, 360, 480, 600, 720, 840];

  /// List of animation controllers for each line.
  final List<AnimationController> _animationControllers = [];

  /// List of animations that control the opacity of each line.
  final List<Animation<double>> _opacityAnimations = [];

  @override
  List<AnimationController> get animationControllers => _animationControllers;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _kLineSize; i++) {
      _animationControllers.add(
        AnimationController(
          value: _delayInMills[i] / _durationInMills,
          vsync: this,
          duration: const Duration(milliseconds: _durationInMills),
        ),
      );
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
          final angle = pi * i / 4;
          widgets[i] = Positioned.fromRect(
            rect: Rect.fromLTWH(
              center.dx + circleSize * (sin(angle)) - circleSize / 4,
              center.dy + circleSize * (cos(angle)) - circleSize / 2,
              circleSize / 2,
              circleSize,
            ),
            child: FadeTransition(
              opacity: _opacityAnimations[i],
              child: Transform.rotate(
                angle: -angle,
                child: IndicatorShapeWidget(shape: Shape.line, index: i),
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

import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays three circles pulsing up and down in a synchronized manner.
///
/// The animation consists of three circles that move vertically in a wave-like pattern,
/// creating a synchronized pulsing effect. Each circle's movement is slightly delayed
/// from the previous one, creating a smooth visual sequence.
///
/// The animation runs continuously until the widget is disposed.
class BallPulseSync extends StatefulWidget {
  /// Creates a BallPulseSync loading indicator.
  const BallPulseSync({super.key});

  @override
  State<BallPulseSync> createState() => _BallPulseSyncState();
}

/// The state for the [BallPulseSync] widget.
///
/// This state manages the animation controllers and animations for the three
/// pulsing circles. Each circle has its own animation controller with a specific
/// delay to create the synchronized pulsing effect.
class _BallPulseSyncState extends State<BallPulseSync>
    with TickerProviderStateMixin, IndicatorController {
  /// Delays in milliseconds for each circle's animation.
  static const _delayInMills = [70, 140, 210];

  /// Total duration of one complete animation cycle in milliseconds.
  static const _durationInMills = 600;

  /// List of animation controllers for each circle.
  final List<AnimationController> _animationControllers = [];

  /// List of animations that control the vertical movement of each circle.
  final List<Animation<double>> _animations = [];

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

      _animations.add(
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: -1.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -1.0, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(
            parent: _animationControllers[i],
            curve: Curves.easeInOut,
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
        final circleSize = (constraint.maxWidth - 4) / 3;
        final deltaY = (constraint.maxHeight / 2 - circleSize) / 2;

        List<Widget> widgets = List.filled(5, Container());
        for (int i = 0; i < 5; i++) {
          if (i.isEven) {
            widgets[i] = Expanded(
              child: AnimatedBuilder(
                animation: _animationControllers[i ~/ 2],
                builder: (_, child) {
                  return Transform.translate(
                    offset: Offset(0, _animations[i ~/ 2].value * deltaY),
                    child: child,
                  );
                },
                child: IndicatorShapeWidget(shape: Shape.circle, index: i),
              ),
            );
          } else {
            widgets[i] = const Expanded(child: SizedBox());
          }
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widgets,
        );
      },
    );
  }
}

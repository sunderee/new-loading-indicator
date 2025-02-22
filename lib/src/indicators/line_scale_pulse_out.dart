import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays five vertical lines smoothly pulsing outward.
///
/// The animation consists of five vertical lines that scale vertically in a smooth
/// sequence, creating a pulsing effect that appears to move outward from the center.
/// Each line scales down to 40% of its height before smoothly scaling back up.
///
/// The animation uses specific timings for each line:
/// - Center line (3rd): No delay
/// - Adjacent lines (2nd & 4th): 200ms delay
/// - Outer lines (1st & 5th): 400ms delay
///
/// The animation uses a custom cubic curve (0.85, 0.25, 0.37, 0.85) for smooth,
/// natural motion and runs continuously until the widget is disposed.
class LineScalePulseOut extends StatefulWidget {
  /// Creates a LineScalePulseOut loading indicator.
  const LineScalePulseOut({super.key});

  @override
  State<LineScalePulseOut> createState() => _LineScalePulseOutState();
}

/// The state for the [LineScalePulseOut] widget.
///
/// This state manages the animation controllers and animations for the five
/// vertical lines. Each line has its own animation controller with specific
/// delay values to create the outward pulsing effect. The animations use an
/// equal-weighted sequence that smoothly transitions between scaled states.
class _LineScalePulseOutState extends State<LineScalePulseOut>
    with TickerProviderStateMixin, IndicatorController {
  /// Total duration of one complete animation cycle in milliseconds.
  static const _durationInMills = 1000;

  /// Delays in milliseconds for each line's animation, creating a symmetrical
  /// outward pattern from the center:
  /// [400, 200, 0, 200, 400]
  static const _delayInMills = [400, 200, 0, 200, 400];

  /// List of animation controllers for each line.
  final List<AnimationController> _animationControllers = [];

  /// List of animations that control the scale of each line.
  final List<Animation<double>> _animations = [];

  @override
  List<AnimationController> get animationControllers => _animationControllers;

  @override
  void initState() {
    super.initState();
    // Custom cubic curve for smooth, natural animation
    const cubic = Cubic(0.85, 0.25, 0.37, 0.85);
    for (int i = 0; i < 5; i++) {
      _animationControllers.add(
        AnimationController(
          value: _delayInMills[i] / _durationInMills,
          vsync: this,
          duration: const Duration(milliseconds: _durationInMills),
        ),
      );
      _animations.add(
        TweenSequence([
          // Scale down to 40%
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.4), weight: 1),
          // Scale back up to 100%
          TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _animationControllers[i], curve: cubic),
        ),
      );

      _animationControllers[i].repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final widgets = List<Widget>.filled(9, Container());
    for (int i = 0; i < widgets.length; i++) {
      if (i.isEven) {
        widgets[i] = Expanded(
          child: AnimatedBuilder(
            animation: _animations[i ~/ 2],
            builder: (BuildContext context, Widget? child) {
              return FractionallySizedBox(
                heightFactor: _animations[i ~/ 2].value,
                child: IndicatorShapeWidget(shape: Shape.line, index: i ~/ 2),
              );
            },
          ),
        );
      } else {
        widgets[i] = Expanded(child: Container());
      }
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }
}

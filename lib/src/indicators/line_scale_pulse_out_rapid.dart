import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays five vertical lines rapidly pulsing outward.
///
/// The animation consists of five vertical lines that scale vertically in a rapid
/// sequence, creating a pulsing effect that appears to move outward from the center.
/// Each line scales down to 30% of its height before quickly scaling back up.
///
/// The animation uses specific timings for each line:
/// - Center line (3rd): No delay
/// - Adjacent lines (2nd & 4th): 250ms delay
/// - Outer lines (1st & 5th): 500ms delay
///
/// The animation uses a custom cubic curve (0.11, 0.49, 0.38, 0.78) for smoother
/// motion and runs continuously until the widget is disposed.
class LineScalePulseOutRapid extends StatefulWidget {
  /// Creates a LineScalePulseOutRapid loading indicator.
  const LineScalePulseOutRapid({super.key});

  @override
  State<LineScalePulseOutRapid> createState() => _LineScalePulseOutRapidState();
}

/// The state for the [LineScalePulseOutRapid] widget.
///
/// This state manages the animation controllers and animations for the five
/// vertical lines. Each line has its own animation controller with specific
/// delay values to create the outward pulsing effect. The animations use a
/// custom sequence that spends most of the time in the scaled-down state
/// before quickly returning to full size.
class _LineScalePulseOutRapidState extends State<LineScalePulseOutRapid>
    with TickerProviderStateMixin, IndicatorController {
  /// Total duration of one complete animation cycle in milliseconds.
  static const _durationInMills = 900;

  /// Delays in milliseconds for each line's animation, creating a symmetrical
  /// outward pattern from the center:
  /// [500, 250, 0, 250, 500]
  static const _delayInMills = [500, 250, 0, 250, 500];

  /// List of animation controllers for each line.
  final List<AnimationController> _animationControllers = [];

  /// List of animations that control the scale of each line.
  final List<Animation<double>> _animations = [];

  @override
  List<AnimationController> get animationControllers => _animationControllers;

  @override
  void initState() {
    super.initState();
    // Custom cubic curve for smoother animation
    const cubic = Cubic(0.11, 0.49, 0.38, 0.78);
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
          // Spend 80% of the time scaling down to 30%
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 80),
          // Quickly scale back up to 100%
          TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 10),
          // Hold at 100% briefly
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 10),
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

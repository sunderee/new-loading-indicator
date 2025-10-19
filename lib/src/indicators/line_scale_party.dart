import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays four vertical lines scaling up and down in a party-like pattern.
///
/// The animation consists of four vertical lines that scale vertically with different
/// durations and delays, creating a dynamic, party-like effect. Each line follows
/// its own animation cycle, scaling between 50% and 100% of its height.
///
/// The animation uses different timings for each line:
/// - Line 1: 1260ms duration, 770ms delay
/// - Line 2: 430ms duration, 290ms delay
/// - Line 3: 1010ms duration, 280ms delay
/// - Line 4: 730ms duration, 740ms delay
///
/// The animation runs continuously until the widget is disposed.
class LineScaleParty extends StatefulWidget {
  /// Creates a LineScaleParty loading indicator.
  const LineScaleParty({super.key});

  @override
  State<LineScaleParty> createState() => _LineScalePartyState();
}

/// The state for the [LineScaleParty] widget.
///
/// This state manages the animation controllers and animations for the four
/// vertical lines. Each line has its own animation controller with specific
/// duration and delay values to create the party-like scaling effect.
class _LineScalePartyState extends State<LineScaleParty>
    with TickerProviderStateMixin, IndicatorController {
  /// Delays in milliseconds for each line's animation.
  static const _delayInMills = [770, 290, 280, 740];

  /// Durations in milliseconds for each line's animation cycle.
  static const _durationInMills = [1260, 430, 1010, 730];

  /// List of animation controllers for each line.
  final List<AnimationController> _animationControllers = [];

  /// List of animations that control the scale of each line.
  final List<Animation<double>> _animations = [];

  @override
  List<AnimationController> get animationControllers => _animationControllers;

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 4; i++) {
      _animationControllers.add(
        AnimationController(
          value: _delayInMills[i] / _durationInMills[i],
          vsync: this,
          duration: Duration(milliseconds: _durationInMills[i]),
        ),
      );

      _animations.add(
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

      _animationControllers[i].repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = _animations
        .asMap()
        .entries
        .map(
          (entry) => Expanded(
            child: AnimatedBuilder(
              animation: entry.value,
              builder: (BuildContext context, Widget? child) {
                return FractionallySizedBox(
                  heightFactor: entry.value.value,
                  child: IndicatorShapeWidget(
                    shape: Shape.line,
                    index: entry.key,
                  ),
                );
              },
            ),
          ),
        )
        .toList();

    for (int i = 0; i < widgets.length - 1; i++) {
      if (i % 2 == 0) {
        widgets.insert(++i, Expanded(child: Container()));
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }
}

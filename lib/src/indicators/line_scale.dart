import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays five vertical lines with sequential scaling animations.
///
/// The animation consists of five vertical lines that scale vertically in sequence,
/// creating a wave-like effect. Each line scales down to 40% of its height before
/// scaling back up to full size, with specific delays between each line's animation:
/// - Line 1: 100ms delay
/// - Line 2: 200ms delay
/// - Line 3: 300ms delay
/// - Line 4: 400ms delay
/// - Line 5: 500ms delay
///
/// The animation uses a custom cubic curve (0.2, 0.68, 0.18, 0.08) for a more
/// dynamic effect and runs continuously until the widget is disposed.
class LineScale extends StatefulWidget {
  /// Creates a LineScale loading indicator.
  const LineScale({super.key});

  @override
  State<LineScale> createState() => _LineScaleState();
}

/// The state for the [LineScale] widget.
///
/// This state manages the animation controllers and animations for the five
/// vertical lines. Each line has its own animation controller with specific
/// delays to create the sequential scaling effect. The animations use a
/// sequence that smoothly transitions between scaled states.
class _LineScaleState extends State<LineScale>
    with TickerProviderStateMixin, IndicatorController {
  /// Total duration of one complete animation cycle in milliseconds.
  static const _durationInMills = 1000;

  /// Delays in milliseconds for each line's animation, creating a sequential pattern:
  /// [100, 200, 300, 400, 500]
  static const _delayInMills = [100, 200, 300, 400, 500];

  /// List of animation controllers for each line.
  final List<AnimationController> _animationControllers = [];

  /// List of animations that control the scale of each line.
  final List<Animation<double>> _animations = [];

  @override
  List<AnimationController> get animationControllers => _animationControllers;

  @override
  void initState() {
    super.initState();
    const cubic = Cubic(0.2, 0.68, 0.18, 0.08);

    for (int i = 0; i < 5; i++) {
      _animationControllers.add(
        AnimationController(
          value: _delayInMills[i] / _durationInMills,
          vsync: this,
          duration: const Duration(seconds: 1),
        ),
      );

      _animations.add(
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.4), weight: 1),
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

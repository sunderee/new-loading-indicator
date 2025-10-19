import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that mimics an audio equalizer visualization.
///
/// This indicator displays a series of vertical bars that animate up and down
/// independently, creating a visual effect similar to an audio equalizer or
/// music visualizer.
///
/// The animation consists of 4 bars with different animation durations and
/// sequences, creating an organic, music-like visualization. The bars are
/// separated by equal spacing and animate continuously until paused.
final class AudioEqualizer extends StatefulWidget {
  /// Creates an audio equalizer loading indicator.
  const AudioEqualizer({super.key});

  @override
  State<AudioEqualizer> createState() => _AudioEqualizerState();
}

final class _AudioEqualizerState extends State<AudioEqualizer>
    with TickerProviderStateMixin, IndicatorController {
  /// The number of animated bars in the equalizer.
  static const _lineNum = 4;

  /// Animation durations for each bar in milliseconds.
  /// Each bar has a different duration to create a more natural effect.
  static const _durationInMills = [
    4300, // First bar
    2500, // Second bar
    1700, // Third bar
    3100, // Fourth bar
  ];

  /// The sequence of scale values that each bar animates through.
  /// Values represent the vertical scale factor at each point in the sequence.
  /// The animation interpolates between consecutive values.
  static const _values = [
    0.0, // Fully compressed
    0.7, // 70% expanded
    0.4, // 40% expanded
    0.05, // Nearly compressed
    0.95, // Nearly fully expanded
    0.3, // 30% expanded
    0.9, // 90% expanded
    0.4, // 40% expanded
    0.15, // 15% expanded
    0.18, // 18% expanded
    0.75, // 75% expanded
    0.01, // Nearly fully compressed
  ];

  /// Controllers for each bar's animation.
  final List<AnimationController> _animationControllers = [];

  /// The actual animations that drive each bar's scale transformation.
  final List<Animation<double>> _animations = [];

  @override
  List<AnimationController> get animationControllers => _animationControllers;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  /// Initializes the animation controllers and sequences for each bar.
  void _initializeAnimations() {
    for (int i = 0; i < _lineNum; i++) {
      // Create a controller with the specified duration for this bar
      _animationControllers.add(
        AnimationController(
          vsync: this,
          duration: Duration(milliseconds: _durationInMills[i]),
        ),
      );

      // Create the sequence of animations for this bar
      final sequences = <TweenSequenceItem<double>>[];
      for (int j = 0; j < _values.length - 1; j++) {
        sequences.add(
          TweenSequenceItem(
            tween: Tween(begin: _values[j], end: _values[j + 1]),
            weight: 1,
          ),
        );
      }

      // Create and store the animation
      _animations.add(
        TweenSequence(sequences).animate(_animationControllers[i]),
      );

      // Start the animation
      _animationControllers[i].repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create a list of widgets for bars and spacers
    final widgets = List<Widget>.filled(7, Container());

    // Populate the list with alternating bars and spacers
    for (int i = 0; i < widgets.length; i++) {
      if (i.isEven) {
        // Add an animated bar
        widgets[i] = Expanded(
          child: AnimatedBuilder(
            animation: _animations[i ~/ 2],
            builder: (_, child) {
              return Transform(
                transform: Matrix4.diagonal3Values(
                  1.0,
                  _animations[i ~/ 2].value,
                  1.0,
                ),
                alignment: Alignment.bottomCenter,
                child: child,
              );
            },
            child: IndicatorShapeWidget(shape: Shape.rectangle, index: i ~/ 2),
          ),
        );
      } else {
        // Add a spacer between bars
        widgets[i] = const Expanded(child: SizedBox());
      }
    }

    // Arrange bars and spacers in a row
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays five circles alternating in a wave-like motion.
///
/// This indicator shows five circles in a row that move up and down while scaling,
/// creating a wave-like effect. The circles are divided into two groups (odd and even indices)
/// that move in opposite patterns, making the animation feel balanced and rhythmic.
///
/// The animation consists of:
/// - Scale: Circles scale between different ranges:
///   - Odd circles: 40% -> 110% -> 75%
///   - Even circles: 110% -> 40% -> 100%
/// - Translation: Circles move vertically in opposite patterns:
///   - Odd circles: 0 -> up -> down -> 0
///   - Even circles: 0 -> down -> up -> 0
/// - Timing: 1-second duration with a custom cubic curve (0.15, 0.46, 0.9, 0.6)
/// - Layout: Circles are arranged in a row with equal spacing
///
/// The alternating patterns and smooth transitions create a mesmerizing wave effect
/// that makes the loading state visually engaging.
final class BallPulseRise extends StatefulWidget {
  /// Creates a ball pulse rise loading indicator.
  const BallPulseRise({super.key});

  @override
  State<BallPulseRise> createState() => _BallPulseRiseState();
}

final class _BallPulseRiseState extends State<BallPulseRise>
    with SingleTickerProviderStateMixin, IndicatorController {
  /// The main animation controller that drives all animations.
  late AnimationController _animationController;

  /// Scale animation for circles at odd indices (40% -> 110% -> 75%).
  late Animation<double> _oddScaleAnimation;

  /// Vertical translation animation for circles at odd indices (0 -> up -> down -> 0).
  late Animation<double> _oddTranslateAnimation;

  /// Scale animation for circles at even indices (110% -> 40% -> 100%).
  late Animation<double> _evenScaleAnimation;

  /// Vertical translation animation for circles at even indices (0 -> down -> up -> 0).
  late Animation<double> _evenTranslateAnimation;

  @override
  List<AnimationController> get animationControllers => [_animationController];

  @override
  void initState() {
    super.initState();
    // Initialize the main animation controller with 1-second duration
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Custom cubic curve for smooth, natural motion
    const cubic = Cubic(0.15, 0.46, 0.9, 0.6);

    // Create scale animation for odd-indexed circles
    _oddScaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.1), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 0.75), weight: 50),
    ]).animate(CurvedAnimation(parent: _animationController, curve: cubic));

    // Create translation animation for odd-indexed circles
    _oddTranslateAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: -1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -1.0, end: 0.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _animationController, curve: cubic));

    // Create scale animation for even-indexed circles
    _evenScaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 0.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _animationController, curve: cubic));

    // Create translation animation for even-indexed circles
    _evenTranslateAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -1.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _animationController, curve: cubic));

    // Start the repeating animation
    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraint) {
        // Calculate layout dimensions
        const circleSpacing = 2;
        final circleSize = (constraint.maxWidth - 4 * circleSpacing) / 5;
        const x = 0;
        final y = (constraint.maxHeight - circleSize) / 2;
        final widgets = List<Widget>.filled(5, Container());
        final deltaY = constraint.maxHeight / 3;

        // Create and position each circle
        for (int i = 0; i < 5; i++) {
          Widget child = _buildSingleCircle(i, deltaY);
          widgets[i] = Positioned.fromRect(
            rect: Rect.fromLTWH(
              x + circleSize * i + circleSpacing * i,
              y,
              circleSize,
              circleSize,
            ),
            child: child,
          );
        }
        return Stack(children: widgets);
      },
    );
  }

  /// Builds a single animated circle with the appropriate animations based on its index.
  ///
  /// The circle's animations are determined by whether its index is even or odd:
  /// - Even indices: Use [_evenScaleAnimation] and [_evenTranslateAnimation]
  /// - Odd indices: Use [_oddScaleAnimation] and [_oddTranslateAnimation]
  ///
  /// The [deltaY] parameter determines the vertical translation range.
  AnimatedBuilder _buildSingleCircle(int index, double deltaY) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, child) {
        return Transform(
          alignment: Alignment.center,
          transform:
              Matrix4.identity()
                ..scale(
                  index.isEven
                      ? _evenScaleAnimation.value
                      : _oddScaleAnimation.value,
                )
                ..translate(
                  0.0,
                  index.isEven
                      ? _evenTranslateAnimation.value * deltaY
                      : _oddTranslateAnimation.value * deltaY,
                )
                ..setEntry(3, 2, 0.006),
          child: child,
        );
      },
      child: IndicatorShapeWidget(shape: Shape.circle, index: index),
    );
  }
}

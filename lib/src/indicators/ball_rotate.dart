import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays three circles rotating and scaling in unison.
///
/// The animation consists of three circles arranged horizontally, with the outer
/// circles slightly dimmed. The entire row rotates while simultaneously scaling
/// up and down, creating a smooth rotating effect.
///
/// The animation uses a custom cubic curve for a more dynamic effect and runs
/// continuously until the widget is disposed.
class BallRotate extends StatefulWidget {
  /// Creates a BallRotate loading indicator.
  const BallRotate({super.key});

  @override
  State<BallRotate> createState() => _BallRotateState();
}

/// The state for the [BallRotate] widget.
///
/// This state manages the animation controller and animations for the rotating
/// circles. It combines rotation and scale animations with a custom curve to
/// create a smooth, continuous motion.
class _BallRotateState extends State<BallRotate>
    with SingleTickerProviderStateMixin, IndicatorController {
  /// The main animation controller that drives all animations.
  late AnimationController _animationController;

  /// Animation that controls the scale of all circles.
  late Animation<double> _scaleAnimation;

  /// Animation that controls the rotation of the entire row of circles.
  late Animation<double> _rotateAnimation;

  @override
  List<AnimationController> get animationControllers => [_animationController];

  @override
  void initState() {
    super.initState();

    /// Custom cubic curve for smoother animation.
    /// Note: If b is set to -0.13, value becomes negative and [TweenSequence]'s
    /// transform will throw an error.
    const cubic = Cubic(0.7, 0.87, 0.22, 0.86);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Scale animation that pulses the circles between 60% and 100% size
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _animationController, curve: cubic));

    // Rotation animation that completes one full turn
    _rotateAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: cubic));

    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _rotateAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(child: _buildSingleCircle(0.8, 0)),
            const Expanded(child: SizedBox()),
            Expanded(child: _buildSingleCircle(1.0, 1)),
            const Expanded(child: SizedBox()),
            Expanded(child: _buildSingleCircle(0.8, 2)),
          ],
        ),
      ),
    );
  }

  /// Creates a single circle with the specified opacity and index.
  ///
  /// The [opacity] parameter controls how transparent the circle appears, where
  /// 1.0 is fully opaque and 0.0 is fully transparent.
  ///
  /// The [index] parameter is used to identify the circle and determine its color
  /// from the indicator's color scheme.
  Opacity _buildSingleCircle(double opacity, int index) {
    return Opacity(
      opacity: opacity,
      child: IndicatorShapeWidget(shape: Shape.circle, index: index),
    );
  }
}

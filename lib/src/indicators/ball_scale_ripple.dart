import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays a single ring scaling up while fading out.
///
/// The animation consists of a ring that starts small and fully opaque, then
/// scales up while gradually fading out. The ring maintains its scale for a
/// portion of the animation to create a more pronounced ripple effect.
///
/// The animation uses a custom cubic curve for smoother motion and runs
/// continuously until the widget is disposed.
class BallScaleRipple extends StatefulWidget {
  /// Creates a BallScaleRipple loading indicator.
  const BallScaleRipple({super.key});

  @override
  State<BallScaleRipple> createState() => _BallScaleRippleState();
}

/// The state for the [BallScaleRipple] widget.
///
/// This state manages the animation controller and animations for the rippling
/// ring. The ring has both scale and opacity animations with specific curves
/// to create the ripple effect.
class _BallScaleRippleState extends State<BallScaleRipple>
    with SingleTickerProviderStateMixin, IndicatorController {
  /// The main animation controller that drives all animations.
  late AnimationController _animationController;

  /// Animation that controls the opacity of the ring.
  late Animation<double> _opacityAnimation;

  /// Animation that controls the scale of the ring.
  late Animation<double> _scaleAnimation;

  @override
  List<AnimationController> get animationControllers => [_animationController];

  @override
  void initState() {
    super.initState();
    // Custom cubic curve for smoother animation
    const cubic = Cubic(0.21, 0.53, 0.56, 0.8);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Opacity animation that gradually fades out with a slower initial fade
    _opacityAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.7), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 0.7, end: 0.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _animationController, curve: cubic));

    // Scale animation that scales up and maintains the scale for a period
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.1, end: 1.0), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 70),
    ]).animate(CurvedAnimation(parent: _animationController, curve: cubic));

    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: const IndicatorShapeWidget(shape: Shape.ring),
      ),
    );
  }
}

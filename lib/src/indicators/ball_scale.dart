import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays a single circle scaling up while fading out.
///
/// The animation consists of a circle that starts small and fully opaque, then
/// scales up while gradually fading out. The animation uses a smooth easing curve
/// for both the scale and opacity transitions.
///
/// The animation runs continuously until the widget is disposed, creating a
/// pulsing effect as the circle repeatedly grows and fades.
class BallScale extends StatefulWidget {
  /// Creates a BallScale loading indicator.
  const BallScale({super.key});

  @override
  State<BallScale> createState() => _BallScaleState();
}

/// The state for the [BallScale] widget.
///
/// This state manages the animation controller and animations for the scaling
/// circle. The circle has both scale and opacity animations that are inversely
/// related - as the circle scales up, it fades out, creating a smooth
/// expanding effect.
class _BallScaleState extends State<BallScale>
    with SingleTickerProviderStateMixin, IndicatorController {
  /// The main animation controller that drives all animations.
  late AnimationController _animationController;

  /// Animation that controls the scale of the circle.
  late Animation<double> _scaleAnimation;

  /// Animation that controls the opacity of the circle.
  /// This is the reverse of the scale animation, so the circle
  /// becomes more transparent as it grows larger.
  late Animation<double> _opacityAnimation;

  @override
  List<AnimationController> get animationControllers => [_animationController];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _scaleAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _opacityAnimation = ReverseAnimation(_scaleAnimation);
    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: const IndicatorShapeWidget(shape: Shape.circle),
      ),
    );
  }
}

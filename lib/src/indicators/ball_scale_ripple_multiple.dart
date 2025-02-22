import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays three concentric rings scaling up while fading out.
///
/// The animation consists of three rings that start small and fully opaque, then
/// scale up while gradually fading out. Each ring's animation is delayed from the
/// previous one, creating a ripple-like effect. The rings maintain their scale
/// for a portion of the animation to create a more pronounced ripple effect.
///
/// The animation uses a custom cubic curve for smoother motion and runs
/// continuously until the widget is disposed.
class BallScaleRippleMultiple extends StatefulWidget {
  /// Creates a BallScaleRippleMultiple loading indicator.
  const BallScaleRippleMultiple({super.key});

  @override
  State<BallScaleRippleMultiple> createState() =>
      _BallScaleRippleMultipleState();
}

/// The state for the [BallScaleRippleMultiple] widget.
///
/// This state manages the animation controllers and animations for the three
/// rippling rings. Each ring has its own scale and opacity animations with
/// specific delays and curves to create the ripple effect.
class _BallScaleRippleMultipleState extends State<BallScaleRippleMultiple>
    with TickerProviderStateMixin, IndicatorController {
  /// Total duration of one complete animation cycle in milliseconds.
  static const _durationInMills = 1250;

  /// Delays in milliseconds for each ring's animation.
  static const _delayInMills = [0, 200, 400];

  /// List of animation controllers for each ring.
  final List<AnimationController> _animationControllers = [];

  /// List of animations that control the opacity of each ring.
  final List<Animation<double>> _opacityAnimations = [];

  /// List of animations that control the scale of each ring.
  final List<Animation<double>> _scaleAnimations = [];

  @override
  List<AnimationController> get animationControllers => _animationControllers;

  @override
  void initState() {
    super.initState();
    // Custom cubic curve for smoother animation
    const cubic = Cubic(0.21, 0.53, 0.56, 0.8);

    for (int i = 0; i < 3; i++) {
      _animationControllers.add(
        AnimationController(
          value: _delayInMills[i] / _durationInMills,
          vsync: this,
          duration: const Duration(milliseconds: _durationInMills),
        ),
      );

      // Opacity animation that gradually fades out with a slower initial fade
      _opacityAnimations.add(
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.7), weight: 70),
          TweenSequenceItem(tween: Tween(begin: 0.7, end: 0.0), weight: 30),
        ]).animate(
          CurvedAnimation(parent: _animationControllers[i], curve: cubic),
        ),
      );

      // Scale animation that scales up and maintains the scale for a period
      _scaleAnimations.add(
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 70),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 70),
        ]).animate(
          CurvedAnimation(parent: _animationControllers[i], curve: cubic),
        ),
      );

      _animationControllers[i].repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = List.filled(3, Container());
    for (int i = 0; i < widgets.length; i++) {
      widgets[i] = ScaleTransition(
        scale: _scaleAnimations[i],
        child: FadeTransition(
          opacity: _opacityAnimations[i],
          child: IndicatorShapeWidget(shape: Shape.ring, index: i),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: widgets,
    );
  }
}

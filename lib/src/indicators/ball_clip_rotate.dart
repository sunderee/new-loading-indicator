import 'dart:math';

import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays a rotating ring segment that scales up and down.
///
/// This indicator shows a three-quarter ring that rotates while simultaneously
/// scaling in size, creating a smooth circular loading animation. The animation
/// completes one full rotation while scaling between 100% and 60% size.
///
/// The animation consists of:
/// - Rotation: Full 360° rotation in 750ms
/// - Scale: Ring scales between 100% and 60% size
/// - Timing: Linear curve for smooth, constant motion
final class BallClipRotate extends StatefulWidget {
  /// Creates a ball clip rotate loading indicator.
  const BallClipRotate({super.key});

  @override
  State<BallClipRotate> createState() => _BallClipRotateState();
}

final class _BallClipRotateState extends State<BallClipRotate>
    with SingleTickerProviderStateMixin, IndicatorController {
  /// Duration of one complete animation cycle in milliseconds.
  static const _durationInMills = 750;

  /// The main animation controller that drives both rotation and scaling.
  late AnimationController _animationController;

  /// Animation that controls the scaling of the ring (1.0 -> 0.6 -> 1.0).
  late Animation<double> _scaleAnimation;

  /// Animation that controls the rotation of the ring (0 -> 2π).
  late Animation<double> _rotateAnimation;

  @override
  List<AnimationController> get animationControllers => [_animationController];

  @override
  void initState() {
    super.initState();
    // Initialize the main animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _durationInMills),
    );

    // Create scale animation sequence
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    // Create rotation animation (full 360° rotation)
    _rotateAnimation = Tween(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    // Start the repeating animation
    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, child) {
        return Transform(
          alignment: Alignment.center,
          transform:
              Matrix4.identity()
                ..scale(_scaleAnimation.value)
                ..rotateZ(_rotateAnimation.value),
          child: child,
        );
      },
      // Use a three-quarter ring shape that will be rotated and scaled
      child: const IndicatorShapeWidget(shape: Shape.ringThirdFour),
    );
  }
}

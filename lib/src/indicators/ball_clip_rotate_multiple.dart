import 'dart:math';

import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays two rotating and scaling ring segments.
///
/// This indicator shows two half-ring segments that rotate in opposite directions
/// while scaling up and down. The outer ring is larger and contains a smaller
/// inner ring, creating a complex but visually appealing animation.
///
/// The animation consists of:
/// - Rotation: Both rings complete a full 360° rotation
/// - Scale: Rings scale between 100% and 60% size
/// - Timing: Both animations use easeInOut curve for smooth motion
final class BallClipRotateMultiple extends StatefulWidget {
  /// Creates a ball clip rotate multiple loading indicator.
  const BallClipRotateMultiple({super.key});

  @override
  State<BallClipRotateMultiple> createState() => _BallClipRotateMultipleState();
}

final class _BallClipRotateMultipleState extends State<BallClipRotateMultiple>
    with SingleTickerProviderStateMixin, IndicatorController {
  /// Duration of one complete animation cycle in milliseconds.
  static const _durationInMills = 1000;

  /// The main animation controller that drives both rotation and scaling.
  late AnimationController _animationController;

  /// Animation that controls the rotation of both rings (0 to 2π).
  late Animation<double> _rotateAnimation;

  /// Animation that controls the scaling of both rings (1.0 to 0.6).
  late Animation<double> _scaleAnimation;

  @override
  List<AnimationController> get animationControllers => [_animationController];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  /// Initializes the animation controller and sequences.
  void _initializeAnimations() {
    // Create the main animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _durationInMills),
    );

    // Create rotation animation sequence (0 -> π -> 2π)
    _rotateAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: pi), weight: 1),
      TweenSequenceItem(tween: Tween(begin: pi, end: 2 * pi), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Create scale animation sequence (1.0 -> 0.6 -> 1.0)
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start the repeating animation
    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder:
          (ctx, constraint) => AnimatedBuilder(
            animation: _animationController,
            builder:
                (_, child) => Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: <Widget>[
                    // Outer ring
                    Transform(
                      alignment: Alignment.center,
                      transform:
                          Matrix4.identity()
                            ..scale(_scaleAnimation.value)
                            ..rotateZ(_rotateAnimation.value),
                      child: child,
                    ),
                    // Inner ring (half size, opposite rotation)
                    Positioned(
                      left: constraint.maxWidth / 4,
                      top: constraint.maxHeight / 4,
                      width: constraint.maxWidth / 2,
                      height: constraint.maxHeight / 2,
                      child: Transform(
                        alignment: Alignment.center,
                        transform:
                            Matrix4.identity()
                              ..scale(_scaleAnimation.value)
                              ..rotateZ(-_rotateAnimation.value),
                        child: child,
                      ),
                    ),
                  ],
                ),
            child: const IndicatorShapeWidget(shape: Shape.ringTwoHalfVertical),
          ),
    );
  }
}

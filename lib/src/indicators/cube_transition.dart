import 'dart:math';

import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays two squares performing a synchronized rotation and transition animation.
///
/// The animation consists of two squares that move in opposite directions along the edges
/// of a square path while simultaneously rotating and scaling. One square starts from the
/// top-left corner and moves clockwise, while the other starts from the bottom-right
/// corner and moves counterclockwise.
///
/// Each square completes a full rotation while following its path, creating a complex
/// but smooth animation that combines translation, rotation, and scaling effects.
/// The animation runs continuously until the widget is disposed.
class CubeTransition extends StatefulWidget {
  /// Creates a CubeTransition loading indicator.
  const CubeTransition({super.key});

  @override
  State<CubeTransition> createState() => _CubeTransitionState();
}

/// The state for the [CubeTransition] widget.
///
/// This state manages the animation controller and animations for the two
/// transitioning squares. Each square has three synchronized animations:
/// - Translation: Moves the square along a square path
/// - Rotation: Rotates the square around its center
/// - Scale: Changes the square's size during the transition
class _CubeTransitionState extends State<CubeTransition>
    with SingleTickerProviderStateMixin, IndicatorController {
  /// Total duration of one complete animation cycle in milliseconds.
  static const _durationInMills = 1600;

  /// The main animation controller that drives all animations.
  late AnimationController _animationController;

  /// Animation that controls the position of both squares along their paths.
  /// The animation value is a Size where:
  /// - width represents the horizontal progress (0.0 to 1.0)
  /// - height represents the vertical progress (0.0 to 1.0)
  late Animation<Size?> _translateAnimation;

  /// Animation that controls the rotation of both squares.
  /// Completes one full rotation (-2π) during the animation cycle.
  late Animation<double> _rotateAnimation;

  /// Animation that controls the scale of both squares.
  /// Squares scale down to half size at path corners and back to full size
  /// along the edges.
  late Animation<double> _scaleAnimation;

  @override
  List<AnimationController> get animationControllers => [_animationController];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _durationInMills),
    );

    // Translation animation sequence:
    // 1. Move right (1.0, 0.0)
    // 2. Move down (1.0, 1.0)
    // 3. Move left (0.0, 1.0)
    // 4. Move up (0.0, 0.0)
    _translateAnimation =
        TweenSequence([
          TweenSequenceItem(
            tween: SizeTween(
              begin: const Size(0.0, 0.0),
              end: const Size(1.0, 0.0),
            ),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: SizeTween(
              begin: const Size(1.0, 0.0),
              end: const Size(1.0, 1.0),
            ),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: SizeTween(
              begin: const Size(1.0, 1.0),
              end: const Size(0.0, 1.0),
            ),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: SizeTween(
              begin: const Size(0.0, 1.0),
              end: const Size(0.0, 0.0),
            ),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.linear),
        );

    // Rotation animation sequence:
    // Rotates -90 degrees at each corner, completing -360 degrees total
    _rotateAnimation =
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: -pi / 2), weight: 1),
          TweenSequenceItem(
            tween: Tween(begin: -pi / 2, end: -pi),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(begin: -pi, end: -pi * 1.5),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(begin: -pi * 1.5, end: -pi * 2),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    // Scale animation sequence:
    // Scales down to 0.5 at corners and back to 1.0 along edges
    _scaleAnimation =
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 1),
        ]).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraint) {
        final squareSize = constraint.maxWidth / 5;

        // Calculate the distance each square can move
        final deltaX = constraint.maxWidth - squareSize;
        final deltaY = constraint.maxHeight - squareSize;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (_, child) => Stack(
            children: [
              // First square moving clockwise from top-left
              Positioned.fromRect(
                rect: Rect.fromLTWH(0, 0, squareSize, squareSize),
                child: Transform(
                  alignment: Alignment.center,
                  transform:
                      Matrix4.diagonal3Values(
                          _scaleAnimation.value,
                          _scaleAnimation.value,
                          _scaleAnimation.value,
                        )
                        ..multiply(Matrix4.rotationZ(_rotateAnimation.value))
                        ..multiply(
                          Matrix4.translationValues(
                            _translateAnimation.value!.width * deltaX,
                            _translateAnimation.value!.height * deltaY,
                            0.0,
                          ),
                        ),
                  child: const IndicatorShapeWidget(
                    shape: Shape.rectangle,
                    index: 0,
                  ),
                ),
              ),
              // Second square moving counterclockwise from bottom-right
              Positioned.fromRect(
                rect: Rect.fromLTWH(
                  constraint.maxWidth - squareSize,
                  constraint.maxHeight - squareSize,
                  squareSize,
                  squareSize,
                ),
                child: Transform(
                  alignment: Alignment.center,
                  transform:
                      Matrix4.diagonal3Values(
                          _scaleAnimation.value,
                          _scaleAnimation.value,
                          _scaleAnimation.value,
                        )
                        ..multiply(Matrix4.rotationZ(_rotateAnimation.value))
                        ..multiply(
                          Matrix4.translationValues(
                            -_translateAnimation.value!.width * deltaX,
                            -_translateAnimation.value!.height * deltaY,
                            0.0,
                          ),
                        ),
                  child: const IndicatorShapeWidget(
                    shape: Shape.rectangle,
                    index: 1,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

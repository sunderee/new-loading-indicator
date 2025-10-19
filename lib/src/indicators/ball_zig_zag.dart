import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays two circles moving in a continuous zig-zag pattern.
///
/// The animation consists of two circles that move in opposite directions,
/// creating a continuous zig-zag pattern. One circle moves up and to the sides
/// while the other moves in a mirrored pattern, creating a synchronized dance-like
/// motion.
///
/// Unlike [BallZigZagDeflect], this animation only moves forward without reversing,
/// creating a continuous circular motion rather than a back-and-forth deflection.
/// The animation runs continuously until the widget is disposed.
class BallZigZag extends StatefulWidget {
  /// Creates a BallZigZag loading indicator.
  const BallZigZag({super.key});

  @override
  State<BallZigZag> createState() => _BallZigZagState();
}

/// The state for the [BallZigZag] widget.
///
/// This state manages the animation controller and animations for the two
/// circles. The circles move in opposite directions using a sequence of
/// translations, creating a continuous zig-zag pattern.
class _BallZigZagState extends State<BallZigZag>
    with SingleTickerProviderStateMixin, IndicatorController {
  /// Total duration of one complete animation cycle in milliseconds.
  static const _durationInMills = 700;

  /// The main animation controller that drives all animations.
  late AnimationController _animationController;

  /// Animation that controls the movement of both circles.
  /// One circle uses this animation directly, while the other uses its inverse.
  late Animation<Offset> _animation;

  @override
  List<AnimationController> get animationControllers => [_animationController];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _durationInMills),
    );

    // Animation sequence that creates the zig-zag pattern:
    // 1. Move up and left
    // 2. Move right while maintaining height
    // 3. Return to center
    _animation =
        TweenSequence([
          TweenSequenceItem(
            tween: Tween(begin: const Offset(0, 0), end: const Offset(-1, -1)),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(begin: const Offset(-1, -1), end: const Offset(1, -1)),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(begin: const Offset(1, -1), end: const Offset(0, 0)),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.linear),
        );

    // Repeat the animation continuously in a forward-only direction
    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraint) {
        // Calculate circle size and positioning deltas
        final circleSize = constraint.maxWidth / 5;
        final deltaX = constraint.maxWidth / 2 - circleSize / 2;
        final deltaY = constraint.maxHeight / 2 - circleSize / 2;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (_, child) {
            return Stack(
              children: <Widget>[
                // First circle using the animation directly
                Positioned.fromRect(
                  rect: Rect.fromLTWH(deltaX, deltaY, circleSize, circleSize),
                  child: Transform(
                    transform: Matrix4.translationValues(
                      deltaX * _animation.value.dx,
                      deltaY * _animation.value.dy,
                      0.0,
                    ),
                    child: const IndicatorShapeWidget(
                      shape: Shape.circle,
                      index: 0,
                    ),
                  ),
                ),
                // Second circle using the inverse of the animation
                Positioned.fromRect(
                  rect: Rect.fromLTWH(deltaX, deltaY, circleSize, circleSize),
                  child: Transform(
                    transform: Matrix4.translationValues(
                      deltaX * -_animation.value.dx,
                      deltaY * -_animation.value.dy,
                      0.0,
                    ),
                    child: const IndicatorShapeWidget(
                      shape: Shape.circle,
                      index: 1,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

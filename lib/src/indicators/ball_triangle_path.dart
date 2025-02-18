import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays three rings moving in a triangular path.
///
/// The animation consists of three rings positioned at the vertices of a triangle.
/// Each ring moves along the edges of the triangle in a coordinated pattern,
/// creating a continuous flowing motion.
///
/// Similar to BallTrianglePathColored but always uses rings instead of
/// configurable shapes. The animation runs continuously until the widget is
/// disposed, with each ring completing a full circuit around the triangle
/// in a smooth, eased motion.
class BallTrianglePath extends StatefulWidget {
  /// Creates a BallTrianglePath loading indicator.
  const BallTrianglePath({super.key});

  @override
  State<BallTrianglePath> createState() => _BallTrianglePathState();
}

/// The state for the [BallTrianglePath] widget.
///
/// This state manages the animation controller and animations for the three
/// rings moving along the triangle path. Each ring follows a sequence of
/// movements that form one side of the triangle, creating a continuous
/// circular motion around the triangle's perimeter.
class _BallTrianglePathState extends State<BallTrianglePath>
    with SingleTickerProviderStateMixin, IndicatorController {
  /// The main animation controller that drives all animations.
  late AnimationController _animationController;

  /// Animation that controls the movement of the top center ring.
  ///
  /// The ring moves from top center → right bottom → left bottom → top center.
  late Animation<Offset> _topCenterAnimation;

  /// Animation that controls the movement of the left bottom ring.
  ///
  /// The ring moves from left bottom → top center → right bottom → left bottom.
  late Animation<Offset> _leftBottomAnimation;

  /// Animation that controls the movement of the right bottom ring.
  ///
  /// The ring moves from right bottom → left bottom → top center → right bottom.
  late Animation<Offset> _rightBottomAnimation;

  @override
  List<AnimationController> get animationControllers => [_animationController];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Animation for the top center ring
    _topCenterAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0, 0), end: const Offset(0.5, 1)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0.5, 1), end: const Offset(-0.5, 1)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(-0.5, 1), end: const Offset(0, 0)),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Animation for the left bottom ring
    _leftBottomAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0, 0), end: const Offset(0.5, -1)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0.5, -1), end: const Offset(1, 0)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(1, 0), end: const Offset(0, 0)),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Animation for the right bottom ring
    _rightBottomAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0, 0), end: const Offset(-1, 0)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(-1, 0), end: const Offset(-0.5, -1)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(-0.5, -1), end: const Offset(0, 0)),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraint) {
        final circleSize = constraint.maxWidth / 5;
        final container = Size(constraint.maxWidth, constraint.maxHeight);

        List<Widget> widgets = List.filled(3, Container());
        widgets[0] = Positioned.fromRect(
          rect: Rect.fromLTWH(
            constraint.maxWidth / 2 - circleSize / 2,
            0,
            circleSize,
            circleSize,
          ),
          child: _buildAnimatedRing(
            container,
            circleSize,
            _topCenterAnimation,
            0,
          ),
        );
        widgets[1] = Positioned.fromRect(
          rect: Rect.fromLTWH(
            0,
            constraint.maxHeight - circleSize,
            circleSize,
            circleSize,
          ),
          child: _buildAnimatedRing(
            container,
            circleSize,
            _leftBottomAnimation,
            1,
          ),
        );
        widgets[2] = Positioned.fromRect(
          rect: Rect.fromLTWH(
            constraint.maxWidth - circleSize,
            constraint.maxHeight - circleSize,
            circleSize,
            circleSize,
          ),
          child: _buildAnimatedRing(
            container,
            circleSize,
            _rightBottomAnimation,
            2,
          ),
        );

        return Stack(children: widgets);
      },
    );
  }

  /// Creates an animated ring that follows a specified path.
  ///
  /// The [size] parameter defines the container size for calculating translations.
  /// The [circleSize] parameter defines the size of the ring.
  /// The [animation] parameter controls the movement of the ring.
  /// The [index] parameter is used to determine the ring's color from the theme.
  AnimatedBuilder _buildAnimatedRing(
    Size size,
    double circleSize,
    Animation<Offset> animation,
    int index,
  ) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, child) {
        return Transform(
          transform:
              Matrix4.identity()..translate(
                animation.value.dx * (size.width - circleSize),
                animation.value.dy * (size.height - circleSize),
              ),
          child: child,
        );
      },
      child: IndicatorShapeWidget(shape: Shape.ring, index: index),
    );
  }
}

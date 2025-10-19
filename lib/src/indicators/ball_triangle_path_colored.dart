import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays three shapes moving in a triangular path.
///
/// The animation consists of three shapes (either circles or rings) positioned at
/// the vertices of a triangle. Each shape moves along the edges of the triangle
/// in a coordinated pattern, creating a continuous flowing motion.
///
/// The animation runs continuously until the widget is disposed, with each shape
/// completing a full circuit around the triangle in a smooth, eased motion.
class BallTrianglePathColored extends StatefulWidget {
  /// Whether to use filled circles instead of rings for the shapes.
  ///
  /// If true, the shapes will be solid circles. If false, they will be rings.
  final bool isFilled;

  /// Creates a BallTrianglePathColored loading indicator.
  ///
  /// The [isFilled] parameter determines whether the shapes are filled circles
  /// (true) or rings (false). Defaults to false.
  const BallTrianglePathColored({super.key, this.isFilled = false});

  @override
  State<BallTrianglePathColored> createState() =>
      _BallTrianglePathColoredState();
}

/// The state for the [BallTrianglePathColored] widget.
///
/// This state manages the animation controller and animations for the three
/// shapes moving along the triangle path. Each shape follows a sequence of
/// movements that form one side of the triangle, creating a continuous
/// circular motion around the triangle's perimeter.
class _BallTrianglePathColoredState extends State<BallTrianglePathColored>
    with SingleTickerProviderStateMixin, IndicatorController {
  /// The main animation controller that drives all animations.
  late AnimationController _animationController;

  /// Animation that controls the movement of the top center shape.
  ///
  /// The shape moves from top center → right bottom → left bottom → top center.
  Animation<Offset>? _topCenterAnimation;

  /// Animation that controls the movement of the left bottom shape.
  ///
  /// The shape moves from left bottom → top center → right bottom → left bottom.
  Animation<Offset>? _leftBottomAnimation;

  /// Animation that controls the movement of the right bottom shape.
  ///
  /// The shape moves from right bottom → left bottom → top center → right bottom.
  Animation<Offset>? _rightBottomAnimation;

  @override
  List<AnimationController> get animationControllers => [_animationController];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Animation for the top center shape
    _topCenterAnimation =
        TweenSequence([
          TweenSequenceItem(
            tween: Tween(begin: const Offset(0, 0), end: const Offset(0.5, 1)),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(
              begin: const Offset(0.5, 1),
              end: const Offset(-0.5, 1),
            ),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(begin: const Offset(-0.5, 1), end: const Offset(0, 0)),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    // Animation for the left bottom shape
    _leftBottomAnimation =
        TweenSequence([
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
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    // Animation for the right bottom shape
    _rightBottomAnimation =
        TweenSequence([
          TweenSequenceItem(
            tween: Tween(begin: const Offset(0, 0), end: const Offset(-1, 0)),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(
              begin: const Offset(-1, 0),
              end: const Offset(-0.5, -1),
            ),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(
              begin: const Offset(-0.5, -1),
              end: const Offset(0, 0),
            ),
            weight: 1,
          ),
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

  /// Creates an animated shape (circle or ring) that follows a specified path.
  ///
  /// The [size] parameter defines the container size for calculating translations.
  /// The [circleSize] parameter defines the size of the shape.
  /// The [animation] parameter controls the movement of the shape.
  /// The [index] parameter is used to determine the shape's color from the theme.
  AnimatedBuilder _buildAnimatedRing(
    Size size,
    double circleSize,
    Animation<Offset>? animation,
    int index,
  ) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, child) {
        return Transform(
          transform: Matrix4.translationValues(
            animation!.value.dx * (size.width - circleSize),
            animation.value.dy * (size.height - circleSize),
            0.0,
          ),
          child: child,
        );
      },
      child: IndicatorShapeWidget(
        shape: widget.isFilled ? Shape.circle : Shape.ring,
        index: index,
      ),
    );
  }
}

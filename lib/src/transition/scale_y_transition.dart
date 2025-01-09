import 'package:flutter/material.dart';

/// A widget that scales its child along the Y-axis based on an animation value.
///
/// This widget is similar to [ScaleTransition] but only affects the vertical scale.
/// It's useful for animations that need to stretch or compress a widget vertically
/// while maintaining its horizontal dimensions.
///
/// Example usage:
/// ```dart
/// ScaleYTransition(
///   scaleY: animation,
///   child: Container(
///     width: 100,
///     height: 100,
///     color: Colors.blue,
///   ),
/// )
/// ```
final class ScaleYTransition extends AnimatedWidget {
  /// Creates a vertical scale transition.
  ///
  /// The [scaleY] animation must not be null. If [alignment] is null,
  /// the transition will be centered.
  const ScaleYTransition({
    super.key,
    required Animation<double> scaleY,
    this.alignment = Alignment.center,
    this.child,
  }) : super(listenable: scaleY);

  /// The animation that controls the vertical scale of the child.
  ///
  /// If the current value of the animation is v, the child will be scaled by v
  /// in the vertical axis.
  Animation<double> get scaleY => listenable as Animation<double>;

  /// The alignment of the scaling origin relative to the child.
  ///
  /// The default value is [Alignment.center], which means the scaling will be
  /// centered on the child.
  final Alignment alignment;

  /// The widget below this widget in the tree.
  ///
  /// This widget will be scaled vertically based on the [scaleY] animation.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final double scaleYValue = scaleY.value;
    final Matrix4 transform = Matrix4.identity()..scale(1.0, scaleYValue, 1.0);
    return Transform(
      transform: transform,
      alignment: alignment,
      child: child,
    );
  }
}

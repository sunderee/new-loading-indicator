import 'dart:math';

import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays a triangle rotating in 3D space.
///
/// The animation consists of a triangle that rotates around both X and Y axes,
/// creating a complex 3D spinning effect. The animation is divided into four phases:
/// * Phase 1 (0-25%): X-axis rotation from 0° to 180°
/// * Phase 2 (25-50%): Y-axis rotation from 0° to 180°
/// * Phase 3 (50-75%): X-axis rotation from 180° back to 0°
/// * Phase 4 (75-100%): Y-axis rotation from 180° back to 0°
///
/// The complete animation cycle takes 3000 milliseconds, with each phase taking
/// 750 milliseconds. The animation uses a custom cubic curve (0.09, 0.57, 0.49, 0.9)
/// for smooth transitions between phases.
class TriangleSkewSpin extends StatefulWidget {
  /// Creates a triangle skew spin loading indicator.
  const TriangleSkewSpin({super.key});

  @override
  State<TriangleSkewSpin> createState() => _TriangleSkewSpinState();
}

class _TriangleSkewSpinState extends State<TriangleSkewSpin>
    with SingleTickerProviderStateMixin, IndicatorController {
  static const _animationDuration = Duration(seconds: 3);
  static const _cubicCurve = Cubic(0.09, 0.57, 0.49, 0.9);
  static const _perspective = 0.006;

  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  List<AnimationController> get animationControllers => [_animationController];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );
    _animation =
        TweenSequence([
          TweenSequenceItem(
            tween: Tween(
              begin: const Offset(0.0, 0.0),
              end: const Offset(0.0, pi),
            ),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(
              begin: const Offset(0.0, pi),
              end: const Offset(pi, pi),
            ),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(
              begin: const Offset(pi, pi),
              end: const Offset(pi, 0.0),
            ),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(
              begin: const Offset(pi, 0.0),
              end: const Offset(0.0, 0.0),
            ),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(parent: _animationController, curve: _cubicCurve),
        );
    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      child: const IndicatorShapeWidget(shape: Shape.triangle),
      builder: (_, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, _perspective) // Add perspective for 3D effect
            ..rotateX(_animation.value.dx)
            ..rotateY(_animation.value.dy),
          child: child,
        );
      },
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays a spinning square with a 3D effect.
///
/// The animation consists of a square that rotates in 3D space, creating a complex
/// spinning effect. The animation is divided into four phases:
/// * Phase 1 (0-25%): X-axis rotation from 0° to 180°
/// * Phase 2 (25-50%): Y-axis rotation from 0° to 180°
/// * Phase 3 (50-75%): X-axis rotation from 180° back to 0°
/// * Phase 4 (75-100%): Y-axis rotation from 180° to 360°
///
/// The complete animation cycle takes 3000 milliseconds, with each phase taking
/// 750 milliseconds. The animation uses a custom cubic curve (0.09, 0.57, 0.49, 0.9)
/// for smooth transitions between phases.
class SquareSpin extends StatefulWidget {
  /// Creates a square spin loading indicator.
  const SquareSpin({super.key});

  @override
  State<SquareSpin> createState() => _SquareSpinState();
}

class _SquareSpinState extends State<SquareSpin>
    with SingleTickerProviderStateMixin, IndicatorController {
  static const _animationDuration = Duration(milliseconds: 3000);
  static const _cubicCurve = Cubic(0.09, 0.57, 0.49, 0.9);
  static const _perspective = 0.006;

  late AnimationController _animationController;
  late Animation<double> _xAnimation;
  late Animation<double> _yAnimation;
  late Animation<double> _xAnimation2;
  late Animation<double> _yAnimation2;

  @override
  List<AnimationController> get animationControllers => [_animationController];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );

    // First phase: X-axis rotation (0-25%)
    _xAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.25, curve: _cubicCurve),
      ),
    );

    // Second phase: Y-axis rotation (25-50%)
    _yAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.25, 0.5, curve: _cubicCurve),
      ),
    );

    // Third phase: X-axis rotation back (50-75%)
    _xAnimation2 = Tween<double>(begin: pi, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 0.75, curve: _cubicCurve),
      ),
    );

    // Fourth phase: Y-axis rotation completion (75-100%)
    _yAnimation2 = Tween<double>(begin: pi, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.75, 1, curve: _cubicCurve),
      ),
    );

    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      child: const IndicatorShapeWidget(shape: Shape.rectangle),
      builder: (_, child) {
        late double x, y;
        if (_animationController.value < 0.5) {
          x = _xAnimation.value;
          y = _yAnimation.value;
        } else {
          x = _xAnimation2.value;
          y = _yAnimation2.value;
        }
        return Transform(
          alignment: Alignment.center,
          transform:
              Matrix4.identity()
                ..setEntry(3, 2, _perspective) // Add perspective for 3D effect
                ..rotateX(x)
                ..rotateY(y),
          child: child,
        );
      },
    );
  }
}

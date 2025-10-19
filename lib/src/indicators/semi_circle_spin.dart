import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

/// A loading indicator that displays a spinning semi-circle.
///
/// The animation consists of a semi-circle that rotates continuously, creating
/// a smooth spinning effect. The rotation is divided into two phases:
/// * First half: Rotation from 0° to 180° (0.0 to 0.5 turns)
/// * Second half: Rotation from 180° to 360° (0.5 to 1.0 turns)
///
/// The complete animation cycle takes 600 milliseconds, with each phase taking
/// 300 milliseconds. The animation uses a linear curve for smooth continuous rotation.
class SemiCircleSpin extends StatefulWidget {
  /// Creates a semi-circle spin loading indicator.
  const SemiCircleSpin({super.key});

  @override
  State<SemiCircleSpin> createState() => _SemiCircleSpinState();
}

class _SemiCircleSpinState extends State<SemiCircleSpin>
    with SingleTickerProviderStateMixin, IndicatorController {
  static const _animationDuration = Duration(milliseconds: 600);

  late AnimationController _animationController;
  late Animation<double> _animation;

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
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.5), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.linear),
        );
    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animation,
      child: const IndicatorShapeWidget(shape: Shape.circleSemi),
    );
  }
}

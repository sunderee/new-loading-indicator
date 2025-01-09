import 'package:flutter/material.dart';

import 'decorate/decorate.dart';
import 'indicators/audio_equalizer.dart';
import 'indicators/ball_beat.dart';
import 'indicators/ball_clip_rotate.dart';
import 'indicators/ball_clip_rotate_multiple.dart';
import 'indicators/ball_clip_rotate_pulse.dart';
import 'indicators/ball_grid_beat.dart';
import 'indicators/ball_grid_pulse.dart';
import 'indicators/ball_pulse.dart';
import 'indicators/ball_pulse_rise.dart';
import 'indicators/ball_pulse_sync.dart';
import 'indicators/ball_rotate.dart';
import 'indicators/ball_rotate_chase.dart';
import 'indicators/ball_scale.dart';
import 'indicators/ball_scale_multiple.dart';
import 'indicators/ball_scale_ripple.dart';
import 'indicators/ball_scale_ripple_multiple.dart';
import 'indicators/ball_spin_fade_loader.dart';
import 'indicators/ball_triangle_path.dart';
import 'indicators/ball_triangle_path_colored.dart';
import 'indicators/ball_zig_zag.dart';
import 'indicators/ball_zig_zag_deflect.dart';
import 'indicators/circle_stroke_spin.dart';
import 'indicators/cube_transition.dart';
import 'indicators/line_scale.dart';
import 'indicators/line_scale_party.dart';
import 'indicators/line_scale_pulse_out.dart';
import 'indicators/line_scale_pulse_out_rapid.dart';
import 'indicators/line_spin_fade_loader.dart';
import 'indicators/orbit.dart';
import 'indicators/pacman.dart';
import 'indicators/semi_circle_spin.dart';
import 'indicators/square_spin.dart';
import 'indicators/triangle_skew_spin.dart';

/// Enumerates 34 different animation types available in the library.
enum Indicator {
  ballPulse,
  ballGridPulse,
  ballClipRotate,
  squareSpin,
  ballClipRotatePulse,
  ballClipRotateMultiple,
  ballPulseRise,
  ballRotate,
  cubeTransition,
  ballZigZag,
  ballZigZagDeflect,
  ballTrianglePath,
  ballTrianglePathColored,
  ballTrianglePathColoredFilled,
  ballScale,
  lineScale,
  lineScaleParty,
  ballScaleMultiple,
  ballPulseSync,
  ballBeat,
  lineScalePulseOut,
  lineScalePulseOutRapid,
  ballScaleRipple,
  ballScaleRippleMultiple,
  ballSpinFadeLoader,
  lineSpinFadeLoader,
  triangleSkewSpin,
  pacman,
  ballGridBeat,
  semiCircleSpin,
  ballRotateChase,
  orbit,
  audioEqualizer,
  circleStrokeSpin,
}

/// A widget that displays various loading animations.
final class LoadingIndicator extends StatelessWidget {
  /// The type of loading animation to display.
  final Indicator indicatorType;

  /// The colors used to draw the shape. If not provided, uses the primary color from the current theme.
  final List<Color>? colors;

  /// The background color of the container. Defaults to transparent.
  final Color? backgroundColor;

  /// The stroke width of lines in the animation.
  final double? strokeWidth;

  /// The background color for shapes with cut edges.
  final Color? pathBackgroundColor;

  /// Controls the animation state. When true, the animation is paused. Defaults to false.
  final bool pause;

  const LoadingIndicator({
    super.key,
    required this.indicatorType,
    this.colors,
    this.backgroundColor,
    this.strokeWidth,
    this.pathBackgroundColor,
    this.pause = false,
  });

  @override
  Widget build(BuildContext context) {
    if (indicatorType == Indicator.circleStrokeSpin && pause) {
      debugPrint(
          "LoadingIndicator: it will not take any effect when set pause:true on ${Indicator.circleStrokeSpin}");
    }
    List<Color> safeColors = colors == null || colors!.isEmpty
        ? [Theme.of(context).primaryColor]
        : colors!;
    return DecorateContext(
      decorateData: DecorateData(
        indicator: indicatorType,
        colors: safeColors,
        strokeWidth: strokeWidth,
        pathBackgroundColor: pathBackgroundColor,
        pause: pause,
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          color: backgroundColor,
          child: _buildIndicator(),
        ),
      ),
    );
  }

  // Return the animation indicator.
  Widget _buildIndicator() => switch (indicatorType) {
        Indicator.ballPulse => const BallPulse(),
        Indicator.ballGridPulse => const BallGridPulse(),
        Indicator.ballClipRotate => const BallClipRotate(),
        Indicator.squareSpin => const SquareSpin(),
        Indicator.ballClipRotatePulse => const BallClipRotatePulse(),
        Indicator.ballClipRotateMultiple => const BallClipRotateMultiple(),
        Indicator.ballPulseRise => const BallPulseRise(),
        Indicator.ballRotate => const BallRotate(),
        Indicator.cubeTransition => const CubeTransition(),
        Indicator.ballZigZag => const BallZigZag(),
        Indicator.ballZigZagDeflect => const BallZigZagDeflect(),
        Indicator.ballTrianglePath => const BallTrianglePath(),
        Indicator.ballTrianglePathColored => const BallTrianglePathColored(),
        Indicator.ballTrianglePathColoredFilled =>
          const BallTrianglePathColored(isFilled: true),
        Indicator.ballScale => const BallScale(),
        Indicator.lineScale => const LineScale(),
        Indicator.lineScaleParty => const LineScaleParty(),
        Indicator.ballScaleMultiple => const BallScaleMultiple(),
        Indicator.ballPulseSync => const BallPulseSync(),
        Indicator.ballBeat => const BallBeat(),
        Indicator.lineScalePulseOut => const LineScalePulseOut(),
        Indicator.lineScalePulseOutRapid => const LineScalePulseOutRapid(),
        Indicator.ballScaleRipple => const BallScaleRipple(),
        Indicator.ballScaleRippleMultiple => const BallScaleRippleMultiple(),
        Indicator.ballSpinFadeLoader => const BallSpinFadeLoader(),
        Indicator.lineSpinFadeLoader => const LineSpinFadeLoader(),
        Indicator.triangleSkewSpin => const TriangleSkewSpin(),
        Indicator.pacman => const Pacman(),
        Indicator.ballGridBeat => const BallGridBeat(),
        Indicator.semiCircleSpin => const SemiCircleSpin(),
        Indicator.ballRotateChase => const BallRotateChase(),
        Indicator.orbit => const Orbit(),
        Indicator.audioEqualizer => const AudioEqualizer(),
        Indicator.circleStrokeSpin => const CircleStrokeSpin(),
      };
}

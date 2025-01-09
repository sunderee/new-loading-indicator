import 'dart:math';

import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';

/// The minimum size in logical pixels for any indicator.
const double _kMinIndicatorSize = 36.0;

/// Defines the basic shapes available for loading indicators.
/// These shapes serve as building blocks for more complex loading animations.
enum Shape {
  /// A filled circle shape
  circle,

  /// A three-quarter ring shape (spans 270 degrees)
  ringThirdFour,

  /// A rectangular shape
  rectangle,

  /// A ring split into two vertical halves
  ringTwoHalfVertical,

  /// A complete ring shape
  ring,

  /// A line shape with rounded ends
  line,

  /// A triangular shape
  triangle,

  /// An arc shape that requires additional data parameter
  arc,

  /// A semi-circular shape
  circleSemi,
}

/// A widget that renders basic shapes used in loading indicators.
///
/// This widget serves as a wrapper for the [_ShapePainter] and handles the rendering
/// of various basic shapes defined in the [Shape] enum. It uses [CustomPaint] to
/// draw the shapes and supports customization through colors and dimensions.
class IndicatorShapeWidget extends StatelessWidget {
  /// The type of shape to render
  final Shape shape;

  /// Additional data required for certain shapes (e.g., arc angle)
  final double? data;

  /// The index of this shape when multiple shapes are used in an indicator.
  /// Used for color cycling in multi-shape indicators.
  final int index;

  const IndicatorShapeWidget({
    super.key,
    required this.shape,
    this.data,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final DecorateData decorateData = DecorateContext.of(context)!.decorateData;
    final color = decorateData.colors[index % decorateData.colors.length];

    return Container(
      constraints: const BoxConstraints(
        minWidth: _kMinIndicatorSize,
        minHeight: _kMinIndicatorSize,
      ),
      child: CustomPaint(
        painter: _ShapePainter(
          color,
          shape,
          data,
          decorateData.strokeWidth,
          pathColor: decorateData.pathBackgroundColor,
        ),
      ),
    );
  }
}

/// A custom painter that handles the actual drawing of indicator shapes.
///
/// This painter supports various shape types and customization options including:
/// - Different shape types defined in [Shape] enum
/// - Custom colors and stroke widths
/// - Background paths for certain shapes
/// - Shape-specific data parameters
class _ShapePainter extends CustomPainter {
  final Color color;
  final Shape shape;
  final Paint _paint;
  final double? data;
  final double strokeWidth;
  final Color? pathColor;

  _ShapePainter(
    this.color,
    this.shape,
    this.data,
    this.strokeWidth, {
    this.pathColor,
  })  : _paint = Paint()..isAntiAlias = true,
        super();

  @override
  void paint(Canvas canvas, Size size) {
    switch (shape) {
      case Shape.circle:
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          size.shortestSide / 2,
          _paint,
        );
        break;
      case Shape.ringThirdFour:
        if (pathColor != null) {
          _paint
            ..color = pathColor!
            ..strokeWidth = strokeWidth
            ..style = PaintingStyle.stroke;
          canvas.drawCircle(
            Offset(size.width / 2, size.height / 2),
            size.shortestSide / 2,
            _paint,
          );
        }
        _paint
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;
        canvas.drawArc(
          Rect.fromCircle(
            center: Offset(size.width / 2, size.height / 2),
            radius: size.shortestSide / 2,
          ),
          -3 * pi / 4,
          3 * pi / 2,
          false,
          _paint,
        );
        break;
      case Shape.rectangle:
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawRect(Offset.zero & size, _paint);
        break;
      case Shape.ringTwoHalfVertical:
        _paint
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;
        final rect = Rect.fromLTWH(
            size.width / 4, size.height / 4, size.width / 2, size.height / 2);
        canvas.drawArc(rect, -3 * pi / 4, pi / 2, false, _paint);
        canvas.drawArc(rect, 3 * pi / 4, -pi / 2, false, _paint);
        break;
      case Shape.ring:
        _paint
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(Offset(size.width / 2, size.height / 2),
            size.shortestSide / 2, _paint);
        break;
      case Shape.line:
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(0, 0, size.width, size.height),
                Radius.circular(size.shortestSide / 2)),
            _paint);
        break;
      case Shape.triangle:
        final offsetY = size.height / 4;
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        Path path = Path()
          ..moveTo(0, size.height - offsetY)
          ..lineTo(size.width / 2, size.height / 2 - offsetY)
          ..lineTo(size.width, size.height - offsetY)
          ..close();
        canvas.drawPath(path, _paint);
        break;
      case Shape.arc:
        assert(data != null);
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawArc(
            Offset.zero & size, data!, pi * 2 - 2 * data!, true, _paint);
        break;
      case Shape.circleSemi:
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawArc(Offset.zero & size, -pi * 6, -2 * pi / 3, false, _paint);
        break;
    }
  }

  @override
  bool shouldRepaint(_ShapePainter oldDelegate) =>
      shape != oldDelegate.shape ||
      color != oldDelegate.color ||
      data != oldDelegate.data ||
      strokeWidth != oldDelegate.strokeWidth ||
      pathColor != oldDelegate.pathColor;
}

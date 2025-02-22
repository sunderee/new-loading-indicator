import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/indicators/ball_clip_rotate_pulse.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

void main() {
  group('BallClipRotatePulse', () {
    testWidgets('renders correct number of shapes and transforms', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballClipRotatePulse,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallClipRotatePulse(),
          ),
        ),
      );

      // Should find 2 shapes (outer ring and inner circle)
      expect(find.byType(IndicatorShapeWidget), findsNWidgets(2));

      // Should find 2 Transform widgets (one Transform and one Transform.scale)
      expect(find.byType(Transform), findsNWidgets(2));

      // Should find 1 Stack widget
      expect(find.byType(Stack), findsNWidgets(1));
    });

    testWidgets('shapes use correct types', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballClipRotatePulse,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallClipRotatePulse(),
          ),
        ),
      );

      // Get all shapes
      final shapes =
          tester
              .widgetList<IndicatorShapeWidget>(
                find.byType(IndicatorShapeWidget),
              )
              .toList();

      // Verify outer ring uses ringTwoHalfVertical shape
      expect(shapes[0].shape, equals(Shape.ringTwoHalfVertical));
      expect(shapes[0].index, equals(0));

      // Verify inner circle uses circle shape
      expect(shapes[1].shape, equals(Shape.circle));
      expect(shapes[1].index, equals(1));
    });

    testWidgets('responds to pause state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballClipRotatePulse,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallClipRotatePulse(),
          ),
        ),
      );

      // Get initial transforms
      final initialTransforms =
          tester.widgetList<Transform>(find.byType(Transform)).toList();

      // Get initial values
      final initialValues =
          initialTransforms
              .map(
                (t) => {
                  'rotation': t.transform.getRotation()[0],
                  'scale': t.transform.getMaxScaleOnAxis(),
                },
              )
              .toList();

      // Let animations run
      await tester.pump(const Duration(milliseconds: 500));

      // Values should have changed
      final runningTransforms =
          tester.widgetList<Transform>(find.byType(Transform)).toList();
      final runningValues =
          runningTransforms
              .map(
                (t) => {
                  'rotation': t.transform.getRotation()[0],
                  'scale': t.transform.getMaxScaleOnAxis(),
                },
              )
              .toList();
      expect(runningValues, isNot(equals(initialValues)));

      // Update to paused state
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballClipRotatePulse,
              colors: const [Colors.blue],
              pause: true,
            ),
            child: const BallClipRotatePulse(),
          ),
        ),
      );

      // Get values after pause
      final pausedTransforms =
          tester.widgetList<Transform>(find.byType(Transform)).toList();
      final pausedValues =
          pausedTransforms
              .map(
                (t) => {
                  'rotation': t.transform.getRotation()[0],
                  'scale': t.transform.getMaxScaleOnAxis(),
                },
              )
              .toList();

      // Let some time pass
      await tester.pump(const Duration(milliseconds: 500));

      // Get values after waiting while paused
      final stillPausedTransforms =
          tester.widgetList<Transform>(find.byType(Transform)).toList();
      final stillPausedValues =
          stillPausedTransforms
              .map(
                (t) => {
                  'rotation': t.transform.getRotation()[0],
                  'scale': t.transform.getMaxScaleOnAxis(),
                },
              )
              .toList();

      // Verify values haven't changed while paused
      expect(
        stillPausedValues,
        equals(pausedValues),
        reason: 'Animation values should not change while paused',
      );
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/indicators/ball_clip_rotate_multiple.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

void main() {
  group('BallClipRotateMultiple', () {
    testWidgets('renders correct number of rings and transforms', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballClipRotateMultiple,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallClipRotateMultiple(),
          ),
        ),
      );

      // Should find 2 rings (IndicatorShapeWidget)
      expect(find.byType(IndicatorShapeWidget), findsNWidgets(2));

      // Should find 2 Transform widgets for rotation and scaling
      expect(find.byType(Transform), findsNWidgets(2));

      // Should find 1 Stack widget
      expect(find.byType(Stack), findsNWidgets(1));

      // Should find 1 Positioned widget for inner ring
      expect(find.byType(Positioned), findsNWidgets(1));
    });

    testWidgets('rings use correct shape', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballClipRotateMultiple,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallClipRotateMultiple(),
          ),
        ),
      );

      // Verify all rings use ringTwoHalfVertical shape
      final rings = tester.widgetList<IndicatorShapeWidget>(
        find.byType(IndicatorShapeWidget),
      );
      for (final ring in rings) {
        expect(ring.shape, equals(Shape.ringTwoHalfVertical));
      }
    });

    testWidgets('responds to pause state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballClipRotateMultiple,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallClipRotateMultiple(),
          ),
        ),
      );

      // Get initial transforms
      final initialTransforms = tester
          .widgetList<Transform>(find.byType(Transform))
          .toList();

      // Get initial values
      final initialValues = initialTransforms
          .map(
            (t) => {
              'rotation': t.transform.getRotation(),
              'scale': t.transform.getMaxScaleOnAxis(),
            },
          )
          .toList();

      // Let animations run
      await tester.pump(const Duration(milliseconds: 500));

      // Values should have changed
      final runningTransforms = tester
          .widgetList<Transform>(find.byType(Transform))
          .toList();
      final runningValues = runningTransforms
          .map(
            (t) => {
              'rotation': t.transform.getRotation(),
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
              indicator: Indicator.ballClipRotateMultiple,
              colors: const [Colors.blue],
              pause: true,
            ),
            child: const BallClipRotateMultiple(),
          ),
        ),
      );

      // Get values after pause
      final pausedTransforms = tester
          .widgetList<Transform>(find.byType(Transform))
          .toList();
      final pausedValues = pausedTransforms
          .map(
            (t) => {
              'rotation': t.transform.getRotation(),
              'scale': t.transform.getMaxScaleOnAxis(),
            },
          )
          .toList();

      // Let some time pass
      await tester.pump(const Duration(milliseconds: 500));

      // Get values after waiting while paused
      final stillPausedTransforms = tester
          .widgetList<Transform>(find.byType(Transform))
          .toList();
      final stillPausedValues = stillPausedTransforms
          .map(
            (t) => {
              'rotation': t.transform.getRotation(),
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

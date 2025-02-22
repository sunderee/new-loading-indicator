import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/indicators/ball_clip_rotate.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

void main() {
  group('BallClipRotate', () {
    testWidgets('renders correct number of shapes and transforms', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballClipRotate,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallClipRotate(),
          ),
        ),
      );

      // Should find 1 Transform widget for rotation and scaling
      expect(find.byType(Transform), findsNWidgets(1));

      // Should find 1 shape (three-quarter ring)
      expect(find.byType(IndicatorShapeWidget), findsNWidgets(1));
    });

    testWidgets('shape uses correct type', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballClipRotate,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallClipRotate(),
          ),
        ),
      );

      // Verify shape is a three-quarter ring
      final shape = tester.widget<IndicatorShapeWidget>(
        find.byType(IndicatorShapeWidget),
      );
      expect(shape.shape, equals(Shape.ringThirdFour));
    });

    testWidgets('animations are properly configured', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballClipRotate,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallClipRotate(),
          ),
        ),
      );

      // Initial pump to start animations
      await tester.pump();

      // Get initial transform
      final initialTransform = tester.widget<Transform>(find.byType(Transform));

      // Get initial values
      final initialRotation = initialTransform.transform.getRotation()[0];
      final initialScale = initialTransform.transform.getMaxScaleOnAxis();

      // Let animations run for a short duration
      await tester.pump(const Duration(milliseconds: 100));

      // Get transform after short delay
      final shortDelayTransform = tester.widget<Transform>(
        find.byType(Transform),
      );

      // Get values after short delay
      final shortDelayRotation = shortDelayTransform.transform.getRotation()[0];
      final shortDelayScale = shortDelayTransform.transform.getMaxScaleOnAxis();

      // Verify initial animation changes
      expect(
        shortDelayRotation,
        isNot(equals(initialRotation)),
        reason: 'Ring should have started rotating',
      );
      expect(
        shortDelayScale,
        isNot(equals(initialScale)),
        reason: 'Ring scale should have started changing',
      );

      // Let animations run longer
      await tester.pump(const Duration(milliseconds: 300));

      // Get transform after longer delay
      final longerDelayTransform = tester.widget<Transform>(
        find.byType(Transform),
      );

      // Get values after longer delay
      final longerDelayRotation =
          longerDelayTransform.transform.getRotation()[0];
      final longerDelayScale =
          longerDelayTransform.transform.getMaxScaleOnAxis();

      // Verify continued animation
      expect(
        longerDelayRotation,
        isNot(equals(shortDelayRotation)),
        reason: 'Ring should continue rotating',
      );
      expect(
        longerDelayScale,
        isNot(equals(shortDelayScale)),
        reason: 'Ring scale should continue changing',
      );

      // Verify scale stays within bounds throughout animation
      expect(
        shortDelayScale >= 0.6 && shortDelayScale <= 1.0,
        isTrue,
        reason: 'Ring scale should stay between 0.6 and 1.0',
      );
      expect(
        longerDelayScale >= 0.6 && longerDelayScale <= 1.0,
        isTrue,
        reason: 'Ring scale should stay between 0.6 and 1.0',
      );
    });

    testWidgets('responds to pause state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballClipRotate,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallClipRotate(),
          ),
        ),
      );

      // Get initial transform
      final initialTransform = tester.widget<Transform>(find.byType(Transform));

      // Get initial values
      final initialValues = {
        'rotation': initialTransform.transform.getRotation()[0],
        'scale': initialTransform.transform.getMaxScaleOnAxis(),
      };

      // Let animations run
      await tester.pump(const Duration(milliseconds: 375));

      // Values should have changed
      final runningTransform = tester.widget<Transform>(find.byType(Transform));
      final runningValues = {
        'rotation': runningTransform.transform.getRotation()[0],
        'scale': runningTransform.transform.getMaxScaleOnAxis(),
      };
      expect(runningValues, isNot(equals(initialValues)));

      // Update to paused state
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballClipRotate,
              colors: const [Colors.blue],
              pause: true,
            ),
            child: const BallClipRotate(),
          ),
        ),
      );

      // Get values after pause
      final pausedTransform = tester.widget<Transform>(find.byType(Transform));
      final pausedValues = {
        'rotation': pausedTransform.transform.getRotation()[0],
        'scale': pausedTransform.transform.getMaxScaleOnAxis(),
      };

      // Let some time pass
      await tester.pump(const Duration(milliseconds: 375));

      // Get values after waiting while paused
      final stillPausedTransform = tester.widget<Transform>(
        find.byType(Transform),
      );
      final stillPausedValues = {
        'rotation': stillPausedTransform.transform.getRotation()[0],
        'scale': stillPausedTransform.transform.getMaxScaleOnAxis(),
      };

      // Verify values haven't changed while paused
      expect(
        stillPausedValues,
        equals(pausedValues),
        reason: 'Animation values should not change while paused',
      );
    });
  });
}

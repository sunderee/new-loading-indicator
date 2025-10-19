import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/indicators/ball_pulse_rise.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

void main() {
  group('BallPulseRise', () {
    testWidgets('renders correct number of shapes and transforms', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballPulseRise,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallPulseRise(),
          ),
        ),
      );

      // Should find 5 circles
      expect(find.byType(IndicatorShapeWidget), findsNWidgets(5));

      // Should find 5 Transform widgets
      expect(find.byType(Transform), findsNWidgets(5));

      // Should find 5 Positioned widgets
      expect(find.byType(Positioned), findsNWidgets(5));

      // Should find 1 Stack
      expect(find.byType(Stack), findsNWidgets(1));
    });

    testWidgets('shapes use correct type and indices', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballPulseRise,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallPulseRise(),
          ),
        ),
      );

      // Get all shapes
      final shapes = tester
          .widgetList<IndicatorShapeWidget>(find.byType(IndicatorShapeWidget))
          .toList();

      // Verify all shapes are circles with correct indices
      for (int i = 0; i < 5; i++) {
        expect(shapes[i].shape, equals(Shape.circle));
        expect(shapes[i].index, equals(i));
      }
    });

    testWidgets('circles are properly positioned', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 100,
            height: 100,
            child: DecorateContext(
              decorateData: DecorateData(
                indicator: Indicator.ballPulseRise,
                colors: const [Colors.blue],
                pause: false,
              ),
              child: const BallPulseRise(),
            ),
          ),
        ),
      );

      // Get all positioned widgets
      final positions = tester
          .widgetList<Positioned>(find.byType(Positioned))
          .toList();

      // Verify horizontal spacing is equal
      final lefts = positions.map((p) => p.left ?? 0.0).toList();
      final widths = positions.map((p) => p.width ?? 0.0).toList();
      final spacing = lefts[1] - (lefts[0] + widths[0]);

      for (int i = 1; i < positions.length; i++) {
        final currentSpacing = lefts[i] - (lefts[i - 1] + widths[i - 1]);
        expect(
          (currentSpacing - spacing).abs() < 0.001,
          isTrue,
          reason: 'Spacing between circles should be equal',
        );
      }

      // Verify all circles have the same size
      final size = widths[0];
      for (final width in widths) {
        expect(
          (width - size).abs() < 0.001,
          isTrue,
          reason: 'All circles should have the same size',
        );
      }

      // Verify all circles are vertically centered
      final centerY = positions[0].top! + widths[0] / 2;
      for (final pos in positions) {
        final positionCenterY = pos.top! + (pos.width ?? 0.0) / 2;
        expect(
          (positionCenterY - centerY).abs() < 0.001,
          isTrue,
          reason: 'All circles should be vertically centered',
        );
      }
    });

    testWidgets('animations are properly configured', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballPulseRise,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallPulseRise(),
          ),
        ),
      );

      // Initial pump to start animations
      await tester.pump();

      // Get initial transforms
      final initialTransforms = tester
          .widgetList<Transform>(find.byType(Transform))
          .toList();

      // Get initial values
      final initialValues = initialTransforms
          .map(
            (t) => {
              'scale': t.transform.getMaxScaleOnAxis(),
              'translateY': t.transform.getTranslation().y,
            },
          )
          .toList();

      // Let animations run for a short duration
      await tester.pump(const Duration(milliseconds: 100));

      // Get transforms after short delay
      final shortDelayTransforms = tester
          .widgetList<Transform>(find.byType(Transform))
          .toList();

      // Get values after short delay
      final shortDelayValues = shortDelayTransforms
          .map(
            (t) => {
              'scale': t.transform.getMaxScaleOnAxis(),
              'translateY': t.transform.getTranslation().y,
            },
          )
          .toList();

      // Verify that animations have started
      for (int i = 0; i < 5; i++) {
        expect(
          shortDelayValues[i],
          isNot(equals(initialValues[i])),
          reason: 'Circle $i should have started animating',
        );
      }

      // Let animations run longer
      await tester.pump(const Duration(milliseconds: 400));

      // Get transforms after longer delay
      final longerDelayTransforms = tester
          .widgetList<Transform>(find.byType(Transform))
          .toList();

      // Get values after longer delay
      final longerDelayValues = longerDelayTransforms
          .map(
            (t) => {
              'scale': t.transform.getMaxScaleOnAxis(),
              'translateY': t.transform.getTranslation().y,
            },
          )
          .toList();

      // Verify scale bounds for odd and even circles
      for (int i = 0; i < 5; i++) {
        final scale = longerDelayValues[i]['scale'] as double;
        if (i.isEven) {
          expect(
            scale >= 0.4 && scale <= 1.1,
            isTrue,
            reason: 'Even circle scale should stay between 0.4 and 1.1',
          );
        } else {
          expect(
            scale >= 0.4 && scale <= 1.1,
            isTrue,
            reason: 'Odd circle scale should stay between 0.4 and 1.1',
          );
        }
      }

      // Verify that even and odd circles move in opposite directions
      for (int i = 0; i < 4; i++) {
        if (i.isEven == (i + 1).isEven) continue;
        final currentY = longerDelayValues[i]['translateY'] as double;
        final nextY = longerDelayValues[i + 1]['translateY'] as double;
        expect(
          currentY * nextY <= 0,
          isTrue,
          reason: 'Adjacent circles should move in opposite directions',
        );
      }
    });

    testWidgets('responds to pause state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballPulseRise,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallPulseRise(),
          ),
        ),
      );

      // Get initial values
      final initialValues = tester
          .widgetList<Transform>(find.byType(Transform))
          .map(
            (t) => {
              'scale': t.transform.getMaxScaleOnAxis(),
              'translateY': t.transform.getTranslation().y,
            },
          )
          .toList();

      // Let animations run
      await tester.pump(const Duration(milliseconds: 300));

      // Values should have changed
      final runningValues = tester
          .widgetList<Transform>(find.byType(Transform))
          .map(
            (t) => {
              'scale': t.transform.getMaxScaleOnAxis(),
              'translateY': t.transform.getTranslation().y,
            },
          )
          .toList();
      expect(runningValues, isNot(equals(initialValues)));

      // Update to paused state
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballPulseRise,
              colors: const [Colors.blue],
              pause: true,
            ),
            child: const BallPulseRise(),
          ),
        ),
      );

      // Get values after pause
      final pausedValues = tester
          .widgetList<Transform>(find.byType(Transform))
          .map(
            (t) => {
              'scale': t.transform.getMaxScaleOnAxis(),
              'translateY': t.transform.getTranslation().y,
            },
          )
          .toList();

      // Let some time pass
      await tester.pump(const Duration(milliseconds: 300));

      // Get values after waiting while paused
      final stillPausedValues = tester
          .widgetList<Transform>(find.byType(Transform))
          .map(
            (t) => {
              'scale': t.transform.getMaxScaleOnAxis(),
              'translateY': t.transform.getTranslation().y,
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

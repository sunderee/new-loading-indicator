import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/indicators/ball_pulse_sync.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

void main() {
  group('BallPulseSync', () {
    testWidgets('renders correct number of shapes and transforms', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballPulseSync,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallPulseSync(),
          ),
        ),
      );

      // Should find 3 circles (at even indices)
      expect(find.byType(IndicatorShapeWidget), findsNWidgets(3));

      // Should find 3 Transform.translate widgets
      expect(find.byType(Transform), findsNWidgets(3));

      // Should find 1 Row
      expect(find.byType(Row), findsNWidgets(1));
    });

    testWidgets('shapes use correct type and indices', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballPulseSync,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallPulseSync(),
          ),
        ),
      );

      // Get all shapes
      final shapes = tester
          .widgetList<IndicatorShapeWidget>(find.byType(IndicatorShapeWidget))
          .toList();

      // Verify all shapes are circles with correct indices
      for (int i = 0; i < 3; i++) {
        expect(shapes[i].shape, equals(Shape.circle));
        expect(shapes[i].index, equals(i * 2)); // Even indices: 0, 2, 4
      }
    });

    testWidgets('animations are properly configured and synchronized', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 100,
            height: 100,
            child: DecorateContext(
              decorateData: DecorateData(
                indicator: Indicator.ballPulseSync,
                colors: const [Colors.blue],
                pause: false,
              ),
              child: const BallPulseSync(),
            ),
          ),
        ),
      );

      // Initial pump to start animations
      await tester.pump();

      // Get initial transforms
      final initialTransforms = tester
          .widgetList<Transform>(find.byType(Transform))
          .toList();

      // Get initial vertical positions
      final initialPositions = initialTransforms
          .map((t) => t.transform.getTranslation().y)
          .toList();

      // Let animations run for a short duration
      await tester.pump(const Duration(milliseconds: 100));

      // Get transforms after short delay
      final shortDelayTransforms = tester
          .widgetList<Transform>(find.byType(Transform))
          .toList();

      // Get positions after short delay
      final shortDelayPositions = shortDelayTransforms
          .map((t) => t.transform.getTranslation().y)
          .toList();

      // Verify that animations have started
      for (int i = 0; i < 3; i++) {
        expect(
          shortDelayPositions[i],
          isNot(equals(initialPositions[i])),
          reason: 'Circle $i should have started animating',
        );
      }

      // Let animations run longer
      await tester.pump(const Duration(milliseconds: 300));

      // Get transforms after longer delay
      final longerDelayTransforms = tester
          .widgetList<Transform>(find.byType(Transform))
          .toList();

      // Get positions after longer delay
      final longerDelayPositions = longerDelayTransforms
          .map((t) => t.transform.getTranslation().y)
          .toList();

      // Verify that circles have different vertical positions due to phase difference
      final positions = Set<double>.from(longerDelayPositions);
      expect(
        positions.length,
        greaterThan(1),
        reason:
            'Circles should be at different vertical positions due to phase differences',
      );

      // Verify movement bounds
      for (final position in longerDelayPositions) {
        expect(
          position.abs() <= 50, // Reasonable bound for 100px height container
          isTrue,
          reason: 'Vertical movement should stay within reasonable bounds',
        );
      }
    });

    testWidgets('layout adapts to container size', (tester) async {
      const containerSize = Size(200.0, 100.0);

      await tester.pumpWidget(
        Center(
          child: SizedBox.fromSize(
            size: containerSize,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              home: DecorateContext(
                decorateData: DecorateData(
                  indicator: Indicator.ballPulseSync,
                  colors: const [Colors.blue],
                  pause: false,
                ),
                child: const BallPulseSync(),
              ),
            ),
          ),
        ),
      );

      // Find the Row widget that contains the circles
      final rowRenderBox = tester.renderObject<RenderBox>(find.byType(Row));

      // Verify that Row uses the container size
      expect(
        rowRenderBox.size.width,
        equals(containerSize.width),
        reason: 'Row should use container width',
      );

      expect(
        rowRenderBox.size.height,
        equals(containerSize.height),
        reason: 'Row should use container height',
      );
    });
  });
}

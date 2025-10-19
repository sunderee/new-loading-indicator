import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/indicators/ball_zig_zag.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

void main() {
  group('BallZigZag', () {
    testWidgets('renders correct number of shapes and transforms', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballZigZag,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallZigZag(),
          ),
        ),
      );

      // Should find 2 circles
      expect(find.byType(IndicatorShapeWidget), findsNWidgets(2));

      // Should find 2 Transform widgets
      expect(find.byType(Transform), findsNWidgets(2));

      // Should find 2 Positioned widgets
      expect(find.byType(Positioned), findsNWidgets(2));

      // Should find 1 Stack
      expect(find.byType(Stack), findsNWidgets(1));

      // Should find 1 AnimatedBuilder
      expect(
        find.descendant(
          of: find.byType(BallZigZag),
          matching: find.byType(AnimatedBuilder),
        ),
        findsOneWidget,
      );
    });

    testWidgets('shapes use correct type and indices', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballZigZag,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallZigZag(),
          ),
        ),
      );

      // Get all shapes
      final shapes = tester
          .widgetList<IndicatorShapeWidget>(find.byType(IndicatorShapeWidget))
          .toList();

      // Verify all shapes are circles with correct indices
      for (int i = 0; i < 2; i++) {
        expect(shapes[i].shape, equals(Shape.circle));
        expect(shapes[i].index, equals(i));
      }
    });

    testWidgets('circles move in opposite directions continuously', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 100,
            height: 100,
            child: DecorateContext(
              decorateData: DecorateData(
                indicator: Indicator.ballZigZag,
                colors: const [Colors.blue],
                pause: false,
              ),
              child: const BallZigZag(),
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
      final initialPositions = initialTransforms
          .map((t) => t.transform.getTranslation())
          .toList();

      // Let animations run for a short duration
      await tester.pump(const Duration(milliseconds: 200));

      // Get transforms after delay
      final delayedTransforms = tester
          .widgetList<Transform>(find.byType(Transform))
          .toList();
      final delayedPositions = delayedTransforms
          .map((t) => t.transform.getTranslation())
          .toList();

      // Verify that both circles have moved
      for (int i = 0; i < 2; i++) {
        expect(
          delayedPositions[i] != initialPositions[i],
          isTrue,
          reason: 'Circle $i should have moved',
        );
      }

      // Verify that circles move in opposite directions
      expect(
        (delayedPositions[0].x - initialPositions[0].x).sign,
        equals(-(delayedPositions[1].x - initialPositions[1].x).sign),
        reason: 'Circles should move in opposite horizontal directions',
      );

      expect(
        (delayedPositions[0].y - initialPositions[0].y).sign,
        equals(-(delayedPositions[1].y - initialPositions[1].y).sign),
        reason: 'Circles should move in opposite vertical directions',
      );

      // Let animations run longer
      await tester.pump(const Duration(milliseconds: 300));

      // Get transforms after longer delay
      final longerDelayTransforms = tester
          .widgetList<Transform>(find.byType(Transform))
          .toList();
      final longerDelayPositions = longerDelayTransforms
          .map((t) => t.transform.getTranslation())
          .toList();

      // Verify that positions have changed further
      for (int i = 0; i < 2; i++) {
        expect(
          longerDelayPositions[i] != delayedPositions[i],
          isTrue,
          reason: 'Circle $i should have continued moving',
        );
      }

      // Verify that circles are still moving in opposite directions
      expect(
        (longerDelayPositions[0].x - delayedPositions[0].x).sign,
        equals(-(longerDelayPositions[1].x - delayedPositions[1].x).sign),
        reason: 'Circles should maintain opposite horizontal movement',
      );

      expect(
        (longerDelayPositions[0].y - delayedPositions[0].y).sign,
        equals(-(longerDelayPositions[1].y - delayedPositions[1].y).sign),
        reason: 'Circles should maintain opposite vertical movement',
      );

      // Let animation complete one cycle
      await tester.pump(const Duration(milliseconds: 700));

      // Get transforms after one cycle
      final cycleTransforms = tester
          .widgetList<Transform>(find.byType(Transform))
          .toList();
      final cyclePositions = cycleTransforms
          .map((t) => t.transform.getTranslation())
          .toList();

      // Verify that animation continues without reversing
      expect(
        cyclePositions,
        isNot(equals(initialPositions)),
        reason: 'Animation should continue forward without reversing',
      );
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
                  indicator: Indicator.ballZigZag,
                  colors: const [Colors.blue],
                  pause: false,
                ),
                child: const BallZigZag(),
              ),
            ),
          ),
        ),
      );

      // Find the root widget's render box
      final renderBox = tester.renderObject<RenderBox>(find.byType(BallZigZag));

      // Verify that widget uses the container size
      expect(
        renderBox.size.width,
        equals(containerSize.width),
        reason: 'Widget should use container width',
      );

      expect(
        renderBox.size.height,
        equals(containerSize.height),
        reason: 'Widget should use container height',
      );

      // Verify circle sizes are proportional to container width
      final circleSize = containerSize.width / 5;
      final circles = tester.widgetList<Positioned>(find.byType(Positioned));
      for (final circle in circles) {
        expect(
          circle.width,
          equals(circleSize),
          reason: 'Circle width should be one-fifth of container width',
        );
        expect(
          circle.height,
          equals(circleSize),
          reason: 'Circle height should be one-fifth of container width',
        );
      }
    });
  });
}

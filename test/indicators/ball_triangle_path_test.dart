import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/indicators/ball_triangle_path.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

void main() {
  group('BallTrianglePath', () {
    testWidgets('renders correct number of shapes and transforms', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballTrianglePath,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallTrianglePath(),
          ),
        ),
      );

      // Should find 3 shapes
      expect(find.byType(IndicatorShapeWidget), findsNWidgets(3));

      // Should find 3 Transform widgets
      expect(find.byType(Transform), findsNWidgets(3));

      // Should find 3 AnimatedBuilder widgets that are children of BallTrianglePath
      final animatedBuilders = find.descendant(
        of: find.byType(BallTrianglePath),
        matching: find.byType(AnimatedBuilder),
      );
      expect(animatedBuilders, findsNWidgets(3));

      // Should find 3 Positioned widgets
      expect(find.byType(Positioned), findsNWidgets(3));

      // Should find 1 Stack
      expect(find.byType(Stack), findsNWidgets(1));
    });

    testWidgets('shapes are always rings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballTrianglePath,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallTrianglePath(),
          ),
        ),
      );

      // Get all shapes
      final shapes = tester
          .widgetList<IndicatorShapeWidget>(find.byType(IndicatorShapeWidget))
          .toList();

      // Verify all shapes are rings with correct indices
      for (int i = 0; i < 3; i++) {
        expect(shapes[i].shape, equals(Shape.ring));
        expect(shapes[i].index, equals(i));
      }
    });

    testWidgets('shapes are positioned correctly in triangle pattern', (
      tester,
    ) async {
      const containerSize = Size(200.0, 100.0);

      await tester.pumpWidget(
        Center(
          child: SizedBox.fromSize(
            size: containerSize,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              home: DecorateContext(
                decorateData: DecorateData(
                  indicator: Indicator.ballTrianglePath,
                  colors: const [Colors.blue],
                  pause: false,
                ),
                child: const BallTrianglePath(),
              ),
            ),
          ),
        ),
      );

      // Find all Positioned widgets
      final positions = tester.widgetList<Positioned>(find.byType(Positioned));
      final positionsList = positions.toList();

      // Calculate expected circle size
      final circleSize = containerSize.width / 5;

      // Verify top center position
      expect(
        positionsList[0].left,
        equals(containerSize.width / 2 - circleSize / 2),
        reason: 'Top ring should be centered horizontally',
      );
      expect(
        positionsList[0].top,
        equals(0),
        reason: 'Top ring should be at the top',
      );

      // Verify left bottom position
      expect(
        positionsList[1].left,
        equals(0),
        reason: 'Left ring should be at the left edge',
      );
      expect(
        positionsList[1].top,
        equals(containerSize.height - circleSize),
        reason: 'Left ring should be at the bottom',
      );

      // Verify right bottom position
      expect(
        positionsList[2].left,
        equals(containerSize.width - circleSize),
        reason: 'Right ring should be at the right edge',
      );
      expect(
        positionsList[2].top,
        equals(containerSize.height - circleSize),
        reason: 'Right ring should be at the bottom',
      );
    });

    testWidgets('animations move shapes along triangle edges', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 100,
            height: 100,
            child: DecorateContext(
              decorateData: DecorateData(
                indicator: Indicator.ballTrianglePath,
                colors: const [Colors.blue],
                pause: false,
              ),
              child: const BallTrianglePath(),
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
      await tester.pump(const Duration(milliseconds: 500));

      // Get transforms after delay
      final delayedTransforms = tester
          .widgetList<Transform>(find.byType(Transform))
          .toList();
      final delayedPositions = delayedTransforms
          .map((t) => t.transform.getTranslation())
          .toList();

      // Verify that positions have changed
      for (int i = 0; i < 3; i++) {
        expect(
          delayedPositions[i] != initialPositions[i],
          isTrue,
          reason: 'Ring $i should have moved',
        );
      }

      // Let animations run longer
      await tester.pump(const Duration(milliseconds: 1000));

      // Get transforms after longer delay
      final longerDelayTransforms = tester
          .widgetList<Transform>(find.byType(Transform))
          .toList();
      final longerDelayPositions = longerDelayTransforms
          .map((t) => t.transform.getTranslation())
          .toList();

      // Verify that positions have changed further
      for (int i = 0; i < 3; i++) {
        expect(
          longerDelayPositions[i] != delayedPositions[i],
          isTrue,
          reason: 'Ring $i should have continued moving',
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
                  indicator: Indicator.ballTrianglePath,
                  colors: const [Colors.blue],
                  pause: false,
                ),
                child: const BallTrianglePath(),
              ),
            ),
          ),
        ),
      );

      // Find the root widget's render box
      final renderBox = tester.renderObject<RenderBox>(
        find.byType(BallTrianglePath),
      );

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

      // Verify ring sizes are proportional to container width
      final circleSize = containerSize.width / 5;
      final shapes = tester.widgetList<Positioned>(find.byType(Positioned));
      for (final shape in shapes) {
        expect(
          shape.width,
          equals(circleSize),
          reason: 'Ring width should be one-fifth of container width',
        );
        expect(
          shape.height,
          equals(circleSize),
          reason: 'Ring height should be one-fifth of container width',
        );
      }
    });
  });
}

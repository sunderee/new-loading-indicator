import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/indicators/ball_triangle_path_colored.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

void main() {
  group('BallTrianglePathColored', () {
    testWidgets('renders correct number of shapes and transforms', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballTrianglePathColored,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallTrianglePathColored(),
          ),
        ),
      );

      // Should find 3 shapes
      expect(find.byType(IndicatorShapeWidget), findsNWidgets(3));

      // Should find 3 Transform widgets
      expect(find.byType(Transform), findsNWidgets(3));

      // Should find 3 AnimatedBuilder widgets that are children of BallTrianglePathColored
      final animatedBuilders = find.descendant(
        of: find.byType(BallTrianglePathColored),
        matching: find.byType(AnimatedBuilder),
      );
      expect(animatedBuilders, findsNWidgets(3));

      // Should find 3 Positioned widgets
      expect(find.byType(Positioned), findsNWidgets(3));

      // Should find 1 Stack
      expect(find.byType(Stack), findsNWidgets(1));
    });

    testWidgets('shapes use correct type based on isFilled parameter', (
      tester,
    ) async {
      // Test with rings (isFilled = false)
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballTrianglePathColored,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallTrianglePathColored(isFilled: false),
          ),
        ),
      );

      // Get all shapes
      var shapes = tester
          .widgetList<IndicatorShapeWidget>(find.byType(IndicatorShapeWidget))
          .toList();

      // Verify all shapes are rings with correct indices
      for (int i = 0; i < 3; i++) {
        expect(shapes[i].shape, equals(Shape.ring));
        expect(shapes[i].index, equals(i));
      }

      // Test with circles (isFilled = true)
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballTrianglePathColored,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallTrianglePathColored(isFilled: true),
          ),
        ),
      );

      // Get all shapes again
      shapes = tester
          .widgetList<IndicatorShapeWidget>(find.byType(IndicatorShapeWidget))
          .toList();

      // Verify all shapes are circles with correct indices
      for (int i = 0; i < 3; i++) {
        expect(shapes[i].shape, equals(Shape.circle));
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
                  indicator: Indicator.ballTrianglePathColored,
                  colors: const [Colors.blue],
                  pause: false,
                ),
                child: const BallTrianglePathColored(),
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
        reason: 'Top circle should be centered horizontally',
      );
      expect(
        positionsList[0].top,
        equals(0),
        reason: 'Top circle should be at the top',
      );

      // Verify left bottom position
      expect(
        positionsList[1].left,
        equals(0),
        reason: 'Left circle should be at the left edge',
      );
      expect(
        positionsList[1].top,
        equals(containerSize.height - circleSize),
        reason: 'Left circle should be at the bottom',
      );

      // Verify right bottom position
      expect(
        positionsList[2].left,
        equals(containerSize.width - circleSize),
        reason: 'Right circle should be at the right edge',
      );
      expect(
        positionsList[2].top,
        equals(containerSize.height - circleSize),
        reason: 'Right circle should be at the bottom',
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
                indicator: Indicator.ballTrianglePathColored,
                colors: const [Colors.blue],
                pause: false,
              ),
              child: const BallTrianglePathColored(),
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
          reason: 'Shape $i should have moved',
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
          reason: 'Shape $i should have continued moving',
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
                  indicator: Indicator.ballTrianglePathColored,
                  colors: const [Colors.blue],
                  pause: false,
                ),
                child: const BallTrianglePathColored(),
              ),
            ),
          ),
        ),
      );

      // Find the root widget's render box
      final renderBox = tester.renderObject<RenderBox>(
        find.byType(BallTrianglePathColored),
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

      // Verify shape sizes are proportional to container width
      final circleSize = containerSize.width / 5;
      final shapes = tester.widgetList<Positioned>(find.byType(Positioned));
      for (final shape in shapes) {
        expect(
          shape.width,
          equals(circleSize),
          reason: 'Shape width should be one-fifth of container width',
        );
        expect(
          shape.height,
          equals(circleSize),
          reason: 'Shape height should be one-fifth of container width',
        );
      }
    });
  });
}

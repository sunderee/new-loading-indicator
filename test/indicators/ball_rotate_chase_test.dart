import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/indicators/ball_rotate_chase.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

void main() {
  group('BallRotateChase', () {
    testWidgets('renders correct number of shapes and transforms', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballRotateChase,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallRotateChase(),
          ),
        ),
      );

      // Should find 5 circles
      expect(find.byType(IndicatorShapeWidget), findsNWidgets(5));

      // Should find 5 Transform widgets as direct children of AnimatedBuilder
      final animatedBuilders = find.byType(AnimatedBuilder).evaluate().toList();
      int transformCount = 0;
      for (final element in animatedBuilders) {
        final widget = element.widget as AnimatedBuilder;
        if (widget.builder(element, widget.child) is Transform) {
          transformCount++;
        }
      }
      expect(transformCount, equals(5));

      // Should find 5 ScaleTransition widgets
      expect(find.byType(ScaleTransition), findsNWidgets(5));

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
              indicator: Indicator.ballRotateChase,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallRotateChase(),
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

      // Verify all shapes are circles with correct indices
      for (int i = 0; i < 5; i++) {
        expect(shapes[i].shape, equals(Shape.circle));
        expect(shapes[i].index, equals(i));
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
                  indicator: Indicator.ballRotateChase,
                  colors: const [Colors.blue],
                  pause: false,
                ),
                child: const BallRotateChase(),
              ),
            ),
          ),
        ),
      );

      // Find the Stack widget that contains the circles
      final stackRenderBox = tester.renderObject<RenderBox>(find.byType(Stack));

      // Verify that Stack uses the container size
      expect(
        stackRenderBox.size.width,
        equals(containerSize.width),
        reason: 'Stack should use container width',
      );

      expect(
        stackRenderBox.size.height,
        equals(containerSize.height),
        reason: 'Stack should use container height',
      );

      // Verify circle sizes
      final circles = tester.widgetList<Positioned>(find.byType(Positioned));
      for (final circle in circles) {
        final expectedSize = containerSize.width / 5;
        expect(
          circle.left! + expectedSize <= containerSize.width &&
              circle.top! + expectedSize <= containerSize.height,
          isTrue,
          reason: 'Circle should fit within container bounds',
        );
      }
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/indicators/ball_rotate.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

void main() {
  group('BallRotate', () {
    testWidgets('renders correct number of shapes and transitions', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballRotate,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallRotate(),
          ),
        ),
      );

      // Should find 3 circles
      expect(find.byType(IndicatorShapeWidget), findsNWidgets(3));

      // Should find 1 RotationTransition
      expect(find.byType(RotationTransition), findsNWidgets(1));

      // Should find 1 ScaleTransition
      expect(find.byType(ScaleTransition), findsNWidgets(1));

      // Should find 3 Opacity widgets
      expect(find.byType(Opacity), findsNWidgets(3));

      // Should find 1 Row
      expect(find.byType(Row), findsNWidgets(1));
    });

    testWidgets('shapes use correct type, indices, and opacities', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballRotate,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallRotate(),
          ),
        ),
      );

      // Get all shapes
      final shapes = tester
          .widgetList<IndicatorShapeWidget>(find.byType(IndicatorShapeWidget))
          .toList();

      // Get all opacity widgets
      final opacities = tester
          .widgetList<Opacity>(find.byType(Opacity))
          .toList();

      // Verify all shapes are circles with correct indices
      for (int i = 0; i < 3; i++) {
        expect(shapes[i].shape, equals(Shape.circle));
        expect(shapes[i].index, equals(i));
      }

      // Verify opacities are correct (outer circles at 0.8, center at 1.0)
      expect(opacities[0].opacity, equals(0.8));
      expect(opacities[1].opacity, equals(1.0));
      expect(opacities[2].opacity, equals(0.8));
    });

    testWidgets('animations are properly configured', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 100,
            height: 100,
            child: DecorateContext(
              decorateData: DecorateData(
                indicator: Indicator.ballRotate,
                colors: const [Colors.blue],
                pause: false,
              ),
              child: const BallRotate(),
            ),
          ),
        ),
      );

      // Initial pump to start animations
      await tester.pump();

      // Get initial rotation and scale
      final initialRotation = tester
          .widget<RotationTransition>(find.byType(RotationTransition))
          .turns
          .value;

      final initialScale = tester
          .widget<ScaleTransition>(find.byType(ScaleTransition))
          .scale
          .value;

      // Let animations run for a short duration
      await tester.pump(const Duration(milliseconds: 100));

      // Get rotation and scale after delay
      final delayedRotation = tester
          .widget<RotationTransition>(find.byType(RotationTransition))
          .turns
          .value;

      final delayedScale = tester
          .widget<ScaleTransition>(find.byType(ScaleTransition))
          .scale
          .value;

      // Verify that animations have started
      expect(
        delayedRotation,
        isNot(equals(initialRotation)),
        reason: 'Rotation animation should have started',
      );

      expect(
        delayedScale,
        isNot(equals(initialScale)),
        reason: 'Scale animation should have started',
      );

      // Let animations run longer
      await tester.pump(const Duration(milliseconds: 300));

      // Get rotation and scale after longer delay
      final longerDelayRotation = tester
          .widget<RotationTransition>(find.byType(RotationTransition))
          .turns
          .value;

      final longerDelayScale = tester
          .widget<ScaleTransition>(find.byType(ScaleTransition))
          .scale
          .value;

      // Verify rotation is progressing
      expect(
        longerDelayRotation,
        isNot(equals(delayedRotation)),
        reason: 'Rotation should continue changing',
      );

      // Verify scale bounds
      expect(
        longerDelayScale >= 0.6 && longerDelayScale <= 1.0,
        isTrue,
        reason: 'Scale should stay between 0.6 and 1.0',
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
                  indicator: Indicator.ballRotate,
                  colors: const [Colors.blue],
                  pause: false,
                ),
                child: const BallRotate(),
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

      // Find the Row widget to check its children
      final row = tester.widget<Row>(find.byType(Row));

      // Verify that circles and spacers use equal width
      for (final child in row.children) {
        if (child is Expanded) {
          expect(
            child.flex,
            equals(1),
            reason: 'All Expanded widgets should have equal flex',
          );
        }
      }
    });
  });
}

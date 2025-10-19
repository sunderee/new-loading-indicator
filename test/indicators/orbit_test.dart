import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/indicators/orbit.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

void main() {
  group('Orbit', () {
    testWidgets('debug widget tree', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.orbit,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const Orbit(),
          ),
        ),
      );
    });

    testWidgets('renders correct number of shapes and transitions', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.orbit,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const Orbit(),
          ),
        ),
      );

      // Should find 4 circles (core, 2 rings, 1 satellite)
      expect(find.byType(IndicatorShapeWidget), findsNWidgets(4));

      // Should find 2 FadeTransition widgets (for rings)
      expect(find.byType(FadeTransition), findsNWidgets(2));

      // Should find 3 ScaleTransition widgets (core + 2 rings)
      expect(find.byType(ScaleTransition), findsNWidgets(3));

      // Should find 4 Transform widgets (core, 2 rings, 1 satellite)
      expect(find.byType(Transform), findsNWidgets(4));

      // Should find 4 Positioned widgets
      expect(find.byType(Positioned), findsNWidgets(4));

      // Should find 1 Stack
      expect(find.byType(Stack), findsNWidgets(1));

      // Verify the satellite Transform has a non-zero translation
      final transforms = tester.widgetList<Transform>(find.byType(Transform));
      final satelliteTransform = transforms.firstWhere(
        (t) => t.transform.getTranslation().y != 0,
      );
      expect(satelliteTransform.child, isA<IndicatorShapeWidget>());
      expect(
        (satelliteTransform.child as IndicatorShapeWidget).index,
        equals(3),
      );
    });

    testWidgets('shapes use correct type and indices', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.orbit,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const Orbit(),
          ),
        ),
      );

      // Get all shapes
      final shapes = tester
          .widgetList<IndicatorShapeWidget>(find.byType(IndicatorShapeWidget))
          .toList();

      // Verify all shapes are circles with correct indices
      for (int i = 0; i < 4; i++) {
        expect(shapes[i].shape, equals(Shape.circle));
        expect(shapes[i].index, equals(i));
      }
    });

    testWidgets('animations are properly configured', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 100,
            height: 100,
            child: DecorateContext(
              decorateData: DecorateData(
                indicator: Indicator.orbit,
                colors: const [Colors.blue],
                pause: false,
              ),
              child: const Orbit(),
            ),
          ),
        ),
      );

      // Initial pump to start animations
      await tester.pump();

      // Get initial states
      final initialScales = tester
          .widgetList<ScaleTransition>(find.byType(ScaleTransition))
          .map((w) => w.scale.value)
          .toList();

      // Let animations run for a longer duration to ensure changes are visible
      await tester.pump(const Duration(milliseconds: 500));

      // Get states after delay
      final delayScales = tester
          .widgetList<ScaleTransition>(find.byType(ScaleTransition))
          .map((w) => w.scale.value)
          .toList();

      // Verify that animations have started
      bool hasScaleAnimationStarted = false;
      for (int i = 0; i < delayScales.length; i++) {
        if ((delayScales[i] - initialScales[i]).abs() > 0.01) {
          hasScaleAnimationStarted = true;
          break;
        }
      }

      expect(
        hasScaleAnimationStarted,
        isTrue,
        reason: 'At least one scale animation should have started',
      );

      // Verify core animation bounds
      final coreScale = delayScales[0];
      expect(
        coreScale >= 1.0 && coreScale <= 1.3,
        isTrue,
        reason: 'Core scale should stay between 100% and 130%',
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
                  indicator: Indicator.orbit,
                  colors: const [Colors.blue],
                  pause: false,
                ),
                child: const Orbit(),
              ),
            ),
          ),
        ),
      );

      // Find the Stack widget
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

      // Get all positioned widgets
      final positions = tester.widgetList<Positioned>(find.byType(Positioned));

      // Calculate expected dimensions
      final coreSize = containerSize.width / (1 + 0.25 + 1.5);
      final satelliteSize = containerSize.width * 0.25 / 2;

      // Verify core and satellite sizes with tolerance
      final corePosition = positions.first;
      final satellitePosition = positions.last;

      expect(
        (corePosition.width! - coreSize).abs() < 0.000001,
        isTrue,
        reason: 'Core width should be correctly calculated',
      );
      expect(
        (satellitePosition.width! - satelliteSize).abs() < 0.000001,
        isTrue,
        reason: 'Satellite width should be correctly calculated',
      );
    });

    testWidgets('satellite orbits correctly', (tester) async {
      const containerSize = Size(200.0, 100.0);

      await tester.pumpWidget(
        Center(
          child: SizedBox.fromSize(
            size: containerSize,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              home: DecorateContext(
                decorateData: DecorateData(
                  indicator: Indicator.orbit,
                  colors: const [Colors.blue],
                  pause: false,
                ),
                child: const Orbit(),
              ),
            ),
          ),
        ),
      );

      // Initial pump to start animations
      await tester.pump();

      // Get initial satellite position
      final initialTransforms = tester.widgetList<Transform>(
        find.byType(Transform),
      );
      final initialTransform = initialTransforms.firstWhere(
        (t) => t.transform.getTranslation().y != 0,
      );
      final initialOffset = initialTransform.transform.getTranslation();
      final initialX = initialOffset.x;
      final initialY = initialOffset.y;

      // Let animation run for a quarter orbit
      await tester.pump(const Duration(milliseconds: 475)); // 1900ms / 4

      // Get new satellite position
      final quarterTransforms = tester.widgetList<Transform>(
        find.byType(Transform),
      );
      final quarterTransform = quarterTransforms.firstWhere(
        (t) => t.transform.getTranslation().y != 0,
      );
      final quarterOffset = quarterTransform.transform.getTranslation();
      final quarterX = quarterOffset.x;
      final quarterY = quarterOffset.y;

      // Verify that position has changed significantly
      expect(
        (quarterX - initialX).abs() > 1.0 || (quarterY - initialY).abs() > 1.0,
        isTrue,
        reason: 'Satellite should move significantly during orbit',
      );
    });
  });
}

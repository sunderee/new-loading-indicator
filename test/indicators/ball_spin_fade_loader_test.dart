import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/indicators/ball_spin_fade_loader.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

void main() {
  group('BallSpinFadeLoader', () {
    testWidgets('renders correct number of shapes and transitions', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballSpinFadeLoader,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallSpinFadeLoader(),
          ),
        ),
      );

      // Should find 8 circles
      expect(find.byType(IndicatorShapeWidget), findsNWidgets(8));

      // Should find 8 ScaleTransition widgets
      expect(find.byType(ScaleTransition), findsNWidgets(8));

      // Should find 8 FadeTransition widgets
      expect(find.byType(FadeTransition), findsNWidgets(8));

      // Should find 8 Positioned widgets
      expect(find.byType(Positioned), findsNWidgets(8));

      // Should find 1 Stack
      expect(find.byType(Stack), findsNWidgets(1));
    });

    testWidgets('shapes use correct type and indices', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballSpinFadeLoader,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallSpinFadeLoader(),
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
      for (int i = 0; i < 8; i++) {
        expect(shapes[i].shape, equals(Shape.circle));
        expect(shapes[i].index, equals(i));
      }
    });

    testWidgets('animations are properly configured with delays', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 100,
            height: 100,
            child: DecorateContext(
              decorateData: DecorateData(
                indicator: Indicator.ballSpinFadeLoader,
                colors: const [Colors.blue],
                pause: false,
              ),
              child: const BallSpinFadeLoader(),
            ),
          ),
        ),
      );

      // Initial pump to start animations
      await tester.pump();

      // Get initial scales and opacities
      final initialScales =
          tester
              .widgetList<ScaleTransition>(find.byType(ScaleTransition))
              .map((w) => w.scale.value)
              .toList();

      final initialOpacities =
          tester
              .widgetList<FadeTransition>(find.byType(FadeTransition))
              .map((w) => w.opacity.value)
              .toList();

      // Let animations run for a short duration
      await tester.pump(const Duration(milliseconds: 200));

      // Get scales and opacities after short delay
      final shortDelayScales =
          tester
              .widgetList<ScaleTransition>(find.byType(ScaleTransition))
              .map((w) => w.scale.value)
              .toList();

      final shortDelayOpacities =
          tester
              .widgetList<FadeTransition>(find.byType(FadeTransition))
              .map((w) => w.opacity.value)
              .toList();

      // Verify that animations have started
      bool hasAnimationStarted = false;
      for (int i = 0; i < 8; i++) {
        if (shortDelayScales[i] != initialScales[i] ||
            shortDelayOpacities[i] != initialOpacities[i]) {
          hasAnimationStarted = true;
          break;
        }
      }

      expect(
        hasAnimationStarted,
        isTrue,
        reason: 'At least one circle should have started animating',
      );

      // Let animations run longer
      await tester.pump(const Duration(milliseconds: 500));

      // Get scales and opacities after longer delay
      final longerDelayScales =
          tester
              .widgetList<ScaleTransition>(find.byType(ScaleTransition))
              .map((w) => w.scale.value)
              .toList();

      final longerDelayOpacities =
          tester
              .widgetList<FadeTransition>(find.byType(FadeTransition))
              .map((w) => w.opacity.value)
              .toList();

      // Verify scale bounds
      for (final scale in longerDelayScales) {
        expect(
          scale >= 0.4 && scale <= 1.0,
          isTrue,
          reason: 'Scale should stay between 0.4 and 1.0',
        );
      }

      // Verify opacity bounds
      for (final opacity in longerDelayOpacities) {
        expect(
          opacity >= 0.3 && opacity <= 1.0,
          isTrue,
          reason: 'Opacity should stay between 0.3 and 1.0',
        );
      }

      // Verify that circles have different scales due to phase differences
      final uniqueScales = Set<double>.from(longerDelayScales);
      expect(
        uniqueScales.length,
        greaterThan(1),
        reason: 'Circles should have different scales due to phase differences',
      );

      // Verify that circles have different opacities due to phase differences
      final uniqueOpacities = Set<double>.from(longerDelayOpacities);
      expect(
        uniqueOpacities.length,
        greaterThan(1),
        reason:
            'Circles should have different opacities due to phase differences',
      );
    });

    testWidgets('circles are positioned correctly in circular pattern', (
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
                  indicator: Indicator.ballSpinFadeLoader,
                  colors: const [Colors.blue],
                  pause: false,
                ),
                child: const BallSpinFadeLoader(),
              ),
            ),
          ),
        ),
      );

      // Find all Positioned widgets
      final positions = tester.widgetList<Positioned>(find.byType(Positioned));

      // Get the center point
      final centerX = containerSize.width / 2;
      final centerY = containerSize.height / 2;

      // Calculate circle size based on container width (matches widget implementation)
      final circleSize = containerSize.width / 3;
      final radius = circleSize;

      // Verify each circle's position
      int index = 0;
      for (final position in positions) {
        final angle = pi * index / 4;

        // Calculate expected position (center of the circle)
        // Using the same calculations as in the widget implementation
        final expectedX = centerX + radius * sin(angle) - circleSize / 4;
        final expectedY = centerY + radius * cos(angle) - circleSize / 4;

        // Get actual position
        final actualX = position.left!;
        final actualY = position.top!;

        // Allow for small rounding differences
        expect(
          (actualX - expectedX).abs() < 1.0,
          isTrue,
          reason: 'Circle $index should be at correct X position',
        );
        expect(
          (actualY - expectedY).abs() < 1.0,
          isTrue,
          reason: 'Circle $index should be at correct Y position',
        );

        index++;
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
                  indicator: Indicator.ballSpinFadeLoader,
                  colors: const [Colors.blue],
                  pause: false,
                ),
                child: const BallSpinFadeLoader(),
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

      // Verify Stack alignment and fit
      final stack = tester.widget<Stack>(find.byType(Stack));
      expect(stack.alignment, equals(Alignment.center));
      expect(stack.fit, equals(StackFit.expand));
    });
  });
}

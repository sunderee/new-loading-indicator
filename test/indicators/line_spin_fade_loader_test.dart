import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/indicators/line_spin_fade_loader.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

void main() {
  group('LineSpinFadeLoader', () {
    testWidgets('renders correct number of shapes and transitions', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.lineSpinFadeLoader,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const LineSpinFadeLoader(),
          ),
        ),
      );

      // Should find 8 lines
      expect(find.byType(IndicatorShapeWidget), findsNWidgets(8));

      // Should find 8 FadeTransition widgets
      expect(find.byType(FadeTransition), findsNWidgets(8));

      // Should find 8 Transform.rotate widgets
      expect(find.byType(Transform), findsNWidgets(8));

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
              indicator: Indicator.lineSpinFadeLoader,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const LineSpinFadeLoader(),
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

      // Verify all shapes are lines with correct indices
      for (int i = 0; i < 8; i++) {
        expect(shapes[i].shape, equals(Shape.line));
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
                indicator: Indicator.lineSpinFadeLoader,
                colors: const [Colors.blue],
                pause: false,
              ),
              child: const LineSpinFadeLoader(),
            ),
          ),
        ),
      );

      // Initial pump to start animations
      await tester.pump();

      // Get initial opacities
      final initialOpacities =
          tester
              .widgetList<FadeTransition>(find.byType(FadeTransition))
              .map((w) => w.opacity.value)
              .toList();

      // Let animations run for a short duration
      await tester.pump(const Duration(milliseconds: 200));

      // Get opacities after short delay
      final shortDelayOpacities =
          tester
              .widgetList<FadeTransition>(find.byType(FadeTransition))
              .map((w) => w.opacity.value)
              .toList();

      // Verify that animations have started
      bool hasAnimationStarted = false;
      for (int i = 0; i < 8; i++) {
        if (shortDelayOpacities[i] != initialOpacities[i]) {
          hasAnimationStarted = true;
          break;
        }
      }

      expect(
        hasAnimationStarted,
        isTrue,
        reason: 'At least one line should have started fading',
      );

      // Let animations run longer
      await tester.pump(const Duration(milliseconds: 300));

      // Get opacities after longer delay
      final longerDelayOpacities =
          tester
              .widgetList<FadeTransition>(find.byType(FadeTransition))
              .map((w) => w.opacity.value)
              .toList();

      // Verify opacity bounds
      for (final opacity in longerDelayOpacities) {
        expect(
          opacity >= 0.3 && opacity <= 1.0,
          isTrue,
          reason: 'Opacity should stay between 0.3 and 1.0',
        );
      }

      // Verify that lines have different opacities due to different delays
      final uniqueOpacities = Set<double>.from(longerDelayOpacities);
      expect(
        uniqueOpacities.length,
        greaterThan(1),
        reason: 'Lines should have different opacities due to different delays',
      );
    });

    testWidgets('lines are correctly positioned and rotated', (tester) async {
      const containerSize = Size(200.0, 100.0);

      await tester.pumpWidget(
        Center(
          child: SizedBox.fromSize(
            size: containerSize,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              home: DecorateContext(
                decorateData: DecorateData(
                  indicator: Indicator.lineSpinFadeLoader,
                  colors: const [Colors.blue],
                  pause: false,
                ),
                child: const LineSpinFadeLoader(),
              ),
            ),
          ),
        ),
      );

      // Get all positioned widgets
      final positions = tester.widgetList<Positioned>(find.byType(Positioned));
      final rotations = tester.widgetList<Transform>(find.byType(Transform));

      // Calculate expected line dimensions and center point
      final circleSize = containerSize.width / 3;
      final lineWidth = circleSize / 2;
      final lineHeight = circleSize;
      final centerX = containerSize.width / 2;
      final centerY = containerSize.height / 2;

      // Verify each line's position and rotation
      for (int i = 0; i < 8; i++) {
        final angle = pi * i / 4;
        final position = positions.elementAt(i);
        final rotation = rotations.elementAt(i);

        // Verify line dimensions
        expect(
          (position.width! - lineWidth).abs() < 0.000001,
          isTrue,
          reason: 'Line width should be one-sixth of container width',
        );
        expect(
          (position.height! - lineHeight).abs() < 0.000001,
          isTrue,
          reason: 'Line height should be one-third of container width',
        );

        // Calculate expected position relative to center
        final expectedX = centerX + circleSize * sin(angle) - lineWidth / 2;
        final expectedY = centerY + circleSize * cos(angle) - lineHeight / 2;

        // Verify line position with some tolerance for floating-point precision
        expect(
          (position.left! - expectedX).abs() < 0.000001,
          isTrue,
          reason: 'Line should be positioned correctly horizontally',
        );
        expect(
          (position.top! - expectedY).abs() < 0.000001,
          isTrue,
          reason: 'Line should be positioned correctly vertically',
        );

        // Verify rotation angle
        final transform = rotation;
        expect(
          transform.transform.getRotation()[0],
          closeTo(cos(-angle), 0.001),
          reason: 'Line should be rotated to maintain vertical orientation',
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
                  indicator: Indicator.lineSpinFadeLoader,
                  colors: const [Colors.blue],
                  pause: false,
                ),
                child: const LineSpinFadeLoader(),
              ),
            ),
          ),
        ),
      );

      // Find the Stack widget that contains the lines
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
      expect(
        stack.alignment,
        equals(Alignment.center),
        reason: 'Stack should be center-aligned',
      );
      expect(
        stack.fit,
        equals(StackFit.expand),
        reason: 'Stack should expand to fill container',
      );
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/indicators/ball_scale_ripple_multiple.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

void main() {
  group('BallScaleRippleMultiple', () {
    testWidgets('renders correct number of shapes and transitions', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballScaleRippleMultiple,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallScaleRippleMultiple(),
          ),
        ),
      );

      // Should find 3 rings
      expect(find.byType(IndicatorShapeWidget), findsNWidgets(3));

      // Should find 3 ScaleTransition widgets
      expect(find.byType(ScaleTransition), findsNWidgets(3));

      // Should find 3 FadeTransition widgets
      expect(find.byType(FadeTransition), findsNWidgets(3));

      // Should find 1 Stack
      expect(find.byType(Stack), findsNWidgets(1));
    });

    testWidgets('shapes use correct type and indices', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballScaleRippleMultiple,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallScaleRippleMultiple(),
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
                indicator: Indicator.ballScaleRippleMultiple,
                colors: const [Colors.blue],
                pause: false,
              ),
              child: const BallScaleRippleMultiple(),
            ),
          ),
        ),
      );

      // Initial pump to start animations
      await tester.pump();

      // Get initial scales and opacities
      final initialScales = tester
          .widgetList<ScaleTransition>(find.byType(ScaleTransition))
          .map((w) => w.scale.value)
          .toList();

      final initialOpacities = tester
          .widgetList<FadeTransition>(find.byType(FadeTransition))
          .map((w) => w.opacity.value)
          .toList();

      // Let animations run for a short duration
      await tester.pump(const Duration(milliseconds: 200));

      // Get scales and opacities after short delay
      final shortDelayScales = tester
          .widgetList<ScaleTransition>(find.byType(ScaleTransition))
          .map((w) => w.scale.value)
          .toList();

      final shortDelayOpacities = tester
          .widgetList<FadeTransition>(find.byType(FadeTransition))
          .map((w) => w.opacity.value)
          .toList();

      // Verify that animations have started
      bool hasAnimationStarted = false;
      for (int i = 0; i < 3; i++) {
        if (shortDelayScales[i] != initialScales[i] ||
            shortDelayOpacities[i] != initialOpacities[i]) {
          hasAnimationStarted = true;
          break;
        }
      }

      expect(
        hasAnimationStarted,
        isTrue,
        reason: 'At least one ring should have started animating',
      );

      // Let animations run longer (about half the total duration)
      await tester.pump(const Duration(milliseconds: 600));

      // Get scales and opacities after longer delay
      final longerDelayScales = tester
          .widgetList<ScaleTransition>(find.byType(ScaleTransition))
          .map((w) => w.scale.value)
          .toList();

      final longerDelayOpacities = tester
          .widgetList<FadeTransition>(find.byType(FadeTransition))
          .map((w) => w.opacity.value)
          .toList();

      // Verify scale bounds
      for (final scale in longerDelayScales) {
        expect(
          scale >= 0.0 && scale <= 1.0,
          isTrue,
          reason: 'Scale should stay between 0.0 and 1.0',
        );
      }

      // Verify opacity bounds
      for (final opacity in longerDelayOpacities) {
        expect(
          opacity >= 0.0 && opacity <= 1.0,
          isTrue,
          reason: 'Opacity should stay between 0.0 and 1.0',
        );
      }

      // Let animations run even longer to ensure phase differences are visible
      await tester.pump(const Duration(milliseconds: 400));

      // Get final scales and opacities
      final finalScales = tester
          .widgetList<ScaleTransition>(find.byType(ScaleTransition))
          .map((w) => w.scale.value)
          .toList();

      final finalOpacities = tester
          .widgetList<FadeTransition>(find.byType(FadeTransition))
          .map((w) => w.opacity.value)
          .toList();

      // Verify that rings have different scales or opacities due to phase differences
      final uniqueStates = Set<String>.from(
        List.generate(3, (i) => '${finalScales[i]},${finalOpacities[i]}'),
      );

      expect(
        uniqueStates.length,
        greaterThan(1),
        reason:
            'Rings should have different animation states due to phase differences',
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
                  indicator: Indicator.ballScaleRippleMultiple,
                  colors: const [Colors.blue],
                  pause: false,
                ),
                child: const BallScaleRippleMultiple(),
              ),
            ),
          ),
        ),
      );

      // Find the Stack widget that contains the rings
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

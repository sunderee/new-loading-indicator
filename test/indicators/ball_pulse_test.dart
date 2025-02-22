import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/indicators/ball_pulse.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

void main() {
  group('BallPulse', () {
    testWidgets('renders correct number of shapes and transitions', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballPulse,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallPulse(),
          ),
        ),
      );

      // Should find 3 circles
      expect(find.byType(IndicatorShapeWidget), findsNWidgets(3));

      // Should find 3 ScaleTransition widgets
      expect(find.byType(ScaleTransition), findsNWidgets(3));

      // Should find 3 FadeTransition widgets
      expect(find.byType(FadeTransition), findsNWidgets(3));

      // Should find 1 Row
      expect(find.byType(Row), findsNWidgets(1));
    });

    testWidgets('shapes use correct type and indices', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballPulse,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallPulse(),
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
      for (int i = 0; i < 3; i++) {
        expect(shapes[i].shape, equals(Shape.circle));
        expect(shapes[i].index, equals(i));
      }
    });

    testWidgets('animations are properly configured with delays', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballPulse,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallPulse(),
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
      await tester.pump(const Duration(milliseconds: 100));

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
      for (int i = 0; i < 3; i++) {
        expect(
          shortDelayScales[i],
          isNot(equals(initialScales[i])),
          reason: 'Circle $i scale should have changed',
        );
        expect(
          shortDelayOpacities[i],
          isNot(equals(initialOpacities[i])),
          reason: 'Circle $i opacity should have changed',
        );
      }

      // Let animations run longer
      await tester.pump(const Duration(milliseconds: 300));

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
          scale >= 0.1 && scale <= 1.0,
          isTrue,
          reason: 'Scale should stay between 0.1 and 1.0',
        );
      }

      // Verify opacity bounds
      for (final opacity in longerDelayOpacities) {
        expect(
          opacity >= 0.7 && opacity <= 1.0,
          isTrue,
          reason: 'Opacity should stay between 0.7 and 1.0',
        );
      }

      // Verify that circles have different scales due to phase difference
      final uniqueScales = Set<double>.from(longerDelayScales);
      expect(
        uniqueScales.length,
        greaterThan(1),
        reason: 'Circles should have different scales due to phase differences',
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
                  indicator: Indicator.ballPulse,
                  colors: const [Colors.blue],
                  pause: false,
                ),
                child: const BallPulse(),
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
      final spacers = row.children.whereType<SizedBox>();

      // Verify spacing between circles
      for (final spacer in spacers) {
        expect(
          spacer.width,
          equals(2.0),
          reason: 'Spacing between circles should be 2 pixels',
        );
      }
    });
  });
}

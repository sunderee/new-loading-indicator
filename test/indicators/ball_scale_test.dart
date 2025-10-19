import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/indicators/ball_scale.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

void main() {
  group('BallScale', () {
    testWidgets('renders correct number of shapes and transitions', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballScale,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallScale(),
          ),
        ),
      );

      // Should find 1 circle
      expect(find.byType(IndicatorShapeWidget), findsOneWidget);

      // Should find 1 ScaleTransition widget
      expect(find.byType(ScaleTransition), findsOneWidget);

      // Should find 1 FadeTransition widget
      expect(find.byType(FadeTransition), findsOneWidget);
    });

    testWidgets('shape uses correct type', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballScale,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallScale(),
          ),
        ),
      );

      // Get the shape
      final shape = tester.widget<IndicatorShapeWidget>(
        find.byType(IndicatorShapeWidget),
      );

      // Verify it's a circle
      expect(shape.shape, equals(Shape.circle));
    });

    testWidgets('animations are properly configured', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 100,
            height: 100,
            child: DecorateContext(
              decorateData: DecorateData(
                indicator: Indicator.ballScale,
                colors: const [Colors.blue],
                pause: false,
              ),
              child: const BallScale(),
            ),
          ),
        ),
      );

      // Initial pump to start animations
      await tester.pump();

      // Get initial scale and opacity
      final initialScale = tester
          .widget<ScaleTransition>(find.byType(ScaleTransition))
          .scale
          .value;

      final initialOpacity = tester
          .widget<FadeTransition>(find.byType(FadeTransition))
          .opacity
          .value;

      // Let animations run for a short duration
      await tester.pump(const Duration(milliseconds: 200));

      // Get scale and opacity after short delay
      final shortDelayScale = tester
          .widget<ScaleTransition>(find.byType(ScaleTransition))
          .scale
          .value;

      final shortDelayOpacity = tester
          .widget<FadeTransition>(find.byType(FadeTransition))
          .opacity
          .value;

      // Verify that animations have started
      expect(
        shortDelayScale,
        isNot(equals(initialScale)),
        reason: 'Scale animation should have started',
      );

      expect(
        shortDelayOpacity,
        isNot(equals(initialOpacity)),
        reason: 'Opacity animation should have started',
      );

      // Let animations run longer
      await tester.pump(const Duration(milliseconds: 500));

      // Get scale and opacity after longer delay
      final longerDelayScale = tester
          .widget<ScaleTransition>(find.byType(ScaleTransition))
          .scale
          .value;

      final longerDelayOpacity = tester
          .widget<FadeTransition>(find.byType(FadeTransition))
          .opacity
          .value;

      // Verify scale bounds
      expect(
        longerDelayScale >= 0.0 && longerDelayScale <= 1.0,
        isTrue,
        reason: 'Scale should stay between 0.0 and 1.0',
      );

      // Verify opacity bounds
      expect(
        longerDelayOpacity >= 0.0 && longerDelayOpacity <= 1.0,
        isTrue,
        reason: 'Opacity should stay between 0.0 and 1.0',
      );

      // Verify that opacity is inversely related to scale
      expect(
        (1.0 - longerDelayScale - longerDelayOpacity).abs() < 0.0001,
        isTrue,
        reason: 'Opacity should be inverse of scale',
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
                  indicator: Indicator.ballScale,
                  colors: const [Colors.blue],
                  pause: false,
                ),
                child: const BallScale(),
              ),
            ),
          ),
        ),
      );

      // Find the root widget's render box
      final renderBox = tester.renderObject<RenderBox>(find.byType(BallScale));

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
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/indicators/circle_stroke_spin.dart';

void main() {
  group('CircleStrokeSpin', () {
    testWidgets('renders CircularProgressIndicator with correct properties', (
      tester,
    ) async {
      const color = Colors.blue;
      const strokeWidth = 4.0;
      const backgroundColor = Colors.grey;

      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.circleStrokeSpin,
              colors: const [color],
              strokeWidth: strokeWidth,
              pathBackgroundColor: backgroundColor,
              pause: false,
            ),
            child: const CircleStrokeSpin(),
          ),
        ),
      );

      // Should find 1 CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Get the CircularProgressIndicator widget
      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      // Verify properties are correctly passed from DecorateContext
      expect(progressIndicator.color, equals(color));
      expect(progressIndicator.strokeWidth, equals(strokeWidth));
      expect(progressIndicator.backgroundColor, equals(backgroundColor));
    });

    testWidgets('adapts to different colors', (tester) async {
      const colors = [Colors.red, Colors.green, Colors.blue];

      for (final color in colors) {
        await tester.pumpWidget(
          MaterialApp(
            home: DecorateContext(
              decorateData: DecorateData(
                indicator: Indicator.circleStrokeSpin,
                colors: [color],
                pause: false,
              ),
              child: const CircleStrokeSpin(),
            ),
          ),
        );

        // Get the CircularProgressIndicator widget
        final progressIndicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );

        // Verify color is correctly applied
        expect(progressIndicator.color, equals(color));
      }
    });

    testWidgets('adapts to different stroke widths', (tester) async {
      const strokeWidths = [2.0, 4.0, 6.0];

      for (final strokeWidth in strokeWidths) {
        await tester.pumpWidget(
          MaterialApp(
            home: DecorateContext(
              decorateData: DecorateData(
                indicator: Indicator.circleStrokeSpin,
                colors: const [Colors.blue],
                strokeWidth: strokeWidth,
                pause: false,
              ),
              child: const CircleStrokeSpin(),
            ),
          ),
        );

        // Get the CircularProgressIndicator widget
        final progressIndicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );

        // Verify stroke width is correctly applied
        expect(progressIndicator.strokeWidth, equals(strokeWidth));
      }
    });

    testWidgets('adapts to different background colors', (tester) async {
      const backgroundColors = [Colors.grey, Colors.black12, Colors.white24];

      for (final backgroundColor in backgroundColors) {
        await tester.pumpWidget(
          MaterialApp(
            home: DecorateContext(
              decorateData: DecorateData(
                indicator: Indicator.circleStrokeSpin,
                colors: const [Colors.blue],
                pathBackgroundColor: backgroundColor,
                pause: false,
              ),
              child: const CircleStrokeSpin(),
            ),
          ),
        );

        // Get the CircularProgressIndicator widget
        final progressIndicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );

        // Verify background color is correctly applied
        expect(progressIndicator.backgroundColor, equals(backgroundColor));
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
                  indicator: Indicator.circleStrokeSpin,
                  colors: const [Colors.blue],
                  pause: false,
                ),
                child: const CircleStrokeSpin(),
              ),
            ),
          ),
        ),
      );

      // Find the root widget's render box
      final renderBox = tester.renderObject<RenderBox>(
        find.byType(CircleStrokeSpin),
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
    });
  });
}

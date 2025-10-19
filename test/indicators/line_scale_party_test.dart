import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/indicators/line_scale_party.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

void main() {
  group('LineScaleParty', () {
    testWidgets('renders correct number of shapes and transitions', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.lineScaleParty,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const LineScaleParty(),
          ),
        ),
      );

      // Should find 4 lines
      expect(find.byType(IndicatorShapeWidget), findsNWidgets(4));

      // Should find 4 FractionallySizedBox widgets
      expect(find.byType(FractionallySizedBox), findsNWidgets(4));

      // Should find 5 AnimatedBuilder widgets (4 for lines + 1 from MaterialApp)
      expect(find.byType(AnimatedBuilder), findsNWidgets(5));

      // Should find 7 Expanded widgets (4 for lines + 3 for spacers)
      expect(find.byType(Expanded), findsNWidgets(7));

      // Should find 1 Row
      expect(find.byType(Row), findsNWidgets(1));
    });

    testWidgets('shapes use correct type and indices', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.lineScaleParty,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const LineScaleParty(),
          ),
        ),
      );

      // Get all shapes
      final shapes = tester
          .widgetList<IndicatorShapeWidget>(find.byType(IndicatorShapeWidget))
          .toList();

      // Verify all shapes are lines with correct indices
      for (int i = 0; i < 4; i++) {
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
                indicator: Indicator.lineScaleParty,
                colors: const [Colors.blue],
                pause: false,
              ),
              child: const LineScaleParty(),
            ),
          ),
        ),
      );

      // Initial pump to start animations
      await tester.pump();

      // Get initial height factors
      final initialHeightFactors = tester
          .widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox))
          .map((w) => w.heightFactor)
          .toList();

      // Let animations run for a short duration
      await tester.pump(const Duration(milliseconds: 200));

      // Get height factors after short delay
      final shortDelayHeightFactors = tester
          .widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox))
          .map((w) => w.heightFactor)
          .toList();

      // Verify that animations have started
      bool hasAnimationStarted = false;
      for (int i = 0; i < 4; i++) {
        if (shortDelayHeightFactors[i] != initialHeightFactors[i]) {
          hasAnimationStarted = true;
          break;
        }
      }

      expect(
        hasAnimationStarted,
        isTrue,
        reason: 'At least one line should have started animating',
      );

      // Let animations run longer
      await tester.pump(const Duration(milliseconds: 300));

      // Get height factors after longer delay
      final longerDelayHeightFactors = tester
          .widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox))
          .map((w) => w.heightFactor)
          .toList();

      // Verify height factor bounds
      for (final heightFactor in longerDelayHeightFactors) {
        expect(
          heightFactor! >= 0.5 && heightFactor <= 1.0,
          isTrue,
          reason: 'Height factor should stay between 0.5 and 1.0',
        );
      }

      // Verify that lines have different heights due to different timings
      final uniqueHeightFactors = Set<double>.from(
        longerDelayHeightFactors.map((factor) => factor!),
      );
      expect(
        uniqueHeightFactors.length,
        greaterThan(1),
        reason: 'Lines should have different heights due to different timings',
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
                  indicator: Indicator.lineScaleParty,
                  colors: const [Colors.blue],
                  pause: false,
                ),
                child: const LineScaleParty(),
              ),
            ),
          ),
        ),
      );

      // Find the Row widget that contains the lines
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

      // Verify that lines and spacers use equal width
      for (final child in row.children) {
        if (child is Expanded) {
          expect(
            child.flex,
            equals(1),
            reason: 'All Expanded widgets should have equal flex',
          );
        }
      }

      // Verify cross axis alignment
      expect(
        row.crossAxisAlignment,
        equals(CrossAxisAlignment.stretch),
        reason: 'Row should stretch its children vertically',
      );
    });
  });
}

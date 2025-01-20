import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/indicators/audio_equalizer.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

void main() {
  group('AudioEqualizer', () {
    testWidgets('renders correct number of bars and spacers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.audioEqualizer,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const AudioEqualizer(),
          ),
        ),
      );

      // Should find 4 bars (IndicatorShapeWidget)
      expect(find.byType(IndicatorShapeWidget), findsNWidgets(4));

      // Should find 7 Expanded widgets (4 bars + 3 spacers)
      expect(find.byType(Expanded), findsNWidgets(7));

      // Find AnimatedBuilders that are children of Expanded widgets
      final animatedBuilders = find.descendant(
        of: find.byType(Expanded),
        matching: find.byType(AnimatedBuilder),
      );
      expect(animatedBuilders, findsNWidgets(4));
    });

    testWidgets('bars use rectangle shape', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.audioEqualizer,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const AudioEqualizer(),
          ),
        ),
      );

      // Verify all bars use rectangle shape
      final bars = tester.widgetList<IndicatorShapeWidget>(
        find.byType(IndicatorShapeWidget),
      );
      for (final bar in bars) {
        expect(bar.shape, equals(Shape.rectangle));
      }
    });

    testWidgets('bars animate correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.audioEqualizer,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const AudioEqualizer(),
          ),
        ),
      );

      // Allow animations to start
      await tester.pump();

      // Get all Transform widgets that handle the scaling
      final transforms = tester.widgetList<Transform>(
        find.descendant(
          of: find.byType(AnimatedBuilder),
          matching: find.byType(Transform),
        ),
      );
      expect(transforms.length, 4);

      // Initial values should be set
      final initialScales =
          transforms.map((t) => t.transform.getRow(1)[1]).toList();

      // Animate for a longer duration to ensure changes are visible
      await tester.pump(const Duration(seconds: 1));

      // Get new transforms after animation
      final newTransforms = tester.widgetList<Transform>(
        find.descendant(
          of: find.byType(AnimatedBuilder),
          matching: find.byType(Transform),
        ),
      );

      // Check that at least one bar has changed its scale
      final newScales =
          newTransforms.map((t) => t.transform.getRow(1)[1]).toList();
      expect(
        initialScales.any((scale) => !newScales.contains(scale)),
        isTrue,
        reason: 'At least one bar should have changed scale',
      );
    });

    testWidgets('responds to pause state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.audioEqualizer,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const AudioEqualizer(),
          ),
        ),
      );

      // Allow animations to start
      await tester.pump();

      // Get initial Y scales
      final initialScales = tester
          .widgetList<Transform>(
            find.descendant(
              of: find.byType(AnimatedBuilder),
              matching: find.byType(Transform),
            ),
          )
          .map((t) => t.transform.getRow(1)[1])
          .toList();

      // Let animations run
      await tester.pump(const Duration(seconds: 1));

      // Get scales after animation
      final animatedScales = tester
          .widgetList<Transform>(
            find.descendant(
              of: find.byType(AnimatedBuilder),
              matching: find.byType(Transform),
            ),
          )
          .map((t) => t.transform.getRow(1)[1])
          .toList();

      // Verify that scales have changed during animation
      expect(initialScales, isNot(equals(animatedScales)));

      // Update to paused state
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.audioEqualizer,
              colors: const [Colors.blue],
              pause: true,
            ),
            child: const AudioEqualizer(),
          ),
        ),
      );

      // Get scales right after pause
      final pausedScales = tester
          .widgetList<Transform>(
            find.descendant(
              of: find.byType(AnimatedBuilder),
              matching: find.byType(Transform),
            ),
          )
          .map((t) => t.transform.getRow(1)[1])
          .toList();

      // Wait a bit more
      await tester.pump(const Duration(seconds: 1));

      // Get scales after waiting while paused
      final stillPausedScales = tester
          .widgetList<Transform>(
            find.descendant(
              of: find.byType(AnimatedBuilder),
              matching: find.byType(Transform),
            ),
          )
          .map((t) => t.transform.getRow(1)[1])
          .toList();

      // Verify scales haven't changed while paused
      expect(pausedScales, equals(stillPausedScales));
    });
  });
}

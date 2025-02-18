import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/indicators/ball_beat.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

void main() {
  group('BallBeat', () {
    testWidgets('renders correct number of circles and spacers', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballBeat,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallBeat(),
          ),
        ),
      );

      // Should find 3 circles (IndicatorShapeWidget)
      expect(find.byType(IndicatorShapeWidget), findsNWidgets(3));

      // Should find 5 Expanded widgets (3 circles + 2 spacers)
      expect(find.byType(Expanded), findsNWidgets(3));

      // Should find 3 ScaleTransition widgets
      expect(find.byType(ScaleTransition), findsNWidgets(3));

      // Should find 3 FadeTransition widgets
      expect(find.byType(FadeTransition), findsNWidgets(3));

      // Should find 2 SizedBox widgets (spacers)
      expect(find.byType(SizedBox), findsNWidgets(2));
    });

    testWidgets('circles use circle shape', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballBeat,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallBeat(),
          ),
        ),
      );

      // Verify all indicators use circle shape
      final circles = tester.widgetList<IndicatorShapeWidget>(
        find.byType(IndicatorShapeWidget),
      );
      for (final circle in circles) {
        expect(circle.shape, equals(Shape.circle));
      }
    });

    testWidgets('animations are properly phased', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballBeat,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallBeat(),
          ),
        ),
      );

      // Initial pump to start animations
      await tester.pump();

      // Get initial values
      final initialScales = _getScales(tester);
      final initialOpacities = _getOpacities(tester);

      // Verify initial state
      expect(
        initialScales[1],
        equals(1.0),
        reason: 'Middle circle should start at scale 1.0',
      );
      expect(
        initialScales[0],
        equals(initialScales[2]),
        reason: 'Outer circles should be in sync',
      );

      // Let animations run for half the duration
      await tester.pump(const Duration(milliseconds: 350));

      // Get values after delay
      final delayedScales = _getScales(tester);
      final delayedOpacities = _getOpacities(tester);

      // Verify that middle circle has started animating
      expect(
        delayedScales[1],
        isNot(equals(initialScales[1])),
        reason: 'Middle circle should have animated',
      );

      // Verify that outer circles are still in sync with each other
      expect(
        delayedScales[0],
        equals(delayedScales[2]),
        reason: 'Outer circles should remain in sync',
      );

      // Verify that outer circles have different values than middle circle
      expect(
        delayedScales[0],
        isNot(equals(delayedScales[1])),
        reason: 'Outer circles should be out of phase with middle circle',
      );

      // Same verification for opacity
      expect(
        delayedOpacities[1],
        isNot(equals(initialOpacities[1])),
        reason: 'Middle circle opacity should have changed',
      );
      expect(
        delayedOpacities[0],
        equals(delayedOpacities[2]),
        reason: 'Outer circles opacity should be in sync',
      );
      expect(
        delayedOpacities[0],
        isNot(equals(delayedOpacities[1])),
        reason:
            'Outer circles opacity should be out of phase with middle circle',
      );
    });

    testWidgets('responds to pause state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballBeat,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallBeat(),
          ),
        ),
      );

      // Get initial values
      final initialScales = _getScales(tester);
      final initialOpacities = _getOpacities(tester);

      // Let animations run
      await tester.pump(const Duration(milliseconds: 350));

      // Values should have changed
      final runningScales = _getScales(tester);
      final runningOpacities = _getOpacities(tester);
      expect(runningScales, isNot(equals(initialScales)));
      expect(runningOpacities, isNot(equals(initialOpacities)));

      // Update to paused state
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballBeat,
              colors: const [Colors.blue],
              pause: true,
            ),
            child: const BallBeat(),
          ),
        ),
      );

      // Get values after pause
      final pausedScales = _getScales(tester);
      final pausedOpacities = _getOpacities(tester);

      // Wait some more
      await tester.pump(const Duration(milliseconds: 350));

      // Values should not have changed while paused
      expect(_getScales(tester), equals(pausedScales));
      expect(_getOpacities(tester), equals(pausedOpacities));
    });
  });
}

/// Helper function to get current scale values of all circles
List<double> _getScales(WidgetTester tester) {
  return tester
      .widgetList<ScaleTransition>(find.byType(ScaleTransition))
      .map((t) => t.scale.value)
      .toList();
}

/// Helper function to get current opacity values of all circles
List<double> _getOpacities(WidgetTester tester) {
  return tester
      .widgetList<FadeTransition>(find.byType(FadeTransition))
      .map((t) => t.opacity.value)
      .toList();
}

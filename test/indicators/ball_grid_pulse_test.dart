import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/indicators/ball_grid_pulse.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

void main() {
  group('BallGridPulse', () {
    testWidgets('renders correct number of shapes and transitions', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballGridPulse,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallGridPulse(),
          ),
        ),
      );

      // Should find 9 circles
      expect(find.byType(IndicatorShapeWidget), findsNWidgets(9));

      // Should find 9 ScaleTransitions
      expect(find.byType(ScaleTransition), findsNWidgets(9));

      // Should find 9 FadeTransitions
      expect(find.byType(FadeTransition), findsNWidgets(9));

      // Should find 1 GridView
      expect(find.byType(GridView), findsNWidgets(1));
    });

    testWidgets('shapes use correct type and indices', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballGridPulse,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallGridPulse(),
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
      for (int i = 0; i < 9; i++) {
        expect(shapes[i].shape, equals(Shape.circle));
        expect(shapes[i].index, equals(i));
      }
    });

    testWidgets('grid has correct layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballGridPulse,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallGridPulse(),
          ),
        ),
      );

      // Get the GridView
      final grid = tester.widget<GridView>(find.byType(GridView));

      // Verify grid properties
      expect(grid.childrenDelegate.estimatedChildCount, equals(9));
      expect(
        (grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
            .crossAxisCount,
        equals(3),
      );
      expect(
        (grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
            .mainAxisSpacing,
        equals(2),
      );
      expect(
        (grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
            .crossAxisSpacing,
        equals(2),
      );
    });

    testWidgets('animations are properly configured', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballGridPulse,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallGridPulse(),
          ),
        ),
      );

      // Initial pump to start animations
      await tester.pump();

      // Get initial values
      final initialScales =
          tester
              .widgetList<ScaleTransition>(find.byType(ScaleTransition))
              .map((s) => s.scale.value)
              .toList();
      final initialOpacities =
          tester
              .widgetList<FadeTransition>(find.byType(FadeTransition))
              .map((f) => f.opacity.value)
              .toList();

      // Let animations run for a short duration
      await tester.pump(const Duration(milliseconds: 100));

      // Get values after short delay
      final shortDelayScales =
          tester
              .widgetList<ScaleTransition>(find.byType(ScaleTransition))
              .map((s) => s.scale.value)
              .toList();
      final shortDelayOpacities =
          tester
              .widgetList<FadeTransition>(find.byType(FadeTransition))
              .map((f) => f.opacity.value)
              .toList();

      // Verify that at least one circle has started animating
      expect(
        shortDelayScales.any((scale) => scale != initialScales[0]),
        isTrue,
        reason: 'At least one circle should have started scaling',
      );
      expect(
        shortDelayOpacities.any((opacity) => opacity != initialOpacities[0]),
        isTrue,
        reason: 'At least one circle should have started fading',
      );

      // Let animations run longer
      await tester.pump(const Duration(milliseconds: 300));

      // Get values after longer delay
      final longerDelayScales =
          tester
              .widgetList<ScaleTransition>(find.byType(ScaleTransition))
              .map((s) => s.scale.value)
              .toList();
      final longerDelayOpacities =
          tester
              .widgetList<FadeTransition>(find.byType(FadeTransition))
              .map((f) => f.opacity.value)
              .toList();

      // Verify that animations are running
      expect(
        longerDelayScales.any((scale) => scale != initialScales[0]),
        isTrue,
        reason: 'Circles should be animating',
      );
      expect(
        longerDelayOpacities.any((opacity) => opacity != initialOpacities[0]),
        isTrue,
        reason: 'Circles should be fading',
      );

      // Verify scale values stay within bounds
      for (final scale in [...shortDelayScales, ...longerDelayScales]) {
        expect(
          scale >= 0.5 && scale <= 1.0,
          isTrue,
          reason: 'Circle scales should stay between 0.5 and 1.0',
        );
      }

      // Verify opacity values stay within bounds
      for (final opacity in [...shortDelayOpacities, ...longerDelayOpacities]) {
        expect(
          opacity >= 0.7 && opacity <= 1.0,
          isTrue,
          reason: 'Circle opacities should stay between 0.7 and 1.0',
        );
      }

      // Verify that different circles have different values
      final uniqueScales = longerDelayScales.toSet();
      final uniqueOpacities = longerDelayOpacities.toSet();
      expect(
        uniqueScales.length > 1,
        isTrue,
        reason: 'Different circles should have different scale values',
      );
      expect(
        uniqueOpacities.length > 1,
        isTrue,
        reason: 'Different circles should have different opacity values',
      );
    });

    testWidgets('responds to pause state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballGridPulse,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const BallGridPulse(),
          ),
        ),
      );

      // Get initial values
      final initialValues =
          tester
              .widgetList<ScaleTransition>(find.byType(ScaleTransition))
              .map(
                (s) => {
                  'scale': s.scale.value,
                  'opacity': (s.child as FadeTransition).opacity.value,
                },
              )
              .toList();

      // Let animations run
      await tester.pump(const Duration(milliseconds: 300));

      // Values should have changed
      final runningValues =
          tester
              .widgetList<ScaleTransition>(find.byType(ScaleTransition))
              .map(
                (s) => {
                  'scale': s.scale.value,
                  'opacity': (s.child as FadeTransition).opacity.value,
                },
              )
              .toList();
      expect(runningValues, isNot(equals(initialValues)));

      // Update to paused state
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballGridPulse,
              colors: const [Colors.blue],
              pause: true,
            ),
            child: const BallGridPulse(),
          ),
        ),
      );

      // Get values after pause
      final pausedValues =
          tester
              .widgetList<ScaleTransition>(find.byType(ScaleTransition))
              .map(
                (s) => {
                  'scale': s.scale.value,
                  'opacity': (s.child as FadeTransition).opacity.value,
                },
              )
              .toList();

      // Let some time pass
      await tester.pump(const Duration(milliseconds: 300));

      // Get values after waiting while paused
      final stillPausedValues =
          tester
              .widgetList<ScaleTransition>(find.byType(ScaleTransition))
              .map(
                (s) => {
                  'scale': s.scale.value,
                  'opacity': (s.child as FadeTransition).opacity.value,
                },
              )
              .toList();

      // Verify values haven't changed while paused
      expect(
        stillPausedValues,
        equals(pausedValues),
        reason: 'Animation values should not change while paused',
      );
    });
  });
}

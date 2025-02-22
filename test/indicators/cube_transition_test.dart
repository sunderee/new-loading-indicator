import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/indicators/cube_transition.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

void main() {
  group('CubeTransition', () {
    testWidgets('renders correct number of shapes and transforms', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.cubeTransition,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const CubeTransition(),
          ),
        ),
      );

      // Should find 2 squares
      expect(find.byType(IndicatorShapeWidget), findsNWidgets(2));

      // Should find 2 Transform widgets
      expect(find.byType(Transform), findsNWidgets(2));

      // Should find 2 Positioned widgets
      expect(find.byType(Positioned), findsNWidgets(2));

      // Should find 1 Stack
      expect(find.byType(Stack), findsNWidgets(1));

      // Should find 1 AnimatedBuilder
      expect(
        find.descendant(
          of: find.byType(CubeTransition),
          matching: find.byType(AnimatedBuilder),
        ),
        findsOneWidget,
      );
    });

    testWidgets('shapes use correct type and indices', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.cubeTransition,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const CubeTransition(),
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

      // Verify all shapes are rectangles with correct indices
      for (int i = 0; i < 2; i++) {
        expect(shapes[i].shape, equals(Shape.rectangle));
        expect(shapes[i].index, equals(i));
      }
    });

    testWidgets(
      'squares move in opposite directions with rotation and scaling',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SizedBox(
              width: 100,
              height: 100,
              child: DecorateContext(
                decorateData: DecorateData(
                  indicator: Indicator.cubeTransition,
                  colors: const [Colors.blue],
                  pause: false,
                ),
                child: const CubeTransition(),
              ),
            ),
          ),
        );

        // Initial pump to start animations
        await tester.pump();

        // Get initial transforms
        final initialTransforms =
            tester.widgetList<Transform>(find.byType(Transform)).toList();
        final initialTranslations =
            initialTransforms.map((t) => t.transform.getTranslation()).toList();
        final initialRotations =
            initialTransforms.map((t) => t.transform.getRotation()).toList();
        final initialScales =
            initialTransforms
                .map((t) => t.transform.getMaxScaleOnAxis())
                .toList();

        // Let animations run for a short duration
        await tester.pump(const Duration(milliseconds: 400));

        // Get transforms after delay
        final delayedTransforms =
            tester.widgetList<Transform>(find.byType(Transform)).toList();
        final delayedTranslations =
            delayedTransforms.map((t) => t.transform.getTranslation()).toList();
        final delayedRotations =
            delayedTransforms.map((t) => t.transform.getRotation()).toList();
        final delayedScales =
            delayedTransforms
                .map((t) => t.transform.getMaxScaleOnAxis())
                .toList();

        // Verify that both squares have moved
        for (int i = 0; i < 2; i++) {
          expect(
            delayedTranslations[i] != initialTranslations[i],
            isTrue,
            reason: 'Square $i should have moved',
          );
        }

        // Verify that squares move in opposite directions
        expect(
          (delayedTranslations[0].x - initialTranslations[0].x).sign,
          equals(-(delayedTranslations[1].x - initialTranslations[1].x).sign),
          reason: 'Squares should move in opposite horizontal directions',
        );

        expect(
          (delayedTranslations[0].y - initialTranslations[0].y).sign,
          equals(-(delayedTranslations[1].y - initialTranslations[1].y).sign),
          reason: 'Squares should move in opposite vertical directions',
        );

        // Verify that squares have rotated
        for (int i = 0; i < 2; i++) {
          expect(
            delayedRotations[i] != initialRotations[i],
            isTrue,
            reason: 'Square $i should have rotated',
          );
        }

        // Verify that squares have scaled
        for (int i = 0; i < 2; i++) {
          expect(
            delayedScales[i] != initialScales[i],
            isTrue,
            reason: 'Square $i should have scaled',
          );
        }

        // Let animations run longer
        await tester.pump(const Duration(milliseconds: 800));

        // Get transforms after longer delay
        final longerDelayTransforms =
            tester.widgetList<Transform>(find.byType(Transform)).toList();
        final longerDelayTranslations =
            longerDelayTransforms
                .map((t) => t.transform.getTranslation())
                .toList();
        final longerDelayRotations =
            longerDelayTransforms
                .map((t) => t.transform.getRotation())
                .toList();
        final longerDelayScales =
            longerDelayTransforms
                .map((t) => t.transform.getMaxScaleOnAxis())
                .toList();

        // Verify that positions have changed further
        for (int i = 0; i < 2; i++) {
          expect(
            longerDelayTranslations[i] != delayedTranslations[i],
            isTrue,
            reason: 'Square $i should have continued moving',
          );
        }

        // Verify scale bounds
        for (final scale in longerDelayScales) {
          expect(
            scale >= 0.5 && scale <= 1.0,
            isTrue,
            reason: 'Scale should stay between 0.5 and 1.0',
          );
        }

        // Verify rotation progression
        for (int i = 0; i < 2; i++) {
          expect(
            longerDelayRotations[i] != delayedRotations[i],
            isTrue,
            reason: 'Square $i should have continued rotating',
          );
        }
      },
    );

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
                  indicator: Indicator.cubeTransition,
                  colors: const [Colors.blue],
                  pause: false,
                ),
                child: const CubeTransition(),
              ),
            ),
          ),
        ),
      );

      // Find the root widget's render box
      final renderBox = tester.renderObject<RenderBox>(
        find.byType(CubeTransition),
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

      // Verify square sizes are proportional to container width
      final squareSize = containerSize.width / 5;
      final squares = tester.widgetList<Positioned>(find.byType(Positioned));
      for (final square in squares) {
        expect(
          square.width,
          equals(squareSize),
          reason: 'Square width should be one-fifth of container width',
        );
        expect(
          square.height,
          equals(squareSize),
          reason: 'Square height should be one-fifth of container width',
        );
      }
    });
  });
}

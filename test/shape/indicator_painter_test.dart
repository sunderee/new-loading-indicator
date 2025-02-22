import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

void main() {
  group('IndicatorShapeWidget', () {
    const shapeKey = Key('indicator_shape');

    testWidgets('renders circle shape correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballPulse,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const IndicatorShapeWidget(
              key: shapeKey,
              shape: Shape.circle,
            ),
          ),
        ),
      );

      expect(find.byKey(shapeKey), findsOneWidget);
      final widget = tester.widget<IndicatorShapeWidget>(find.byKey(shapeKey));
      expect(widget.shape, equals(Shape.circle));
    });

    testWidgets('respects minimum size constraints', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballPulse,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const SizedBox(
              width: 20, // Less than minimum
              height: 20, // Less than minimum
              child: IndicatorShapeWidget(key: shapeKey, shape: Shape.circle),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byKey(shapeKey),
          matching: find.byType(Container),
        ),
      );
      expect(
        container.constraints?.minWidth,
        36.0, // _kMinIndicatorSize
      );
      expect(
        container.constraints?.minHeight,
        36.0, // _kMinIndicatorSize
      );
    });

    testWidgets('cycles through colors based on index', (tester) async {
      const colors = [Colors.red, Colors.blue, Colors.green];

      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballPulse,
              colors: colors,
              pause: false,
            ),
            child: const Column(
              children: [
                IndicatorShapeWidget(
                  key: Key('shape_0'),
                  shape: Shape.circle,
                  index: 0,
                ),
                IndicatorShapeWidget(
                  key: Key('shape_1'),
                  shape: Shape.circle,
                  index: 1,
                ),
                IndicatorShapeWidget(
                  key: Key('shape_2'),
                  shape: Shape.circle,
                  index: 2,
                ),
                IndicatorShapeWidget(
                  key: Key('shape_3'),
                  shape: Shape.circle,
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      );

      // Verify each shape is rendered
      for (var i = 0; i < 4; i++) {
        expect(find.byKey(Key('shape_$i')), findsOneWidget);
      }
    });

    testWidgets('renders arc shape with data parameter', (tester) async {
      const arcKey = Key('arc_shape');
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballPulse,
              colors: const [Colors.blue],
              pause: false,
            ),
            child: const IndicatorShapeWidget(
              key: arcKey,
              shape: Shape.arc,
              data: 0.5, // Half circle
            ),
          ),
        ),
      );

      expect(find.byKey(arcKey), findsOneWidget);
      final widget = tester.widget<IndicatorShapeWidget>(find.byKey(arcKey));
      expect(widget.shape, equals(Shape.arc));
      expect(widget.data, equals(0.5));
    });

    testWidgets('renders with stroke width and path color', (tester) async {
      const ringKey = Key('ring_shape');
      await tester.pumpWidget(
        MaterialApp(
          home: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.ballPulse,
              colors: const [Colors.blue],
              strokeWidth: 2.0,
              pathBackgroundColor: Colors.grey,
              pause: false,
            ),
            child: const IndicatorShapeWidget(
              key: ringKey,
              shape: Shape.ringThirdFour,
            ),
          ),
        ),
      );

      expect(find.byKey(ringKey), findsOneWidget);
      final widget = tester.widget<IndicatorShapeWidget>(find.byKey(ringKey));
      expect(widget.shape, equals(Shape.ringThirdFour));
    });
  });
}

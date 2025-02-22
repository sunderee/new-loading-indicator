import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/src/transition/scale_y_transition.dart';

void main() {
  group('ScaleYTransition', () {
    testWidgets('scales child vertically based on animation value', (
      tester,
    ) async {
      const childKey = Key('child');
      final controller = AnimationController(
        vsync: tester,
        duration: const Duration(seconds: 1),
      );
      final animation = Tween<double>(begin: 1.0, end: 2.0).animate(controller);

      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: ScaleYTransition(
              scaleY: animation,
              child: Container(
                key: childKey,
                width: 100.0,
                height: 100.0,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      // Initial scale should be 1.0
      var transform = tester.widget<Transform>(
        find.ancestor(
          of: find.byKey(childKey),
          matching: find.byType(Transform),
        ),
      );
      var matrix = transform.transform;
      expect(matrix.getRow(1)[1], 1.0); // Y scale should be 1.0

      // Animate to halfway
      controller.value = 0.5;
      await tester.pump();

      transform = tester.widget<Transform>(
        find.ancestor(
          of: find.byKey(childKey),
          matching: find.byType(Transform),
        ),
      );
      matrix = transform.transform;
      expect(matrix.getRow(1)[1], closeTo(1.5, 0.01)); // Y scale should be 1.5

      // Animate to end
      controller.value = 1.0;
      await tester.pump();

      transform = tester.widget<Transform>(
        find.ancestor(
          of: find.byKey(childKey),
          matching: find.byType(Transform),
        ),
      );
      matrix = transform.transform;
      expect(matrix.getRow(1)[1], 2.0); // Y scale should be 2.0
    });

    testWidgets('respects alignment property', (tester) async {
      const childKey = Key('child');
      final controller = AnimationController(vsync: tester, value: 1.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: ScaleYTransition(
              scaleY: controller,
              alignment: Alignment.topCenter,
              child: Container(
                key: childKey,
                width: 100.0,
                height: 100.0,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      final transform = tester.widget<Transform>(
        find.ancestor(
          of: find.byKey(childKey),
          matching: find.byType(Transform),
        ),
      );
      expect(transform.alignment, Alignment.topCenter);
    });

    testWidgets('handles null child', (tester) async {
      final controller = AnimationController(vsync: tester, value: 1.0);

      await tester.pumpWidget(
        MaterialApp(home: Center(child: ScaleYTransition(scaleY: controller))),
      );

      expect(find.byType(Transform), findsOneWidget);
      final transform = tester.widget<Transform>(find.byType(Transform));
      expect(transform.child, isNull);
    });

    testWidgets('only scales in Y direction', (tester) async {
      const childKey = Key('child');
      final controller = AnimationController(vsync: tester, value: 1.0);
      final animation = Tween<double>(begin: 1.0, end: 2.0).animate(controller);

      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: ScaleYTransition(
              scaleY: animation,
              child: Container(
                key: childKey,
                width: 100.0,
                height: 100.0,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      final transform = tester.widget<Transform>(
        find.ancestor(
          of: find.byKey(childKey),
          matching: find.byType(Transform),
        ),
      );

      // Extract the scale values from the transform matrix
      final matrix = transform.transform;
      expect(matrix.getRow(0)[0], 1.0); // X scale should be 1.0
      expect(matrix.getRow(1)[1], 2.0); // Y scale should be 2.0
      expect(matrix.getRow(2)[2], 1.0); // Z scale should be 1.0
    });
  });
}

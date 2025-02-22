import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/indicators/square_spin.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

void main() {
  group('SquareSpin', () {
    Widget buildTestWidget({
      bool pause = false,
      List<Color>? colors,
      double? containerSize,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.squareSpin,
              pause: pause,
              colors: colors ?? [Colors.black],
            ),
            child: SizedBox(
              width: containerSize ?? 100,
              height: containerSize ?? 100,
              child: const SquareSpin(),
            ),
          ),
        ),
      );
    }

    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(SquareSpin), findsOneWidget);

      // Find the Transform widget that's a descendant of SquareSpin
      expect(
        find.descendant(
          of: find.byType(SquareSpin),
          matching: find.byType(Transform),
        ),
        findsOneWidget,
      );

      // Verify the rectangle shape is rendered
      expect(
        find.descendant(
          of: find.byType(SquareSpin),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is IndicatorShapeWidget &&
                widget.shape == Shape.rectangle,
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets('animation is initialized and running', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Initial state
      await tester.pump();
      final state = tester.state(find.byType(SquareSpin));
      final controller =
          (state as dynamic).animationControllers.first as AnimationController;

      // Verify animation controller
      expect(controller.isAnimating, isTrue);
      expect(controller.duration, equals(const Duration(milliseconds: 3000)));

      // Verify animation after some time
      await tester.pump(const Duration(milliseconds: 750));
      expect(controller.isAnimating, isTrue);
      expect(controller.value, greaterThan(0));
    });

    testWidgets('layout is responsive', (tester) async {
      const testSize = 200.0;
      await tester.pumpWidget(buildTestWidget(containerSize: testSize));

      final indicatorFinder = find.byType(SquareSpin);
      expect(indicatorFinder, findsOneWidget);

      final indicatorSize = tester.getSize(indicatorFinder);
      expect(indicatorSize.width, equals(testSize));
      expect(indicatorSize.height, equals(testSize));
    });

    testWidgets('disposes animation properly', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final state = tester.state(find.byType(SquareSpin));
      final controller =
          (state as dynamic).animationControllers.first as AnimationController;

      // Store the controller status before disposal
      expect(
        controller.isAnimating,
        isTrue,
        reason: 'Controller should be running initially',
      );

      // Trigger disposal
      await tester.pumpWidget(const SizedBox());
      await tester.pump();

      // Verify controller is disposed
      expect(
        controller.isAnimating,
        isFalse,
        reason: 'Controller should not be animating after disposal',
      );
      expect(
        () => controller.dispose(),
        throwsFlutterError,
        reason: 'Controller should already be disposed',
      );
    });

    testWidgets('pauses and resumes animation', (tester) async {
      // Start with animation running
      await tester.pumpWidget(buildTestWidget(pause: false));

      final state = tester.state(find.byType(SquareSpin));
      final controller =
          (state as dynamic).animationControllers.first as AnimationController;

      // Verify animation is running
      expect(controller.isAnimating, isTrue);

      // Pause animation
      await tester.pumpWidget(buildTestWidget(pause: true));
      await tester.pump();

      // Verify animation is paused
      expect(controller.isAnimating, isFalse);

      // Resume animation
      await tester.pumpWidget(buildTestWidget(pause: false));
      await tester.pump();

      // Verify animation is running again
      expect(controller.isAnimating, isTrue);
    });

    testWidgets('completes all rotation phases', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final state = tester.state(find.byType(SquareSpin));
      final controller =
          (state as dynamic).animationControllers.first as AnimationController;

      // Helper function to get the Transform widget
      Transform getTransform() {
        return tester.widget<Transform>(
          find.descendant(
            of: find.byType(SquareSpin),
            matching: find.byType(Transform),
          ),
        );
      }

      // Phase 1: X-axis rotation (0-25%)
      controller.value = 0.125; // Midpoint of phase 1
      await tester.pump();
      final transform1 = getTransform();
      expect(
        transform1.transform.storage[5],
        isNot(1.0),
        reason: 'Should have X rotation at 12.5%',
      );
      expect(
        transform1.transform.storage[0],
        equals(1.0),
        reason: 'Should not have Y rotation yet',
      );

      // Phase 2: Y-axis rotation (25-50%)
      controller.value = 0.375; // Midpoint of phase 2
      await tester.pump();
      final transform2 = getTransform();
      expect(
        transform2.transform.storage[5],
        isNot(1.0),
        reason: 'Should have X rotation at 37.5%',
      );
      expect(
        transform2.transform.storage[0],
        isNot(1.0),
        reason: 'Should have Y rotation at 37.5%',
      );

      // Phase 3: X-axis rotation back (50-75%)
      controller.value = 0.625; // Midpoint of phase 3
      await tester.pump();
      final transform3 = getTransform();
      expect(
        transform3.transform.storage[5],
        isNot(1.0),
        reason: 'Should have X rotation at 62.5%',
      );
      expect(
        transform3.transform.storage[0],
        isNot(1.0),
        reason: 'Should have Y rotation at 62.5%',
      );

      // Phase 4: Y-axis rotation completion (75-100%)
      controller.value = 0.875; // Midpoint of phase 4
      await tester.pump();
      final transform4 = getTransform();
      expect(
        transform4.transform.storage[5],
        closeTo(1.0, 0.1),
        reason: 'X rotation should be back to 0',
      );
      expect(
        transform4.transform.storage[0],
        isNot(1.0),
        reason: 'Should have Y rotation at 87.5%',
      );

      // Verify perspective is set
      expect(
        getTransform().transform.storage[11],
        closeTo(0.006, 0.002),
        reason: 'Should have perspective set for 3D effect',
      );
    });
  });
}

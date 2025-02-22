import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/indicators/semi_circle_spin.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

void main() {
  group('SemiCircleSpin', () {
    Widget buildTestWidget({
      bool pause = false,
      List<Color>? colors,
      double? containerSize,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.semiCircleSpin,
              pause: pause,
              colors: colors ?? [Colors.black],
            ),
            child: SizedBox(
              width: containerSize ?? 100,
              height: containerSize ?? 100,
              child: const SemiCircleSpin(),
            ),
          ),
        ),
      );
    }

    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(SemiCircleSpin), findsOneWidget);

      // Find the RotationTransition widget that's a descendant of SemiCircleSpin
      expect(
        find.descendant(
          of: find.byType(SemiCircleSpin),
          matching: find.byType(RotationTransition),
        ),
        findsOneWidget,
      );

      // Verify the semi-circle shape is rendered
      expect(
        find.descendant(
          of: find.byType(SemiCircleSpin),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is IndicatorShapeWidget &&
                widget.shape == Shape.circleSemi,
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets('animation is initialized and running', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Initial state
      await tester.pump();
      final state = tester.state(find.byType(SemiCircleSpin));
      final controller =
          (state as dynamic).animationControllers.first as AnimationController;

      // Verify animation controller
      expect(controller.isAnimating, isTrue);
      expect(controller.duration, equals(const Duration(milliseconds: 600)));

      // Verify animation after some time
      await tester.pump(const Duration(milliseconds: 300));
      expect(controller.isAnimating, isTrue);
      expect(controller.value, greaterThan(0));
    });

    testWidgets('layout is responsive', (tester) async {
      const testSize = 200.0;
      await tester.pumpWidget(buildTestWidget(containerSize: testSize));

      final indicatorFinder = find.byType(SemiCircleSpin);
      expect(indicatorFinder, findsOneWidget);

      final indicatorSize = tester.getSize(indicatorFinder);
      expect(indicatorSize.width, equals(testSize));
      expect(indicatorSize.height, equals(testSize));
    });

    testWidgets('disposes animation properly', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final state = tester.state(find.byType(SemiCircleSpin));
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

      final state = tester.state(find.byType(SemiCircleSpin));
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

    testWidgets('completes full rotation', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final state = tester.state(find.byType(SemiCircleSpin));
      final controller =
          (state as dynamic).animationControllers.first as AnimationController;

      // Start at 0
      controller.reset();
      await tester.pump();
      expect(controller.value, equals(0.0));

      // Move to quarter rotation (90°)
      controller.value = 0.25;
      await tester.pump();
      expect(controller.value, equals(0.25));

      // Move to half rotation (180°)
      controller.value = 0.5;
      await tester.pump();
      expect(controller.value, equals(0.5));

      // Move to three-quarter rotation (270°)
      controller.value = 0.75;
      await tester.pump();
      expect(controller.value, equals(0.75));

      // Complete rotation (360°)
      controller.value = 1.0;
      await tester.pump();
      expect(controller.value, equals(1.0));

      // Verify the rotation transition is present
      expect(
        find.descendant(
          of: find.byType(SemiCircleSpin),
          matching: find.byType(RotationTransition),
        ),
        findsOneWidget,
      );
    });
  });
}

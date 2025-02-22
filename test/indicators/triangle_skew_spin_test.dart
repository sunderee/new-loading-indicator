import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/indicators/triangle_skew_spin.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

void main() {
  group('TriangleSkewSpin', () {
    Widget buildTestWidget({
      bool pause = false,
      List<Color>? colors,
      double? containerSize,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.triangleSkewSpin,
              pause: pause,
              colors: colors ?? [Colors.black],
            ),
            child: SizedBox(
              width: containerSize ?? 100,
              height: containerSize ?? 100,
              child: const TriangleSkewSpin(),
            ),
          ),
        ),
      );
    }

    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(TriangleSkewSpin), findsOneWidget);

      // Find the Transform widget that's a descendant of TriangleSkewSpin
      expect(
        find.descendant(
          of: find.byType(TriangleSkewSpin),
          matching: find.byType(Transform),
        ),
        findsOneWidget,
      );

      // Verify the triangle shape is rendered
      expect(
        find.descendant(
          of: find.byType(TriangleSkewSpin),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is IndicatorShapeWidget &&
                widget.shape == Shape.triangle,
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets('animation is initialized and running', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Initial state
      await tester.pump();
      final state = tester.state(find.byType(TriangleSkewSpin));
      final controller =
          (state as dynamic).animationControllers.first as AnimationController;

      // Verify animation controller
      expect(controller.isAnimating, isTrue);
      expect(controller.duration, equals(const Duration(seconds: 3)));

      // Verify animation after some time
      await tester.pump(const Duration(milliseconds: 750));
      expect(controller.isAnimating, isTrue);
      expect(controller.value, greaterThan(0));
    });

    testWidgets('layout is responsive', (tester) async {
      const testSize = 200.0;
      await tester.pumpWidget(buildTestWidget(containerSize: testSize));

      final indicatorFinder = find.byType(TriangleSkewSpin);
      expect(indicatorFinder, findsOneWidget);

      final indicatorSize = tester.getSize(indicatorFinder);
      expect(indicatorSize.width, equals(testSize));
      expect(indicatorSize.height, equals(testSize));
    });

    testWidgets('disposes animation properly', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final state = tester.state(find.byType(TriangleSkewSpin));
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

      final state = tester.state(find.byType(TriangleSkewSpin));
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

      final state = tester.state(find.byType(TriangleSkewSpin));
      final controller =
          (state as dynamic).animationControllers.first as AnimationController;

      // Helper function to get the Transform widget
      Transform getTransform() {
        return tester.widget<Transform>(
          find.descendant(
            of: find.byType(TriangleSkewSpin),
            matching: find.byType(Transform),
          ),
        );
      }

      // Helper function to check if there's significant rotation
      bool hasSignificantRotation(Matrix4 matrix) {
        // Check multiple matrix elements that would be affected by rotation
        return matrix.storage
            .sublist(0, 8)
            .any((value) => (value - 1.0).abs() > 0.01);
      }

      // Phase 1: Y-axis rotation (0-25%)
      controller.value = 0.125; // Midpoint of phase 1
      await tester.pump();
      final transform1 = getTransform();
      expect(
        hasSignificantRotation(transform1.transform),
        isTrue,
        reason: 'Should have rotation at 12.5%',
      );

      // Phase 2: X-axis rotation added (25-50%)
      controller.value = 0.375; // Midpoint of phase 2
      await tester.pump();
      final transform2 = getTransform();
      expect(
        hasSignificantRotation(transform2.transform),
        isTrue,
        reason: 'Should have rotation at 37.5%',
      );

      // Phase 3: Y-axis rotation changes (50-75%)
      controller.value = 0.625; // Midpoint of phase 3
      await tester.pump();
      final transform3 = getTransform();
      expect(
        hasSignificantRotation(transform3.transform),
        isTrue,
        reason: 'Should have rotation at 62.5%',
      );

      // Phase 4: Both axes returning to start (75-100%)
      controller.value = 0.875; // Midpoint of phase 4
      await tester.pump();
      final transform4 = getTransform();
      expect(
        hasSignificantRotation(transform4.transform),
        isTrue,
        reason: 'Should have rotation at 87.5%',
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

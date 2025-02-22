import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/indicators/pacman.dart';
import 'package:new_loading_indicator/src/shape/indicator_painter.dart';

void main() {
  group('Pacman', () {
    Widget buildTestWidget({
      bool pause = false,
      List<Color>? colors,
      double? containerSize,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: DecorateContext(
            decorateData: DecorateData(
              indicator: Indicator.pacman,
              pause: pause,
              colors: colors ?? [Colors.black],
            ),
            child: SizedBox(
              width: containerSize ?? 100,
              height: containerSize ?? 100,
              child: const Pacman(),
            ),
          ),
        ),
      );
    }

    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(Pacman), findsOneWidget);

      // Find the Stack widget that's a descendant of Pacman
      expect(
        find.descendant(of: find.byType(Pacman), matching: find.byType(Stack)),
        findsOneWidget,
      );

      // Verify the number of IndicatorShapeWidget instances (1 pacman + 2 dots)
      expect(find.byType(IndicatorShapeWidget), findsNWidgets(3));
    });

    testWidgets('animations are initialized and running', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Initial state
      await tester.pump();
      final state = tester.state(find.byType(Pacman));
      final controllers =
          (state as dynamic).animationControllers as List<AnimationController>;

      // Verify animation controllers
      expect(controllers.length, equals(3)); // 1 pacman + 2 dots
      for (final controller in controllers) {
        expect(controller.isAnimating, isTrue);
      }

      // Verify animations after some time
      await tester.pump(const Duration(milliseconds: 250));
      for (final controller in controllers) {
        expect(controller.isAnimating, isTrue);
      }
    });

    testWidgets('layout is responsive', (tester) async {
      const testSize = 200.0;
      await tester.pumpWidget(buildTestWidget(containerSize: testSize));

      final pacmanFinder = find.byType(Pacman);
      expect(pacmanFinder, findsOneWidget);

      final pacmanSize = tester.getSize(pacmanFinder);
      expect(pacmanSize.width, equals(testSize));
      expect(pacmanSize.height, equals(testSize));
    });

    testWidgets('disposes animations properly', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final state = tester.state(find.byType(Pacman));
      final controllers =
          (state as dynamic).animationControllers as List<AnimationController>;

      // Store the controller status before disposal
      final controllerStatus = controllers.map((c) => c.isAnimating).toList();
      expect(
        controllerStatus,
        everyElement(isTrue),
        reason: 'All controllers should be running initially',
      );

      // Trigger disposal
      await tester.pumpWidget(const SizedBox());
      await tester.pump();

      // Verify controllers are disposed
      for (final controller in controllers) {
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
      }
    });

    testWidgets('pauses and resumes animations', (tester) async {
      // Start with animations running
      await tester.pumpWidget(buildTestWidget(pause: false));

      final state = tester.state(find.byType(Pacman));
      final controllers =
          (state as dynamic).animationControllers as List<AnimationController>;

      // Verify animations are running
      for (final controller in controllers) {
        expect(controller.isAnimating, isTrue);
      }

      // Pause animations
      await tester.pumpWidget(buildTestWidget(pause: true));
      await tester.pump();

      // Verify animations are paused
      for (final controller in controllers) {
        expect(controller.isAnimating, isFalse);
      }

      // Resume animations
      await tester.pumpWidget(buildTestWidget(pause: false));
      await tester.pump();

      // Verify animations are running again
      for (final controller in controllers) {
        expect(controller.isAnimating, isTrue);
      }
    });
  });
}

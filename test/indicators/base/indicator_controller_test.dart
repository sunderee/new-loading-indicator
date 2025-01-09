import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';
import 'package:new_loading_indicator/src/indicators/base/indicator_controller.dart';

// Test implementation of a widget using IndicatorController
class TestIndicator extends StatefulWidget {
  final bool initialPause;

  const TestIndicator({super.key, this.initialPause = false});

  @override
  State<TestIndicator> createState() => TestIndicatorState();
}

class TestIndicatorState extends State<TestIndicator>
    with TickerProviderStateMixin, IndicatorController {
  late final AnimationController _controller;
  bool get isControllerAnimating => _controller.isAnimating;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    if (!widget.initialPause) {
      _controller.repeat();
    }
  }

  @override
  List<AnimationController> get animationControllers => [_controller];

  @override
  Widget build(BuildContext context) {
    return Container(); // Dummy widget for testing
  }
}

void main() {
  group('IndicatorController', () {
    testWidgets('initializes with correct pause state', (tester) async {
      await tester.pumpWidget(
        DecorateContext(
          decorateData: DecorateData(
            indicator: Indicator.ballPulse,
            colors: const [Colors.blue],
            pause: true,
          ),
          child: const TestIndicator(),
        ),
      );

      final state =
          tester.state<TestIndicatorState>(find.byType(TestIndicator));
      expect(state.isPaused, isTrue);
      expect(state.isControllerAnimating, isFalse);
    });

    testWidgets('responds to pause state changes', (tester) async {
      await tester.pumpWidget(
        DecorateContext(
          decorateData: DecorateData(
            indicator: Indicator.ballPulse,
            colors: const [Colors.blue],
            pause: false,
          ),
          child: const TestIndicator(),
        ),
      );

      final state =
          tester.state<TestIndicatorState>(find.byType(TestIndicator));
      expect(state.isPaused, isFalse);
      expect(state.isControllerAnimating, isTrue);

      // Update to paused state
      await tester.pumpWidget(
        DecorateContext(
          decorateData: DecorateData(
            indicator: Indicator.ballPulse,
            colors: const [Colors.blue],
            pause: true,
          ),
          child: const TestIndicator(),
        ),
      );

      expect(state.isPaused, isTrue);
      expect(state.isControllerAnimating, isFalse);
    });

    testWidgets('reactivates with correct state', (tester) async {
      await tester.pumpWidget(
        DecorateContext(
          decorateData: DecorateData(
            indicator: Indicator.ballPulse,
            colors: const [Colors.blue],
            pause: true,
          ),
          child: const TestIndicator(),
        ),
      );

      final state =
          tester.state<TestIndicatorState>(find.byType(TestIndicator));

      // Simulate widget reactivation by rebuilding
      await tester.pumpWidget(
        DecorateContext(
          decorateData: DecorateData(
            indicator: Indicator.ballPulse,
            colors: const [Colors.blue],
            pause: true,
          ),
          child: const TestIndicator(),
        ),
      );

      expect(state.isPaused, isTrue);
      expect(state.isControllerAnimating, isFalse);
    });
  });
}

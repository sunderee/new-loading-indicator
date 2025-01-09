import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/indicators/ball_pulse.dart';

void main() {
  group('LoadingIndicator', () {
    testWidgets('renders with default values', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(
              indicatorType: Indicator.ballPulse,
            ),
          ),
        ),
      );

      expect(find.byType(LoadingIndicator), findsOneWidget);
      expect(find.byType(BallPulse), findsOneWidget);
    });

    testWidgets('respects custom colors', (tester) async {
      const customColors = [Colors.red, Colors.blue];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(
              indicatorType: Indicator.ballPulse,
              colors: customColors,
            ),
          ),
        ),
      );

      final widget =
          tester.widget<LoadingIndicator>(find.byType(LoadingIndicator));
      expect(widget.colors, equals(customColors));
    });

    testWidgets('pauses animation when specified', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(
              indicatorType: Indicator.ballPulse,
              pause: true,
            ),
          ),
        ),
      );

      final widget =
          tester.widget<LoadingIndicator>(find.byType(LoadingIndicator));
      expect(widget.pause, isTrue);
    });
  });
}

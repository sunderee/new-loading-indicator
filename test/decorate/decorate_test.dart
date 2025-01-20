import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';

void main() {
  group('DecorateData', () {
    test('creates instance with required parameters', () {
      final data = DecorateData(
        indicator: Indicator.ballPulse,
        colors: const [Colors.blue],
        pause: false,
      );

      expect(data.indicator, equals(Indicator.ballPulse));
      expect(data.colors, equals([Colors.blue]));
      expect(data.pause, isFalse);
      expect(data.backgroundColor, isNull);
      expect(data.pathBackgroundColor, isNull);
      expect(data.strokeWidth, equals(2.0)); // Default stroke width
    });

    test('creates instance with all parameters', () {
      final data = DecorateData(
        indicator: Indicator.ballPulse,
        colors: const [Colors.blue, Colors.red],
        backgroundColor: Colors.white,
        strokeWidth: 3.0,
        pathBackgroundColor: Colors.grey,
        pause: true,
      );

      expect(data.indicator, equals(Indicator.ballPulse));
      expect(data.colors, equals([Colors.blue, Colors.red]));
      expect(data.backgroundColor, equals(Colors.white));
      expect(data.strokeWidth, equals(3.0));
      expect(data.pathBackgroundColor, equals(Colors.grey));
      expect(data.pause, isTrue);
    });

    test('throws assertion error when colors is empty', () {
      expect(
        () => DecorateData(
          indicator: Indicator.ballPulse,
          colors: const [],
          pause: false,
        ),
        throwsAssertionError,
      );
    });

    test('equals and hashCode work correctly', () {
      final data1 = DecorateData(
        indicator: Indicator.ballPulse,
        colors: const [Colors.blue],
        backgroundColor: Colors.white,
        strokeWidth: 2.0,
        pathBackgroundColor: Colors.grey,
        pause: false,
      );

      final data2 = DecorateData(
        indicator: Indicator.ballPulse,
        colors: const [Colors.blue],
        backgroundColor: Colors.white,
        strokeWidth: 2.0,
        pathBackgroundColor: Colors.grey,
        pause: false,
      );

      final data3 = DecorateData(
        indicator: Indicator.ballPulse,
        colors: const [Colors.red], // Different color
        backgroundColor: Colors.white,
        strokeWidth: 2.0,
        pathBackgroundColor: Colors.grey,
        pause: false,
      );

      expect(data1, equals(data2));
      expect(data1.hashCode, equals(data2.hashCode));
      expect(data1, isNot(equals(data3)));
      expect(data1.hashCode, isNot(equals(data3.hashCode)));
    });

    test('toString returns meaningful string', () {
      final data = DecorateData(
        indicator: Indicator.ballPulse,
        colors: const [Colors.blue],
        pause: false,
      );

      final str = data.toString();
      expect(str, contains('DecorateData'));
      expect(str, contains('indicator: Indicator.ballPulse'));
      expect(str, contains('colors: ['));
      expect(str, contains('MaterialColor')); // Verify it's a MaterialColor
      expect(str, contains('blue: 0.9529')); // Verify it's blue
      expect(str, contains('pause: false'));
    });
  });

  group('DecorateContext', () {
    testWidgets('provides DecorateData to descendants', (tester) async {
      final data = DecorateData(
        indicator: Indicator.ballPulse,
        colors: const [Colors.blue],
        pause: false,
      );

      late DecorateContext? foundContext;
      await tester.pumpWidget(
        DecorateContext(
          decorateData: data,
          child: Builder(
            builder: (context) {
              foundContext = DecorateContext.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(foundContext, isNotNull);
      expect(foundContext!.decorateData, equals(data));
    });

    testWidgets('returns null when no DecorateContext is found',
        (tester) async {
      late DecorateContext? foundContext;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            foundContext = DecorateContext.of(context);
            return const SizedBox();
          },
        ),
      );

      expect(foundContext, isNull);
    });

    testWidgets('updates when DecorateData changes', (tester) async {
      final data1 = DecorateData(
        indicator: Indicator.ballPulse,
        colors: const [Colors.blue],
        pause: false,
      );

      final data2 = DecorateData(
        indicator: Indicator.ballPulse,
        colors: const [Colors.red],
        pause: true,
      );

      late DecorateContext? foundContext;
      Widget buildWidget(DecorateData data) {
        return DecorateContext(
          decorateData: data,
          child: Builder(
            builder: (context) {
              foundContext = DecorateContext.of(context);
              return const SizedBox();
            },
          ),
        );
      }

      await tester.pumpWidget(buildWidget(data1));
      expect(foundContext!.decorateData, equals(data1));

      await tester.pumpWidget(buildWidget(data2));
      expect(foundContext!.decorateData, equals(data2));
    });
  });
}

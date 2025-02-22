import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';

/// A loading indicator that displays a spinning circular stroke.
///
/// This widget is a wrapper around Flutter's built-in [CircularProgressIndicator]
/// that adapts its appearance to match the loading indicator theme. It displays
/// a circular stroke that spins continuously, creating a simple but effective
/// loading animation.
///
/// The widget uses the color and stroke width from the [DecorateContext] to
/// maintain consistency with other loading indicators. It also supports an
/// optional background color for the path.
///
/// Unlike other custom loading indicators, this widget leverages Flutter's
/// built-in circular progress animation for optimal performance and native feel.
class CircleStrokeSpin extends StatelessWidget {
  /// Creates a CircleStrokeSpin loading indicator.
  const CircleStrokeSpin({super.key});

  @override
  Widget build(BuildContext context) {
    final color = DecorateContext.of(context)!.decorateData.colors.first;
    return CircularProgressIndicator(
      strokeWidth: DecorateContext.of(context)!.decorateData.strokeWidth,
      color: color,
      backgroundColor:
          DecorateContext.of(context)!.decorateData.pathBackgroundColor,
    );
  }
}

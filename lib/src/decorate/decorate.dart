import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';

/// The default stroke width used when none is specified.
const double _kDefaultStrokeWidth = 2;

/// A data class that holds the configuration for a loading indicator animation.
///
/// This class encapsulates all the customizable aspects of a loading indicator,
/// including colors, stroke width, and animation state. It ensures that at least
/// one color is provided for the animation.
///
/// Example:
/// ```dart
/// DecorateData(
///   indicator: Indicator.ballPulse,
///   colors: [Colors.blue],
///   strokeWidth: 2.0,
///   pause: false,
/// )
/// ```
@immutable
final class DecorateData {
  /// The background color of the loading indicator container.
  /// If null, the container will be transparent.
  final Color? backgroundColor;

  /// The type of loading indicator animation to display.
  final Indicator indicator;

  /// The list of colors to use in the animation.
  /// The animation will cycle through these colors if multiple are provided.
  /// Must contain at least one color.
  final List<Color> colors;

  /// The stroke width for shapes that use strokes (e.g., rings, lines).
  /// If null, defaults to [_kDefaultStrokeWidth].
  final double? _strokeWidth;

  /// The background color for shapes that have cut edges.
  /// This is used to create contrast between the shape and its background
  /// in certain indicators.
  final Color? pathBackgroundColor;

  /// Controls whether the animation is paused.
  /// When true, the animation will be paused in its current state.
  /// When false, the animation will play normally.
  final bool pause;

  /// Creates a new [DecorateData] instance.
  ///
  /// The [indicator] and [colors] parameters are required, and [colors] must not be empty.
  /// Other parameters are optional and will use their default values if not specified.
  const DecorateData({
    required this.indicator,
    required this.colors,
    this.backgroundColor,
    double? strokeWidth,
    this.pathBackgroundColor,
    required this.pause,
  }) : _strokeWidth = strokeWidth,
       assert(colors.length > 0, 'At least one color must be provided');

  /// Gets the stroke width to use for the animation.
  /// Returns the specified stroke width or [_kDefaultStrokeWidth] if none was specified.
  double get strokeWidth => _strokeWidth ?? _kDefaultStrokeWidth;

  /// Helper function for deep equality comparison of collections.
  bool Function(Object? e1, Object? e2) get _deepEq =>
      const DeepCollectionEquality().equals;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecorateData &&
          runtimeType == other.runtimeType &&
          backgroundColor == other.backgroundColor &&
          indicator == other.indicator &&
          _deepEq(colors, other.colors) &&
          _strokeWidth == other._strokeWidth &&
          pathBackgroundColor == other.pathBackgroundColor &&
          pause == other.pause;

  @override
  int get hashCode =>
      backgroundColor.hashCode ^
      indicator.hashCode ^
      colors.hashCode ^
      _strokeWidth.hashCode ^
      pathBackgroundColor.hashCode ^
      pause.hashCode;

  @override
  String toString() {
    return 'DecorateData{backgroundColor: $backgroundColor, indicator: $indicator, colors: $colors, strokeWidth: $_strokeWidth, pathBackgroundColor: $pathBackgroundColor, pause: $pause}';
  }
}

/// An [InheritedWidget] that provides [DecorateData] to its descendants.
///
/// This widget establishes a subtree in which loading indicator widgets can
/// access shared decoration data. It's typically used internally by the
/// [LoadingIndicator] widget to provide configuration to its child widgets.
///
/// Example:
/// ```dart
/// DecorateContext(
///   decorateData: DecorateData(...),
///   child: YourWidget(),
/// )
/// ```
final class DecorateContext extends InheritedWidget {
  /// The decoration data to be provided to descendants.
  final DecorateData decorateData;

  /// Creates a new [DecorateContext] instance.
  ///
  /// Both [decorateData] and [child] parameters are required.
  const DecorateContext({
    super.key,
    required this.decorateData,
    required super.child,
  });

  @override
  bool updateShouldNotify(DecorateContext oldWidget) =>
      oldWidget.decorateData != decorateData;

  /// Finds the nearest [DecorateContext] ancestor and returns its data.
  ///
  /// Returns null if no [DecorateContext] ancestor is found.
  /// This method will cause the calling widget to rebuild when the data changes.
  static DecorateContext? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType();
  }
}

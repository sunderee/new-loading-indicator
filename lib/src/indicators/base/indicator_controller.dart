import 'package:flutter/material.dart';
import 'package:new_loading_indicator/src/decorate/decorate.dart';

/// A mixin that provides animation control functionality for loading indicators.
///
/// This mixin is designed to be used with [State] objects of loading indicator widgets.
/// It manages the lifecycle of animations, including pausing, resuming, and disposing
/// of animation controllers. It also handles state restoration when a widget is
/// reactivated.
///
/// Example usage:
/// ```dart
/// class MyIndicatorState extends State<MyIndicator> with IndicatorController {
///   late final controller = AnimationController(vsync: this);
///
///   @override
///   List<AnimationController> get animationControllers => [controller];
///
///   // ... rest of the implementation
/// }
/// ```
mixin IndicatorController<T extends StatefulWidget> on State<T> {
  /// Tracks whether the animations are currently paused.
  /// This is updated based on the [DecorateData.pause] value from the context.
  bool isPaused = false;

  /// The list of animation controllers managed by this mixin.
  ///
  /// Implementing classes must provide their animation controllers through this
  /// getter. These controllers will be automatically managed (started, stopped,
  /// disposed) based on the widget's lifecycle and pause state.
  List<AnimationController> get animationControllers;

  @override
  void activate() {
    super.activate();
    _initAnimState();
  }

  /// Initializes the animation state when the widget is activated.
  ///
  /// This method reads the [DecorateData.pause] value from the context and
  /// updates the [isPaused] state accordingly.
  void _initAnimState() {
    final DecorateData decorateData = DecorateContext.of(context)!.decorateData;
    isPaused = decorateData.pause;
  }

  @override
  void didChangeDependencies() {
    final DecorateData decorateData = DecorateContext.of(context)!.decorateData;
    if (decorateData.pause != isPaused) {
      isPaused = decorateData.pause;
      if (decorateData.pause) {
        // Stop all animations while preserving their current state
        for (var element in animationControllers) {
          element.stop(canceled: false);
        }
      } else {
        // Resume all animations
        for (var element in animationControllers) {
          element.repeat();
        }
      }
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // Clean up animation controllers when the widget is disposed
    for (var element in animationControllers) {
      element.dispose();
    }
    super.dispose();
  }
}

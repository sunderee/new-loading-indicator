# New Loading Indicator

A modernized Flutter package providing a rich collection of loading animations, forked from [loading_indicator](https://github.com/TinoGuo/loading_indicator).

## Overview

This package offers 34 different loading animations for Flutter applications.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  new_loading_indicator: latest
```

## Usage

```dart
import 'package:new_loading_indicator/new_loading_indicator.dart';

// Basic usage
LoadingIndicator(
  indicatorType: Indicator.ballPulse, // Choose from 34 different indicators
);

// Customized usage
LoadingIndicator(
  indicatorType: Indicator.ballPulse,
  colors: const [Colors.white],        // Custom colors
  strokeWidth: 2.0,                    // Custom stroke width
  backgroundColor: Colors.black,       // Custom background color
  pathBackgroundColor: Colors.white,   // Custom path background color
  pause: false,                        // Pause/resume animation
);
```

## Customization

Each indicator can be customized with:
- Multiple colors (will cycle through the list)
- Background color
- Stroke width (for indicators that use strokes)
- Path background color (for indicators with cut edges)
- Animation pause/resume control

## Attribution

This package is a modernized fork of [loading_indicator](https://github.com/TinoGuo/loading_indicator) by TinoGuo, which was originally inspired by [loaders.css](https://connoratherton.com/loaders). The original work remains copyrighted by its respective owners and is licensed under the Apache License 2.0.

## Improvements Over Original

- Updated for modern Flutter/Dart SDK versions
- Enhanced documentation and examples
- Comprehensive test coverage
- Active maintenance and bug fixes
- Modern Dart patterns and best practices
- Improved type safety and null safety

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
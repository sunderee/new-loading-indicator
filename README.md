# new_loading_indicator

A fork of the [`loading_indicator`](https://pub.dev/packages/loading_indicator) package, providing a rich collection of loading animations for Flutter applications. The original package is unmaintained, has outdated dependencies, poor documentation, and was written without a single test. This fork aims to:

- Modernize the codebase for compatibility with the latest Flutter/Dart SDK versions
- Update outdated dependencies
- Add comprehensive test coverage
- Provide detailed documentation for maintainability
- Ensure ongoing maintenance and active development

Visit the [example on GitLab Pages](https://new-loading-indicator-c6eb32.gitlab.io) for a live demo.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  new_loading_indicator: ^latest_version
```

## Usage

```dart
import 'package:new_loading_indicator/new_loading_indicator.dart';

// Basic usage
LoadingIndicator(
  indicatorType: Indicator.ballPulse, // Choose your animation
  colors: const [Colors.white],        // Customize colors
  strokeWidth: 2,                      // Customize the stroke width
  backgroundColor: Colors.black,       // Optional background color
);

// With custom size
SizedBox(
  width: 100,
  height: 100,
  child: LoadingIndicator(
    indicatorType: Indicator.ballSpinFadeLoader,
    colors: const [Colors.white],
  ),
);
```

## Available Indicators

The package includes a variety of loading indicators, each customizable to match your app's design:

- Ball Pulse
- Ball Grid Pulse
- Ball Clip Rotate
- Ball Clip Rotate Pulse
- Square Spin
- Ball Clip Rotate Multiple
- Ball Pulse Rise
- Ball Rotate
- Cube Transition
- Ball Zig Zag
- Ball Zig Zag Deflect
- Ball Triangle Path
- Ball Scale
- Line Scale
- Line Scale Party
- Ball Scale Multiple
- Ball Pulse Sync
- Ball Beat
- Line Scale Pulse Out
- Line Scale Pulse Out Rapid
- Ball Scale Ripple
- Ball Scale Ripple Multiple
- Ball Spin Fade Loader
- Line Spin Fade Loader
- Triangle Spin Fade Loader
- Pacman
- Ball Grid Beat
- Semi Circle Spin

## Test Coverage Report

```
$ flutter test --coverage && lcov --summary coverage/lcov.info 
00:13 +169: All tests passed!                                                                                                                                      
Reading tracefile coverage/lcov.info.
Summary coverage rate:
  source files: 38
  lines.......: 97.3% (1462 of 1503 lines)
  functions...: no data found
Message summary:
  no messages were reported
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the [Apache License 2.0](./LICENSE). The original work is copyrighted by its respective owners and continues to be licensed under the Apache License 2.0. Refer to the [NOTICE](./NOTICE) file for more details.
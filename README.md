# button_group

![GitHub stars](https://img.shields.io/github/stars/EmilyMonestone/button_group) ![GitHub license](https://img.shields.io/github/license/EmilyMonestone/button_group) [![pub package](https://img.shields.io/pub/v/button_group.svg)](https://pub.dev/packages/button_group)

## Overview

`button_group` is a Flutter package that helps you lay out multiple related Material buttons as a cohesive group. It follows the Material 3 Expressive pattern and supports connected and standard styles, overflow handling, optional split buttons (with attached menus), and multi‑row wrapping. The widget is purely structural — it does not impose selection logic; each child button keeps its own onPressed behavior.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Setup and Running Locally (example app)](#setup-and-running-locally-example-app)
- [Usage](#usage)
- [Scripts and Commands](#scripts-and-commands)
- [Environment Variables](#environment-variables)
- [Tests](#tests)
- [Project Structure](#project-structure)
- [License](#license)
- [Author](#author)

## Features

- Material 3 inspired button groups
  - ButtonGroupType.connected and ButtonGroupType.standard
  - GroupShape.round or GroupShape.square
  - Size ramp via GroupSize: xs, s, m (default), l, xl
- Smart overflow handling via OverflowStrategy
  - menu (default), wrap
- Optional multi‑row layout with maxLines and rowSpacing
- Customizable padding per row (runPadding)
- Optional custom overflow “More” button (moreBuilder)
- Optional theming via ButtonGroupThemeData and MenuThemeData
- SplitButton support with attached menu entries (MenuEntry)

## Requirements

- Dart SDK: ^3.9.2
- Flutter SDK: >=1.17.0
- Platforms: Flutter mobile, web, and desktop are supported by the example app; the widget itself is platform‑agnostic.

## Installation

Add the dependency to your app’s pubspec.yaml:

```yaml
dependencies:
  flutter:
    sdk: flutter
  button_group: ^0.1.0
```

Then fetch packages:

- flutter pub get

## Setup and Running Locally (example app)

This repository includes an example app showcasing the widget.

- Clone the repo
- Open the project in your IDE or a terminal
- Commands:
  - cd example
  - flutter pub get
  - flutter run

To run on a specific device:

- flutter run -d chrome
- flutter run -d windows
- flutter run -d ios
- flutter run -d android

## Usage

Import the package and use ButtonGroup in your widget tree. Minimal example:

```dart
import 'package:flutter/material.dart';
import 'package:button_group/button_group.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ButtonGroup(
      type: ButtonGroupType.connected,
      size: GroupSize.m,
      shape: GroupShape.round,
      overflowStrategy: OverflowStrategy.menu,
      children: [
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Create'),
        ),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.edit),
          label: const Text('Edit'),
        ),
        SplitButton(
          primaryChild: FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.file_upload),
            label: const Text('Export'),
          ),
          menuEntries: [
            MenuEntry('CSV', onSelected: () {}),
            MenuEntry('XLSX', onSelected: () {}),
            MenuEntry('PDF', onSelected: () {}),
          ],
          onPrimaryPressed: () {},
        ),
      ],
    );
  }
}
```

For a complete runnable demo, see example/lib/main.dart.

Core parameters (with defaults):

- children (required): List<Widget> of Material buttons (e.g., FilledButton, OutlinedButton, IconButton, SplitButton)
- type: ButtonGroupType = ButtonGroupType.connected
- size: GroupSize = GroupSize.m
- shape: GroupShape = GroupShape.round
- overflowStrategy: OverflowStrategy = OverflowStrategy.menu
- maxLines: int? = null (no limit)
- rowSpacing: double = 8.0
- runPadding: EdgeInsets = EdgeInsets.symmetric(vertical: 4, horizontal: 6)
- moreBuilder: Widget Function(BuildContext context)? = null
- groupTheme: ButtonGroupThemeData? = null
- menuTheme: MenuThemeData? = null

### Global density for button groups

You can set a global density for all ButtonGroup children using the Theme extension `ButtonGroupThemeData.visualDensity`. This wraps the group contents in a Theme that overrides `ThemeData.visualDensity`, allowing inner Material buttons to automatically adapt their padding and tap target size.

Set it globally:

```
MaterialApp(
  theme: ThemeData(
    extensions: const <ThemeExtension<dynamic>>[
      ButtonGroupThemeData(
        visualDensity: VisualDensity.compact, // or VisualDensity.standard, comfortable, etc.
      ),
    ],
  ),
  home: const MyHomePage(),
)
```

Or override per group via `groupTheme`:

```
ButtonGroup(
  groupTheme: const ButtonGroupThemeData(
    visualDensity: VisualDensity.standard,
  ),
  children: [ /* ... */ ],
)
```

See the source for enum options:

- [ButtonGroupType](lib/src/group/button_group_type.dart): connected, standard
- [GroupSize](lib/src/group/group_size.dart): xs, s, m, l, xl
- [GroupShape](lib/src/group/group_shape.dart): round, square
- [OverflowStrategy](lib/src/group/overflow_strategy.dart): menu, wrap

## Scripts and Commands

Common development commands for this repo:

- Get dependencies: flutter pub get (run in root and in example)
- Format code: dart format .
- Apply quick fixes: dart fix --apply
- Analyze: flutter analyze
- Run tests: flutter test
- Run the example app: cd example && flutter run

## Environment Variables

- None required for this package.
- TODO: Document any environment variables if future features require configuration.

## Tests

- Unit/widget tests live under test/ (e.g., test/connected_button_group_test.dart)
- Run all tests:
  - flutter test

## Project Structure

- [lib/](lib/)
  - [lib/button_group.dart](lib/button_group.dart) — package entry point exporting public API
  - src/
    - group/ — core ButtonGroup widget and related types (size/shape/overflow/split button)
    - menu/ — MenuEntry model used by SplitButton/overflow menus
    - theme/ — ButtonGroupThemeData and theming helpers
- [example/](example/) — runnable demo app
  - [example/lib/main.dart](example/lib/main.dart) — demo showcasing connected layout, split button, overflow menu
- [test/](test/) — tests
- [pubspec.yaml](pubspec.yaml) — package metadata and dependencies
- [CHANGELOG.md](CHANGELOG.md) — version history
- [LICENSE](LICENSE) — MIT License

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

## Author

Created by Emily Pauli (BruckCode / EmilyMonestone).
This package is part of a Flutter component library inspired by Material 3 Expressive patterns. Contributions, bug reports, and feature requests are welcome!


---

## Additional Usage Examples

### Standard group (non-connected)

```dart
import 'package:flutter/material.dart';
import 'package:button_group/button_group.dart';

Widget standardGroup() {
  return ButtonGroup(
    type: ButtonGroupType.standard,
    children: [
      OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.share),
        label: const Text('Share'),
      ),
      TextButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.delete),
        label: const Text('Delete'),
      ),
    ],
  );
}
```

### Wrapping overflow across multiple rows

```dart
import 'package:flutter/material.dart';
import 'package:button_group/button_group.dart';

Widget wrappingGroup() {
  return ButtonGroup(
    overflowStrategy: OverflowStrategy.wrap,
    maxLines: 2,
    rowSpacing: 6,
    runPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    children: [
      FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('New')),
      FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.edit), label: const Text('Edit')),
      FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.copy), label: const Text('Duplicate')),
      FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.download), label: const Text('Download')),
      FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.delete), label: const Text('Delete')),
    ],
  );
}
```

If you prefer a compact single-row layout that overflows into a popup menu, keep the default `OverflowStrategy.menu`.

## Contributing

Contributions are welcome! If you find a bug or have a feature request:

- Open an issue: https://github.com/EmilyMonestone/button_group/issues
- Submit a pull request. Before submitting:
  - Run: `flutter pub get` (root and example)
  - Format: `dart format .`
  - Lints: `flutter analyze`
  - Tests: `flutter test`

## Helpful Links

- Pub package: https://pub.dev/packages/button_group
- Changelog: [CHANGELOG.md](CHANGELOG.md)
- Example app source: [example/lib/main.dart](example/lib/main.dart)

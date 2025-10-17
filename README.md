![GitHub stars](https://img.shields.io/github/stars/BruckCode/connected_button_group) ![GitHub license](https://img.shields.io/github/license/BruckCode/connected_button_group) [![pub package](https://img.shields.io/pub/v/connected_button_group.svg)](https://pub.dev/packages/connected_button_group)

`connected_button_group` is a Flutter widget that arranges multiple related
controls into a single continuous pill‑shaped container, following the
Material 3 Expressive design pattern.  The widget supports
single‑selection and action‑only modes, split‑buttons, attached menus
and automatic overflow handling.

## 📚 Table of Contents

- [🚀 Features](#-features)
- [🏁 Getting Started](#-getting-started)
- [🔧 Usage](#-usage)
- [🎯 Examples](#-examples)
- [⚙️ Parameters](#-parameters)
- [👤 Author](#-author)

## 🚀 Features

* **Unified control:** Arrange a series of buttons into one pill
  container with coordinated interactions.
* **Flexible content:** Each segment can display text, an icon, or an
  icon+label combination.
* **Selection and actions:** Use a `value` and `onChanged` callback to
  enable single selection or omit them to treat the group as a toolbar
  where each segment invokes `onPressed`.
* **Menus & split‑buttons:** Attach a menu to any item; if a
  `ConnectedButtonItem` supplies both a menu and a primary action, it
  renders as a split‑button with distinct tap targets.
* **Automatic overflow:** When items exceed the available width, the
  trailing buttons collapse into a **“More”** menu.  If still too wide
  the group wraps to additional rows.
* **Customisable layout:** Configure overflow strategy, maximum rows,
  row spacing and internal padding.  You can also supply a custom
  overflow handle.
* **Theming support:** Override colours and styles via a
  `ConnectedButtonGroupThemeData` or globally through a
  `ThemeExtension`.

## 🏁 Getting Started

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  connected_button_group: ^0.0.1
```

Then install with `flutter pub get`.  To see the widget in action,
clone this repository and run the example:

```sh
cd example
flutter run
```

## 🔧 Usage

Import the package and create a `ConnectedButtonGroup` with a list of
`ConnectedButtonItem`s.  Provide a `value` and `onChanged` callback to
enable single selection.  Omit `value` and `onChanged` to use the
group in action‑only mode where each item triggers `onPressed`.

```dart
import 'package:flutter/material.dart';
import 'package:connected_button_group/connected_button_group.dart';

enum ViewMode { list, grid, map, settings }

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});
  @override
  State<ExampleWidget> createState() => _ExampleWidgetState();
}

class _ExampleWidgetState extends State<ExampleWidget> {
  ViewMode _mode = ViewMode.list;

  @override
  Widget build(BuildContext context) {
    return ConnectedButtonGroup<ViewMode>(
      items: [
        ConnectedButtonItem(
          value: ViewMode.list,
          icon: Icons.view_list,
          label: 'List',
        ),
        ConnectedButtonItem(
          value: ViewMode.grid,
          icon: Icons.grid_view,
          label: 'Grid',
        ),
        // Split‑button: default action + menu
        ConnectedButtonItem(
          value: ViewMode.map,
          icon: Icons.map,
          label: 'Map',
          isSplit: true,
          onPrimaryPressed: () {
            // perform default map action
          },
          menu: [
            ConnectedMenuEntry(label: 'Default', value: ViewMode.map),
            ConnectedMenuEntry(label: 'Satellite', value: ViewMode.map),
            ConnectedMenuEntry(label: 'Terrain', value: ViewMode.map),
          ],
        ),
        // Overflow / menu item
        ConnectedButtonItem(
          value: ViewMode.settings,
          icon: Icons.settings,
          label: 'Settings',
          menu: [
            ConnectedMenuEntry(label: 'Profile', value: ViewMode.settings),
            ConnectedMenuEntry(label: 'Logout', value: ViewMode.settings, destructive: true),
          ],
        ),
      ],
      value: _mode,
      onChanged: (mode) => setState(() => _mode = mode),
      onMenuItemSelected: (pair) {
        // Called when a menu entry is selected.
        debugPrint('Selected ${pair.$2.label} from ${pair.$1}');
      },
    );
  }
}
```

## 🎯 Examples

You can find a full example in the `example` directory.  Run it with

```sh
flutter run -d chrome
```

The demo shows a connected group with a split‑button and an overflow
menu.  Resize the window to watch items collapse into the **More** menu
and wrap to new lines.

## ⚙️ Parameters

### `ConnectedButtonGroup`

| Parameter | Type | Description |
|---|---|---|
| `items` | `List<ConnectedButtonItem<T>>` | The list of items to display in order. Each item becomes a segment. |
| `value` | `T?` | The currently selected value. When non‑null, the corresponding segment is highlighted. Omit for action‑only mode. |
| `onChanged` | `ValueChanged<T>?` | Called when selection changes. Receives the new value. Ignored if `value` is null. |
| `onPressed` | `ValueChanged<T>?` | Called when an item is tapped in action‑only mode (i.e. when `value` and `onChanged` are omitted). |
| `onMenuItemSelected` | `void Function((T itemValue, ConnectedMenuEntry<T> entry))?` | Called when a menu entry is selected. Receives the parent item value and the selected entry. |
| `overflowStrategy` | `ConnectedOverflowStrategy` | Determines how items that exceed the available width are handled. The default (`menuThenWrap`) collapses trailing items into a menu and then wraps as needed. |
| `maxLines` | `int?` | Maximum number of rows to allow when wrapping. `null` means unlimited. |
| `rowSpacing` | `double` | Spacing between wrapped rows. |
| `runPadding` | `EdgeInsets` | Padding applied inside each row container. |
| `overflowItem` | `ConnectedButtonItem<T>?` | Optional custom item used as the overflow handle. Its `menu` is ignored and will be populated automatically. |
| `theme` | `ConnectedButtonGroupThemeData?` | Overrides colours and styles for this instance. |

### `ConnectedButtonItem`

| Parameter | Type | Description |
|---|---|---|
| `value` | `T` | The semantic value of the item. |
| `label` | `String?` | Text displayed on the button. Optional. |
| `icon` | `IconData?` | Leading icon for the button. Optional. |
| `tooltip` | `String?` | Tooltip shown on long press or hover. Optional. |
| `enabled` | `bool` | Whether the button is enabled. Defaults to `true`. |
| `menu` | `List<ConnectedMenuEntry<T>>?` | Menu entries attached to this item. If non‑null the item can open a menu. |
| `isSplit` | `bool` | If `true` and `menu` is non‑null, renders as a split‑button with separate primary and chevron areas. |
| `onPrimaryPressed` | `VoidCallback?` | Callback for the primary area of a split‑button. Ignored if `isSplit` is false. |
| `menuAlignment` | `ConnectedMenuAlignment` | Where to align the menu (start/end/auto). |
| `openMenuOnLongPress` | `bool` | Whether a long press on the primary area should also open the menu. |

### `ConnectedMenuEntry`

| Parameter | Type | Description |
|---|---|---|
| `label` | `String` | Text displayed in the menu. |
| `icon` | `IconData?` | Leading icon for the menu entry. |
| `value` | `T?` | Semantic value associated with this entry. |
| `enabled` | `bool` | Whether the entry is enabled. Defaults to `true`. |
| `destructive` | `bool` | Whether the entry is destructive. Destructive entries should be styled using an error colour. |
| `checked` | `bool?` | Whether the entry is checkable. `null` means not checkable. |
| `onSelected` | `VoidCallback?` | Callback invoked when the entry is selected. |
| `submenu` | `List<ConnectedMenuEntry<T>>?` | Submenu entries. Submenus are flattened in the current implementation. |

## 👤 Author
Created by Emily Pauli [BruckCode].
This package was created as part of a Flutter component library.  It was inspired by Material 3 Expressive patterns and designed to be easy to adopt in your own projects.  Contributions, bug reports and feature requests are welcome!

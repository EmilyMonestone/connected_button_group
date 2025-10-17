import 'package:flutter/material.dart';

/// A menu entry used by [ConnectedButtonItem] menus.
///
/// Instances of this class describe menu items that may be displayed in
/// overflow menus or split-button menus.  Items can be checkable,
/// destructive, disabled or contain submenus.  When tapped the
/// [onSelected] callback is invoked.
class ConnectedMenuEntry<T> {
  /// Creates a menu entry.
  const ConnectedMenuEntry({
    required this.label,
    this.icon,
    this.value,
    this.enabled = true,
    this.destructive = false,
    this.checked,
    this.onSelected,
    this.submenu,
  });

  /// The text displayed for this entry.  This should be short and
  /// descriptive.
  final String label;

  /// Optional leading icon for the entry.
  final IconData? icon;

  /// A semantic value associated with this entry.  This is passed back to
  /// callbacks when the entry is selected.  It may be null when the
  /// entry simply triggers an action and does not map to a group value.
  final T? value;

  /// Whether the entry is enabled.  Disabled entries are rendered with
  /// reduced opacity and cannot be selected.
  final bool enabled;

  /// Whether the entry is destructive.  Destructive entries should be
  /// styled using an error colour to indicate caution.
  final bool destructive;

  /// Whether the entry is checkable.  Null means the entry is not
  /// checkable; otherwise true or false indicates whether the entry
  /// appears checked.  Checkable entries are rendered with a leading
  /// checkmark and use the [CheckedPopupMenuItem] widget.
  final bool? checked;

  /// Callback invoked when the entry is selected.  This is triggered
  /// before any selection logic in [ConnectedButtonGroup.onMenuItemSelected].
  final VoidCallback? onSelected;

  /// A list of submenu entries.  Flutter's built-in [PopupMenuButton]
  /// does not support nested menus, therefore submenus will simply be
  /// flattened and appended beneath the current entry when rendered.  If
  /// non-null and non-empty, submenus are appended with a divider.
  final List<ConnectedMenuEntry<T>>? submenu;
}
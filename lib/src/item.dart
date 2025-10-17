import 'package:flutter/material.dart';

import 'menu_entry.dart';

/// Where to align the menu relative to the triggering button.
///
/// When a [ConnectedButtonItem] contains a menu (either as a split-button
/// chevron or as a normal button that opens a menu), this enum controls
/// whether the menu is anchored to the start, end or automatically chosen
/// based on the ambient [Directionality].
enum ConnectedMenuAlignment {
  /// Align the menu to the start of the button (left in LTR, right in RTL).
  start,

  /// Align the menu to the end of the button (right in LTR, left in RTL).
  end,

  /// Automatically choose an appropriate alignment based on the ambient
  /// [Directionality].  In most cases the menu opens on the same side as
  /// a trailing icon.
  auto,
}

/// Data class describing an individual item in a [ConnectedButtonGroup].
///
/// Each instance defines the content and behaviour of a segment within
/// the connected button group.  Labels and icons are optional.  An item
/// may also define a menu by supplying [menu], in which case the item
/// may render as a split-button if [isSplit] is true or open a menu when
/// the entire button is tapped if [isSplit] is false.
class ConnectedButtonItem<T> {
  /// Creates a connected button item.
  const ConnectedButtonItem({
    required this.value,
    this.label,
    this.icon,
    this.tooltip,
    this.enabled = true,
    this.menu,
    this.isSplit = false,
    this.onPrimaryPressed,
    this.menuAlignment = ConnectedMenuAlignment.auto,
    this.openMenuOnLongPress = false,
  });

  /// The semantic value of this item.  When selection is enabled, the
  /// group's [ConnectedButtonGroup.onChanged] will be invoked with this
  /// value when the item is tapped.
  final T value;

  /// Optional text displayed on the button.  When null the button may
  /// render as an icon-only control.
  final String? label;

  /// Optional icon displayed before [label].  If [label] is null the icon
  /// becomes the primary visual.  Icons default to a size of 24 dp.
  final IconData? icon;

  /// An optional tooltip shown on long press or when the control is
  /// hovered.  Tooltips are particularly important for icon-only items.
  final String? tooltip;

  /// Whether the button is enabled.  Disabled buttons do not react to
  /// pointer or keyboard input and are rendered with reduced opacity.
  final bool enabled;

  /// A list of menu entries.  If non-null the item can open a menu.
  /// When [isSplit] is true the menu is opened from a chevron area; when
  /// false the menu is opened when the entire button is tapped (no primary
  /// action).  An empty list is treated as null.
  final List<ConnectedMenuEntry<T>>? menu;

  /// Whether to render this item as a split-button.  Split-buttons
  /// comprise two hit targets: a primary area that invokes
  /// [onPrimaryPressed] or selection, and a chevron area that opens
  /// [menu].  If false the entire button opens the menu when tapped.
  final bool isSplit;

  /// An optional callback invoked when the primary portion of a split
  /// button is pressed.  Ignored if [isSplit] is false.  If this is
  /// provided it will be invoked before any selection is performed.
  final VoidCallback? onPrimaryPressed;

  /// Determines where to align the attached [menu] relative to the button.
  final ConnectedMenuAlignment menuAlignment;

  /// Whether a long press on the primary area should also open the
  /// attached menu.  Defaults to false, meaning long press behaviour is
  /// delegated to tooltips when [tooltip] is non-null.
  final bool openMenuOnLongPress;
}
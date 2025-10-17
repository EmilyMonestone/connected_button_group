import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Theme data for [ConnectedButtonGroup].
///
/// This class defines colour and stylistic overrides for the connected
/// button group.  It can be provided to the group via the [theme]
/// property or globally using [ThemeExtension] on [ThemeData].  When
/// omitted, reasonable defaults are chosen from the ambient
/// [ColorScheme].
@immutable
class ConnectedButtonGroupThemeData
    extends ThemeExtension<ConnectedButtonGroupThemeData> {
  /// Creates a theme for a connected button group.
  const ConnectedButtonGroupThemeData({
    this.containerColor,
    this.selectedContainerColor,
    this.selectedContentColor,
    this.unselectedContentColor,
    this.disabledContentColor,
    this.dividerColor,
    this.focusOutlineColor,
  });

  /// The background colour of the group container.  This applies behind
  /// all items.  Defaults to [ColorScheme.surfaceVariant].
  final Color? containerColor;

  /// The background colour of a selected item.  Defaults to
  /// [ColorScheme.primaryContainer].
  final Color? selectedContainerColor;

  /// The colour of text and icons for a selected item.  Defaults to
  /// [ColorScheme.onPrimaryContainer].
  final Color? selectedContentColor;

  /// The colour of text and icons for an unselected item.  Defaults to
  /// [ColorScheme.onSurfaceVariant].
  final Color? unselectedContentColor;

  /// The colour of text and icons for a disabled item.  Defaults to
  /// [ColorScheme.onSurfaceVariant] with an opacity of 0.38.
  final Color? disabledContentColor;

  /// The colour used for divider lines between items.  Defaults to
  /// [ColorScheme.outlineVariant].
  final Color? dividerColor;

  /// The colour of the focus outline drawn around an item when it has
  /// keyboard focus.  Defaults to [ColorScheme.outline].
  final Color? focusOutlineColor;

  @override
  ConnectedButtonGroupThemeData copyWith({
    Color? containerColor,
    Color? selectedContainerColor,
    Color? selectedContentColor,
    Color? unselectedContentColor,
    Color? disabledContentColor,
    Color? dividerColor,
    Color? focusOutlineColor,
  }) {
    return ConnectedButtonGroupThemeData(
      containerColor: containerColor ?? this.containerColor,
      selectedContainerColor:
          selectedContainerColor ?? this.selectedContainerColor,
      selectedContentColor: selectedContentColor ?? this.selectedContentColor,
      unselectedContentColor:
          unselectedContentColor ?? this.unselectedContentColor,
      disabledContentColor:
          disabledContentColor ?? this.disabledContentColor,
      dividerColor: dividerColor ?? this.dividerColor,
      focusOutlineColor: focusOutlineColor ?? this.focusOutlineColor,
    );
  }

  @override
  ConnectedButtonGroupThemeData lerp(
      ThemeExtension<ConnectedButtonGroupThemeData>? other, double t) {
    if (other is! ConnectedButtonGroupThemeData) return this;
    return ConnectedButtonGroupThemeData(
      containerColor: Color.lerp(containerColor, other.containerColor, t),
      selectedContainerColor:
          Color.lerp(selectedContainerColor, other.selectedContainerColor, t),
      selectedContentColor:
          Color.lerp(selectedContentColor, other.selectedContentColor, t),
      unselectedContentColor:
          Color.lerp(unselectedContentColor, other.unselectedContentColor, t),
      disabledContentColor:
          Color.lerp(disabledContentColor, other.disabledContentColor, t),
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t),
      focusOutlineColor:
          Color.lerp(focusOutlineColor, other.focusOutlineColor, t),
    );
  }
}
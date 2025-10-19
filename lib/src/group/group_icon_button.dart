import 'package:flutter/material.dart';

import 'group_size.dart';

/// Width options for [GroupIconButton].
///
/// The width determines the horizontal extent of the icon button segment
/// while the height is derived from the surrounding [ButtonGroup]'s
/// [GroupSize].
enum GroupIconButtonWidth {
  /// 1:1 circle/rounded-square. Matches the height.
  defaultWidth,

  /// Narrower than tall.
  narrow,

  /// Wider than tall.
  wide,
}

/// Returns the target width for a given [GroupSize] and [GroupIconButtonWidth]
/// according to Material 3 specifications.
///
/// This is used by [ButtonGroup] when laying out a [GroupIconButton].
@protected
double groupIconButtonTargetWidth(GroupSize size, GroupIconButtonWidth width) {
  switch (size) {
    case GroupSize.xs:
      switch (width) {
        case GroupIconButtonWidth.defaultWidth:
          return 32;
        case GroupIconButtonWidth.narrow:
          return 28;
        case GroupIconButtonWidth.wide:
          return 40;
      }
    case GroupSize.s:
      switch (width) {
        case GroupIconButtonWidth.defaultWidth:
          return 40;
        case GroupIconButtonWidth.narrow:
          return 32;
        case GroupIconButtonWidth.wide:
          return 52;
      }
    case GroupSize.m:
      switch (width) {
        case GroupIconButtonWidth.defaultWidth:
          return 56;
        case GroupIconButtonWidth.narrow:
          return 48;
        case GroupIconButtonWidth.wide:
          return 72;
      }
    case GroupSize.l:
      switch (width) {
        case GroupIconButtonWidth.defaultWidth:
          return 96;
        case GroupIconButtonWidth.narrow:
          return 64;
        case GroupIconButtonWidth.wide:
          return 128;
      }
    case GroupSize.xl:
      switch (width) {
        case GroupIconButtonWidth.defaultWidth:
          return 136;
        case GroupIconButtonWidth.narrow:
          return 104;
        case GroupIconButtonWidth.wide:
          return 184;
      }
  }
}

/// A Material-3 style IconButton with width variants for use inside
/// [ButtonGroup].
///
/// This widget mirrors the API of Flutter's M3 [IconButton] constructors
/// (standard, filled, filledTonal, outlined) while adding a [width]
/// parameter. The actual width is applied by [ButtonGroup] during layout so
/// that it can match the group's [GroupSize]. When used outside of a
/// [ButtonGroup], the [width] parameter has no effect on layout.
class GroupIconButton extends StatelessWidget {
  const GroupIconButton({
    super.key,
    this.iconSize,
    this.visualDensity,
    this.padding,
    this.alignment,
    this.splashRadius,
    this.color,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.splashColor,
    this.disabledColor,
    required this.onPressed,
    this.onHover,
    this.onLongPress,
    this.mouseCursor,
    this.focusNode,
    this.autofocus = false,
    this.tooltip,
    this.enableFeedback,
    this.constraints,
    this.style,
    this.isSelected,
    this.selectedIcon,
    required this.icon,
    this.width = GroupIconButtonWidth.defaultWidth,
  }) : _variant = _Variant.standard;

  const GroupIconButton.filled({
    super.key,
    this.iconSize,
    this.visualDensity,
    this.padding,
    this.alignment,
    this.splashRadius,
    this.color,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.splashColor,
    this.disabledColor,
    required this.onPressed,
    this.onHover,
    this.onLongPress,
    this.mouseCursor,
    this.focusNode,
    this.autofocus = false,
    this.tooltip,
    this.enableFeedback,
    this.constraints,
    this.style,
    this.isSelected,
    this.selectedIcon,
    required this.icon,
    this.width = GroupIconButtonWidth.defaultWidth,
  }) : _variant = _Variant.filled;

  const GroupIconButton.filledTonal({
    super.key,
    this.iconSize,
    this.visualDensity,
    this.padding,
    this.alignment,
    this.splashRadius,
    this.color,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.splashColor,
    this.disabledColor,
    required this.onPressed,
    this.onHover,
    this.onLongPress,
    this.mouseCursor,
    this.focusNode,
    this.autofocus = false,
    this.tooltip,
    this.enableFeedback,
    this.constraints,
    this.style,
    this.isSelected,
    this.selectedIcon,
    required this.icon,
    this.width = GroupIconButtonWidth.defaultWidth,
  }) : _variant = _Variant.filledTonal;

  const GroupIconButton.outlined({
    super.key,
    this.iconSize,
    this.visualDensity,
    this.padding,
    this.alignment,
    this.splashRadius,
    this.color,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.splashColor,
    this.disabledColor,
    required this.onPressed,
    this.onHover,
    this.onLongPress,
    this.mouseCursor,
    this.focusNode,
    this.autofocus = false,
    this.tooltip,
    this.enableFeedback,
    this.constraints,
    this.style,
    this.isSelected,
    this.selectedIcon,
    required this.icon,
    this.width = GroupIconButtonWidth.defaultWidth,
  }) : _variant = _Variant.outlined;

  final _Variant _variant;

  // Mirror of IconButton parameters
  final double? iconSize;
  final VisualDensity? visualDensity;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
  final double? splashRadius;
  final Color? color;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? highlightColor;
  final Color? splashColor;
  final Color? disabledColor;
  final VoidCallback? onPressed;
  final ValueChanged<bool>? onHover;
  final VoidCallback? onLongPress;
  final MouseCursor? mouseCursor;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? tooltip;
  final bool? enableFeedback;
  final BoxConstraints? constraints;
  final ButtonStyle? style;
  final bool? isSelected;
  final Widget? selectedIcon;
  final Widget icon;

  /// Desired width behavior; applied by ButtonGroup.
  final GroupIconButtonWidth width;

  @override
  Widget build(BuildContext context) {
    // Build the underlying Material IconButton variant. The width is handled
    // by ButtonGroup; here we create the button normally.
    switch (_variant) {
      case _Variant.standard:
        return IconButton(
          iconSize: iconSize,
          visualDensity: visualDensity,
          padding: padding,
          alignment: alignment,
          splashRadius: splashRadius,
          color: color,
          focusColor: focusColor,
          hoverColor: hoverColor,
          highlightColor: highlightColor,
          splashColor: splashColor,
          disabledColor: disabledColor,
          onPressed: onPressed,
          onHover: onHover,
          onLongPress: onLongPress,
          mouseCursor: mouseCursor,
          focusNode: focusNode,
          autofocus: autofocus,
          tooltip: tooltip,
          enableFeedback: enableFeedback,
          constraints: constraints,
          style: style,
          isSelected: isSelected,
          selectedIcon: selectedIcon,
          icon: icon,
        );
      case _Variant.filled:
        return IconButton.filled(
          iconSize: iconSize,
          visualDensity: visualDensity,
          padding: padding,
          alignment: alignment,
          splashRadius: splashRadius,
          color: color,
          focusColor: focusColor,
          hoverColor: hoverColor,
          highlightColor: highlightColor,
          splashColor: splashColor,
          disabledColor: disabledColor,
          onPressed: onPressed,
          onHover: onHover,
          onLongPress: onLongPress,
          mouseCursor: mouseCursor,
          focusNode: focusNode,
          autofocus: autofocus,
          tooltip: tooltip,
          enableFeedback: enableFeedback,
          constraints: constraints,
          style: style,
          isSelected: isSelected,
          selectedIcon: selectedIcon,
          icon: icon,
        );
      case _Variant.filledTonal:
        return IconButton.filledTonal(
          iconSize: iconSize,
          visualDensity: visualDensity,
          padding: padding,
          alignment: alignment,
          splashRadius: splashRadius,
          color: color,
          focusColor: focusColor,
          hoverColor: hoverColor,
          highlightColor: highlightColor,
          splashColor: splashColor,
          disabledColor: disabledColor,
          onPressed: onPressed,
          onHover: onHover,
          onLongPress: onLongPress,
          mouseCursor: mouseCursor,
          focusNode: focusNode,
          autofocus: autofocus,
          tooltip: tooltip,
          enableFeedback: enableFeedback,
          constraints: constraints,
          style: style,
          isSelected: isSelected,
          selectedIcon: selectedIcon,
          icon: icon,
        );
      case _Variant.outlined:
        return IconButton.outlined(
          iconSize: iconSize,
          visualDensity: visualDensity,
          padding: padding,
          alignment: alignment,
          splashRadius: splashRadius,
          color: color,
          focusColor: focusColor,
          hoverColor: hoverColor,
          highlightColor: highlightColor,
          splashColor: splashColor,
          disabledColor: disabledColor,
          onPressed: onPressed,
          onHover: onHover,
          onLongPress: onLongPress,
          mouseCursor: mouseCursor,
          focusNode: focusNode,
          autofocus: autofocus,
          tooltip: tooltip,
          enableFeedback: enableFeedback,
          constraints: constraints,
          style: style,
          isSelected: isSelected,
          selectedIcon: selectedIcon,
          icon: icon,
        );
    }
  }
}

enum _Variant { standard, filled, filledTonal, outlined }

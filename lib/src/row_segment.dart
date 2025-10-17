part of 'connected_button_group.dart';

/// A widget that renders a single segment (button) within a row.
class _RowSegment<T> extends StatelessWidget {
  const _RowSegment({
    required this.item,
    required this.flex,
    required this.isFirst,
    required this.isLast,
    required this.selected,
    required this.onChanged,
    required this.onPressed,
    required this.onMenuItemSelected,
    required this.overflowMenu,
    required this.theme,
  });

  final ConnectedButtonItem<T> item;
  final int flex;
  final bool isFirst;
  final bool isLast;
  final bool selected;
  final ValueChanged<T>? onChanged;
  final ValueChanged<T>? onPressed;
  final void Function((T itemValue, ConnectedMenuEntry<T> entry) selection)?
  onMenuItemSelected;
  final List<ConnectedButtonItem<T>> overflowMenu;
  final ConnectedButtonGroupThemeData theme;

  @override
  Widget build(BuildContext context) {
    // Determine colours based on selection state and enabled state.
    final bool enabled = item.enabled;
    final Color bgColor = selected
        ? theme.selectedContainerColor!
        : theme.containerColor!;
    final Color contentColor = !enabled
        ? theme.disabledContentColor!
        : (selected
              ? theme.selectedContentColor!
              : theme.unselectedContentColor!);
    final dividerColor = theme.dividerColor!;

    // Build the core content for the segment.  Depending on whether
    // the item has a menu and whether it is split we choose between
    // several compositions: plain InkWell, PopupMenuButton, or split
    // combination.
    Widget segment;
    if (item.menu != null && item.menu!.isNotEmpty) {
      // This item has an attached menu.
      if (item.isSplit) {
        // Render as a split-button: primary area + chevron area.
        segment = _SplitButtonSegment<T>(
          item: item,
          selected: selected,
          enabled: enabled,
          contentColor: contentColor,
          bgColor: bgColor,
          dividerColor: dividerColor,
          onChanged: onChanged,
          onPressed: onPressed,
          onMenuItemSelected: onMenuItemSelected,
          overflowMenu: overflowMenu,
          theme: theme,
        );
      } else {
        // A plain menu button: clicking anywhere opens the menu; no
        // selection or primary action.
        segment = _PlainMenuButtonSegment<T>(
          item: item,
          enabled: enabled,
          contentColor: contentColor,
          bgColor: bgColor,
          dividerColor: dividerColor,
          onMenuItemSelected: onMenuItemSelected,
          onChanged: onChanged,
          onPressed: onPressed,
          overflowMenu: overflowMenu,
          theme: theme,
        );
      }
    } else {
      // A standard selectable or action-only button.
      segment = _StandardButtonSegment<T>(
        item: item,
        selected: selected,
        enabled: enabled,
        contentColor: contentColor,
        bgColor: bgColor,
        dividerColor: dividerColor,
        onChanged: onChanged,
        onPressed: onPressed,
        theme: theme,
      );
    }
    // Wrap with tooltip if provided.
    if (item.tooltip != null && item.tooltip!.isNotEmpty) {
      segment = Tooltip(message: item.tooltip!, child: segment);
    }
    // Decorate with a left divider except for the first item.
    return Expanded(
      flex: flex,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            left: isFirst ? BorderSide.none : BorderSide(color: dividerColor),
          ),
        ),
        child: segment,
      ),
    );
  }
}

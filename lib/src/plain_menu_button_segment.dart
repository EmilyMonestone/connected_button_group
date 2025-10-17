part of 'connected_button_group.dart';

/// A segment representing a plain menu button (non-split).
class _PlainMenuButtonSegment<T> extends StatelessWidget {
  const _PlainMenuButtonSegment({
    required this.item,
    required this.enabled,
    required this.contentColor,
    required this.bgColor,
    required this.dividerColor,
    required this.onMenuItemSelected,
    required this.onChanged,
    required this.onPressed,
    required this.overflowMenu,
    required this.theme,
  });

  final ConnectedButtonItem<T> item;
  final bool enabled;
  final Color contentColor;
  final Color bgColor;
  final Color dividerColor;
  final void Function((T itemValue, ConnectedMenuEntry<T> entry) selection)?
  onMenuItemSelected;
  final ValueChanged<T>? onChanged;
  final ValueChanged<T>? onPressed;
  final List<ConnectedButtonItem<T>> overflowMenu;
  final ConnectedButtonGroupThemeData theme;

  List<PopupMenuEntry<ConnectedMenuEntry<T>>> _buildMenuEntries(
    BuildContext context,
  ) {
    final menu = item.menu ?? <ConnectedMenuEntry<T>>[];
    final List<PopupMenuEntry<ConnectedMenuEntry<T>>> entries = [];
    for (final entry in menu) {
      entries.add(_popupEntry(entry));
    }
    // If this is the overflow handle we need to append the collapsed
    // items into the menu.  Overflow items are defined by
    // [overflowMenu] and consist of [ConnectedButtonItem] objects.
    if (identical(item, overflowMenu.isNotEmpty ? item : null)) {
      // no-op; the overflow handle will have its own menu set later.
    }
    return entries;
  }

  PopupMenuEntry<ConnectedMenuEntry<T>> _popupEntry(
    ConnectedMenuEntry<T> entry,
  ) {
    if (entry.checked != null) {
      return CheckedPopupMenuItem<ConnectedMenuEntry<T>>(
        value: entry,
        checked: entry.checked!,
        enabled: entry.enabled,
        child: _menuItemContent(entry),
      );
    }
    return PopupMenuItem<ConnectedMenuEntry<T>>(
      value: entry,
      enabled: entry.enabled,
      child: _menuItemContent(entry),
    );
  }

  Widget _menuItemContent(ConnectedMenuEntry<T> entry) {
    final Color color = entry.destructive
        ? Colors.red
        : theme.unselectedContentColor!;
    return Row(
      children: [
        if (entry.icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(entry.icon, size: 24.0, color: color),
          ),
        Text(entry.label, style: TextStyle(color: color)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine whether this button acts as the overflow handle.  A
    // sentinel overflow button will have an empty or null menu and a
    // non-empty [overflowMenu].
    final bool isOverflowHandle =
        (item.menu == null || item.menu!.isEmpty) && overflowMenu.isNotEmpty;
    // Flatten nested submenus.  This helper copies entries and submenus
    // into a single list.  Flutter's standard popup menu does not
    // support nested menus.
    List<ConnectedMenuEntry<T>> flattenMenuEntries(
      List<ConnectedMenuEntry<T>> menu,
    ) {
      final List<ConnectedMenuEntry<T>> flattened = [];
      for (final entry in menu) {
        flattened.add(entry);
        if (entry.submenu != null && entry.submenu!.isNotEmpty) {
          for (final sub in entry.submenu!) {
            flattened.add(sub);
          }
        }
      }
      return flattened;
    }

    // Build the menu list.  If this is the overflow handle, convert the
    // collapsed items into menu entries.  Otherwise use the item's own
    // menu.
    late final List<ConnectedMenuEntry<T>> menuEntries;
    if (isOverflowHandle) {
      // Convert collapsed [ConnectedButtonItem]s into menu entries.  Each
      // collapsed item becomes a simple menu entry that triggers the
      // same selection or action behaviour as pressing the item directly.
      menuEntries = overflowMenu.map((collapsed) {
        return ConnectedMenuEntry<T>(
          label: collapsed.label ?? collapsed.value.toString(),
          icon: collapsed.icon,
          value: collapsed.value,
          enabled: collapsed.enabled,
          onSelected: () {
            if (!collapsed.enabled) return;
            // Call the item's own primary callback if provided.
            collapsed.onPrimaryPressed?.call();
            // Invoke selection or action on the parent group.
            if (onChanged != null) {
              onChanged!(collapsed.value);
            } else if (onPressed != null) {
              onPressed!(collapsed.value);
            }
          },
        );
      }).toList();
    } else {
      menuEntries = flattenMenuEntries(item.menu ?? <ConnectedMenuEntry<T>>[]);
    }
    return PopupMenuButton<ConnectedMenuEntry<T>>(
      enabled: enabled,
      padding: EdgeInsets.zero,
      onSelected: (entry) {
        // First call the entry's own callback (which may trigger
        // selection or custom action).
        entry.onSelected?.call();
        // Then call the group-level menu selection callback if provided.
        if (onMenuItemSelected != null) {
          final pair = (item.value, entry);
          onMenuItemSelected!(pair);
        }
      },
      itemBuilder: (context) {
        return menuEntries.map((entry) {
          return _popupEntry(entry);
        }).toList();
      },
      child: InkWell(
        onTap: enabled ? () {} : null,
        child: Container(
          alignment: Alignment.center,
          color: bgColor,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (item.icon != null)
                Icon(item.icon, size: 24.0, color: contentColor),
              if (item.icon != null &&
                  item.label != null &&
                  item.label!.isNotEmpty)
                const SizedBox(width: 8.0),
              if (item.label != null && item.label!.isNotEmpty)
                Flexible(
                  child: Text(
                    item.label!,
                    style: TextStyle(color: contentColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(width: 8.0),
              Icon(Icons.arrow_drop_down, size: 24.0, color: contentColor),
            ],
          ),
        ),
      ),
    );
  }
}

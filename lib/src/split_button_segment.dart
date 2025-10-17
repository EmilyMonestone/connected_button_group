part of 'connected_button_group.dart';

/// A segment representing a split-button: a primary action and a chevron
/// opening a menu.
class _SplitButtonSegment<T> extends StatelessWidget {
  const _SplitButtonSegment({
    required this.item,
    required this.selected,
    required this.enabled,
    required this.contentColor,
    required this.bgColor,
    required this.dividerColor,
    required this.onChanged,
    required this.onPressed,
    required this.onMenuItemSelected,
    required this.overflowMenu,
    required this.theme,
  });

  final ConnectedButtonItem<T> item;
  final bool selected;
  final bool enabled;
  final Color contentColor;
  final Color bgColor;
  final Color dividerColor;
  final ValueChanged<T>? onChanged;
  final ValueChanged<T>? onPressed;
  final void Function((T itemValue, ConnectedMenuEntry<T> entry) selection)?
  onMenuItemSelected;
  final List<ConnectedButtonItem<T>> overflowMenu;
  final ConnectedButtonGroupThemeData theme;

  @override
  Widget build(BuildContext context) {
    // Build the menu entries, flattening any submenus as plain entries.
    List<ConnectedMenuEntry<T>> flattenMenu(List<ConnectedMenuEntry<T>> menu) {
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

    final menuList = flattenMenu(item.menu ?? <ConnectedMenuEntry<T>>[]);
    // Primary tap handler: selection or action.
    void handlePrimaryTap() {
      if (!enabled) return;
      if (item.onPrimaryPressed != null) {
        item.onPrimaryPressed!();
      }
      if (onChanged != null) {
        onChanged!(item.value);
      } else if (onPressed != null) {
        onPressed!(item.value);
      }
    }

    // Build the primary and chevron children.
    final primaryChild = InkWell(
      onTap: enabled ? handlePrimaryTap : null,
      child: Container(
        alignment: Alignment.center,
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
          ],
        ),
      ),
    );
    final chevron = PopupMenuButton<ConnectedMenuEntry<T>>(
      enabled: enabled,
      padding: EdgeInsets.zero,
      onSelected: (entry) {
        entry.onSelected?.call();
        if (onMenuItemSelected != null) {
          final pair = (item.value, entry);
          onMenuItemSelected!(pair);
        }
      },
      itemBuilder: (context) {
        return menuList.map((entry) {
          if (entry.checked != null) {
            return CheckedPopupMenuItem<ConnectedMenuEntry<T>>(
              value: entry,
              checked: entry.checked!,
              enabled: entry.enabled,
              child: _menuItemRow(entry),
            );
          }
          return PopupMenuItem<ConnectedMenuEntry<T>>(
            value: entry,
            enabled: entry.enabled,
            child: _menuItemRow(entry),
          );
        }).toList();
      },
      child: InkWell(
        onTap: enabled ? () {} : null,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Icon(Icons.arrow_drop_down, size: 24.0, color: contentColor),
        ),
      ),
    );
    return Container(
      color: bgColor,
      child: Row(
        children: [
          Expanded(child: primaryChild),
          // Internal divider between primary and chevron.
          Container(width: 1.0, color: dividerColor, height: double.infinity),
          chevron,
        ],
      ),
    );
  }

  Widget _menuItemRow(ConnectedMenuEntry<T> entry) {
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
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'item.dart';
import 'menu_entry.dart';
import 'overflow_strategy.dart';
import 'theme.dart';

/// A connected button group following Material 3 Expressive patterns.
///
/// This widget arranges a list of [ConnectedButtonItem]s into a single
/// pill-shaped container divided into segments.  The group supports
/// single-selection semantics, split-buttons and overflow menus.  When
/// the group would exceed the available width it can collapse trailing
/// items into an overflow menu or wrap onto additional rows, depending
/// on [overflowStrategy].  See the example for usage.
class ConnectedButtonGroup<T> extends StatelessWidget {
  /// Creates a connected button group.
  const ConnectedButtonGroup({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.onPressed,
    this.onMenuItemSelected,
    this.overflowStrategy = ConnectedOverflowStrategy.menuThenWrap,
    this.maxLines,
    this.rowSpacing = 8.0,
    this.runPadding = const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
    this.overflowItem,
    this.theme,
  });

  /// The items in the group, in order.  Each item becomes a segment.
  final List<ConnectedButtonItem<T>> items;

  /// The currently selected value.  When non-null the corresponding
  /// segment is highlighted.  Passing null disables selection and
  /// effectively turns the group into a toolbar where each item fires
  /// [onPressed] when tapped.
  final T? value;

  /// Callback invoked when the selection changes.  Receives the new
  /// value.  Ignored if [value] is null.
  final ValueChanged<T>? onChanged;

  /// Callback invoked when an item without selection semantics is
  /// tapped.  This is only used when [onChanged] is null, otherwise
  /// selection callbacks take precedence.
  final ValueChanged<T>? onPressed;

  /// Callback invoked when a menu item is selected.  Receives both the
  /// parent item value and the selected menu entry.  This is called
  /// before the entry's own [ConnectedMenuEntry.onSelected] callback.
  final void Function(
      (T itemValue, ConnectedMenuEntry<T> entry) selection)? onMenuItemSelected;

  /// How to handle items that do not fit on a single line.  See
  /// [ConnectedOverflowStrategy] for details.
  final ConnectedOverflowStrategy overflowStrategy;

  /// The maximum number of rows to allow when wrapping.  When null the
  /// group can wrap onto as many rows as needed.  When set to 1 the
  /// group will never wrap; instead it will collapse items into an
  /// overflow menu.
  final int? maxLines;

  /// Vertical spacing between wrapped rows.
  final double rowSpacing;

  /// Padding applied inside each row container.  This separates the
  /// content from the outer stadium border.
  final EdgeInsets runPadding;

  /// Optional custom item used to represent the overflow handle.  If
  /// provided, this item is used in place of the default "More" item.
  /// The item's [menu] property is ignored and will be populated with
  /// overflow entries as needed.
  final ConnectedButtonItem<T>? overflowItem;

  /// Optional theme overrides.  When null, defaults are resolved from
  /// [ThemeData.extensions] or the ambient [ColorScheme].
  final ConnectedButtonGroupThemeData? theme;

  @override
  Widget build(BuildContext context) {
    final localTheme = _resolveTheme(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        // If there are no items we render nothing.
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }
        final rows = _packRows(context, constraints.maxWidth, localTheme);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < rows.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i == rows.length - 1 ? 0.0 : rowSpacing,
                ),
                child: _RowContainer<T>(
                  row: rows[i],
                  value: value,
                  onChanged: onChanged,
                  onPressed: onPressed,
                  onMenuItemSelected: onMenuItemSelected,
                  theme: localTheme,
                  runPadding: runPadding,
                ),
              ),
          ],
        );
      },
    );
  }

  /// Resolves a theme for this group by merging [theme] with any
  /// [ConnectedButtonGroupThemeData] found in the ambient [ThemeData]
  /// extensions and falling back to sensible defaults derived from
  /// [ColorScheme].
  ConnectedButtonGroupThemeData _resolveTheme(BuildContext context) {
    final ThemeData base = Theme.of(context);
    final scheme = base.colorScheme;
    final ext = base.extension<ConnectedButtonGroupThemeData>();
    final merged = ext?.copyWith(
      containerColor: theme?.containerColor,
      selectedContainerColor: theme?.selectedContainerColor,
      selectedContentColor: theme?.selectedContentColor,
      unselectedContentColor: theme?.unselectedContentColor,
      disabledContentColor: theme?.disabledContentColor,
      dividerColor: theme?.dividerColor,
      focusOutlineColor: theme?.focusOutlineColor,
    ) ??
        theme;
    return ConnectedButtonGroupThemeData(
      containerColor: merged?.containerColor ?? scheme.surfaceVariant,
      selectedContainerColor:
          merged?.selectedContainerColor ?? scheme.primaryContainer,
      selectedContentColor:
          merged?.selectedContentColor ?? scheme.onPrimaryContainer,
      unselectedContentColor:
          merged?.unselectedContentColor ?? scheme.onSurfaceVariant,
      disabledContentColor:
          merged?.disabledContentColor ?? scheme.onSurfaceVariant.withOpacity(0.38),
      dividerColor: merged?.dividerColor ?? scheme.outlineVariant,
      focusOutlineColor: merged?.focusOutlineColor ?? scheme.outline,
    );
  }


  /// Packs the list of items into rows according to the current
  /// [overflowStrategy] and available width.  Each packed row holds a
  /// collection of visible items and any items that have been collapsed
  /// into an overflow menu.  A sentinel [ConnectedButtonItem] is
  /// inserted into the row when necessary to represent the overflow menu.
  List<_PackedRow<T>> _packRows(
      BuildContext context, double maxWidth, ConnectedButtonGroupThemeData theme) {
    final List<_PackedRow<T>> rows = [];
    if (items.isEmpty) return rows;

    // Prepare a default overflow item if none was provided.  We choose a
    // generic label and icon; the menu will be populated later.
    final defaultOverflowItem = ConnectedButtonItem<T>(
      value: items.first.value,
      label: 'More',
      icon: Icons.more_horiz,
      tooltip: 'More options',
      enabled: true,
      menu: const [],
    );
    final baseOverflowItem = overflowItem ?? defaultOverflowItem;

    // Pre-measure all item widths for the given context.  Widths are
    // computed based on the current text style and fixed paddings.
    final List<double> itemWidths = <double>[];
    for (final item in items) {
      itemWidths.add(_measureItemWidth(context, item));
    }
    final double overflowWidth = _measureItemWidth(context, baseOverflowItem);

    int index = 0;
    int rowCount = 0;
    while (index < items.length) {
      if (maxLines != null && rowCount >= maxLines!) {
        // We have reached the maximum number of rows; collapse all
        // remaining items into the last row using an overflow menu.
        final remaining = items.sublist(index);
        final visible = <ConnectedButtonItem<T>>[];
        final widths = <double>[];
        final overflowMenu = <ConnectedButtonItem<T>>[];
        // Always show at least the overflow handle if we cannot fit any
        // normal items.  Use the baseOverflowItem for the visual.
        visible.add(baseOverflowItem);
        widths.add(overflowWidth);
        overflowMenu.addAll(remaining);
        rows.add(_PackedRow(
          items: visible,
          widths: widths,
          overflowMenu: overflowMenu,
        ));
        return rows;
      }
      double remainingWidth = maxWidth;
      final List<ConnectedButtonItem<T>> current = [];
      final List<double> currentWidths = [];
      final List<ConnectedButtonItem<T>> currentOverflow = [];
      // Fill the row greedily until overflow.
      while (index < items.length) {
        final double w = itemWidths[index];
        // Does the item fit in the remaining width?  If yes, add it.
        if (current.isEmpty) {
          // If this is the first item in the row we always accept it,
          // regardless of its width.  In extreme cases (e.g. a very
          // long label) this may overflow the available width but we
          // choose to render it anyway.
          current.add(items[index]);
          currentWidths.add(w);
          remainingWidth -= w;
          index++;
          continue;
        }
        if (w <= remainingWidth) {
          current.add(items[index]);
          currentWidths.add(w);
          remainingWidth -= w;
          index++;
          continue;
        }
        // At this point the current item does not fit.  We need to
        // determine how to handle overflow according to the strategy.
        break;
      }
      // Determine if overflow occurs because there are more items left.
      final bool hasMoreItems = index < items.length;
      final bool forceMenu = overflowStrategy == ConnectedOverflowStrategy.menu ||
          overflowStrategy == ConnectedOverflowStrategy.menuThenWrap;
      final bool allowWrap = overflowStrategy == ConnectedOverflowStrategy.wrapThenMenu ||
          overflowStrategy == ConnectedOverflowStrategy.none ||
          (overflowStrategy == ConnectedOverflowStrategy.menuThenWrap && !hasMoreItems);
      if (hasMoreItems && forceMenu) {
        // We need to fit the overflow handle into the current row.  Find
        // the minimal suffix of current items that can be replaced by
        // the overflow handle to fit within the row.
        // If the overflow handle doesn't fit even by itself, we will
        // start a new row.
        int removeCount = 0;
        double freedWidth = 0.0;
        while (removeCount < current.length &&
            (remainingWidth + freedWidth) + overflowWidth < 0) {
          // Remove the last item and reclaim its width.
          removeCount++;
          freedWidth += currentWidths[currentWidths.length - removeCount];
        }
        // If nothing fits (overflow handle alone is larger than max width)
        // then we must wrap even though the strategy is menu-first.
        final bool fitsWithOverflow = current.isEmpty
            ? overflowWidth <= maxWidth
            : (remainingWidth + freedWidth + overflowWidth) <= maxWidth;
        if (!fitsWithOverflow) {
          // Cannot fit overflow handle in the current row.  Start a new
          // row and handle overflow on the next iteration.
          if (current.isNotEmpty) {
            rows.add(_PackedRow(
              items: current,
              widths: currentWidths,
              overflowMenu: [],
            ));
            rowCount++;
          }
          // Do not advance index here since we still need to place the
          // next items.  Continue to next iteration.
          continue;
        }
        // Remove the trailing removeCount items and add them to the
        // overflow menu.  Then add the overflow handle itself to
        // current.
        final int startRemove = current.length - removeCount;
        currentOverflow.addAll(current.sublist(startRemove));
        current.removeRange(startRemove, current.length);
        currentWidths.removeRange(startRemove, currentWidths.length);
        current.add(baseOverflowItem);
        currentWidths.add(overflowWidth);
        // All remaining items (including the one that didn't fit) will
        // appear in the next rows.
      }
      // Add the packed row to the list.  If we have removed items for
      // overflow they will be stored in currentOverflow.  Note that
      // currentOverflow is distinct from the remaining items which will
      // be placed in subsequent rows.
      rows.add(_PackedRow(
        items: List<ConnectedButtonItem<T>>.from(current),
        widths: List<double>.from(currentWidths),
        overflowMenu: List<ConnectedButtonItem<T>>.from(currentOverflow),
      ));
      rowCount++;
    }
    return rows;
  }

  /// Estimates the width of an item based on its label, icon and
  /// structure.  This method uses a [TextPainter] to measure the label
  /// with the current text theme.  Widths are used to calculate how
  /// items fit into rows and to assign flex factors so that items grow
  /// proportionally to their intrinsic sizes.
  double _measureItemWidth(BuildContext context, ConnectedButtonItem<T> item) {
    final theme = Theme.of(context);
    final TextStyle style = theme.textTheme.labelLarge ??
        theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 14.0);
    double width = 0.0;
    // Measure label
    if (item.label != null && item.label!.isNotEmpty) {
      final TextPainter painter = TextPainter(
        text: TextSpan(text: item.label, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();
      width += painter.width;
    }
    // Add icon + gap
    if (item.icon != null) {
      width += 24.0; // icon size
      if (item.label != null && item.label!.isNotEmpty) {
        width += 8.0; // gap between icon and label
      }
    }
    // If the item has a menu, allocate space for an arrow.
    if (item.menu != null && item.menu!.isNotEmpty) {
      // If this is a split-button we allocate a separate area for the
      // chevron; otherwise the chevron appears inline with the label.
      if (item.isSplit) {
        width += 24.0 + 8.0; // chevron size + gap
      } else {
        // Inline chevron: allocate arrow size + gap
        width += 24.0 + 8.0;
      }
    }
    // Horizontal padding on both sides
    width += 2 * 16.0;
    return width;
  }
}

// Represents a packed row with visible items and an optional overflow list.
class _PackedRow<T> {
  _PackedRow({
    required this.items,
    required this.widths,
    required this.overflowMenu,
  });
  final List<ConnectedButtonItem<T>> items;
  final List<double> widths;
  final List<ConnectedButtonItem<T>> overflowMenu;
}

/// A widget that renders a single packed row of the connected button group.
class _RowContainer<T> extends StatelessWidget {
  const _RowContainer({
    required this.row,
    required this.value,
    required this.onChanged,
    required this.onPressed,
    required this.onMenuItemSelected,
    required this.theme,
    required this.runPadding,
  });

  final _PackedRow<T> row;
  final T? value;
  final ValueChanged<T>? onChanged;
  final ValueChanged<T>? onPressed;
  final void Function(
      (T itemValue, ConnectedMenuEntry<T> entry) selection)? onMenuItemSelected;
  final ConnectedButtonGroupThemeData theme;
  final EdgeInsets runPadding;

  @override
  Widget build(BuildContext context) {
    // Compute flex values proportional to item widths.  Each flex is at
    // least 1 to avoid zero-flex errors.
    final List<int> flexes = row.widths
        .map((w) => math.max(1, (w * 1000.0).round()))
        .toList();
    final Color containerColor = theme.containerColor!;
    return Material(
      shape: const StadiumBorder(),
      color: containerColor,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: runPadding,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < row.items.length; i++)
              _RowSegment<T>(
                item: row.items[i],
                flex: flexes[i],
                isFirst: i == 0,
                isLast: i == row.items.length - 1,
                selected: value != null && value == row.items[i].value,
                onChanged: onChanged,
                onPressed: onPressed,
                onMenuItemSelected: onMenuItemSelected,
                overflowMenu: row.overflowMenu,
                theme: theme,
              ),
          ],
        ),
      ),
    );
  }
}

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
  final void Function(
      (T itemValue, ConnectedMenuEntry<T> entry) selection)? onMenuItemSelected;
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
        : (selected ? theme.selectedContentColor! : theme.unselectedContentColor!);
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
            left: isFirst
                ? BorderSide.none
                : BorderSide(color: dividerColor),
          ),
        ),
        child: segment,
      ),
    );
  }
}

/// A segment representing a standard button (no menu).
class _StandardButtonSegment<T> extends StatelessWidget {
  const _StandardButtonSegment({
    required this.item,
    required this.selected,
    required this.enabled,
    required this.contentColor,
    required this.bgColor,
    required this.dividerColor,
    required this.onChanged,
    required this.onPressed,
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
  final ConnectedButtonGroupThemeData theme;

  @override
  Widget build(BuildContext context) {
    // Determine the callback: selection or action-only.
    void handleTap() {
      if (!enabled) return;
      if (onChanged != null) {
        onChanged!(item.value);
      } else if (onPressed != null) {
        onPressed!(item.value);
      }
    }
    return InkWell(
      onTap: enabled ? handleTap : null,
      customBorder: const RoundedRectangleBorder(),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        color: bgColor,
        child: _buildContent(contentColor),
      ),
    );
  }

  Widget _buildContent(Color contentColor) {
    final hasIcon = item.icon != null;
    final hasLabel = item.label != null && item.label!.isNotEmpty;
    return Row(
      mainAxisAlignment: hasLabel ? MainAxisAlignment.center : MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasIcon)
          Icon(
            item.icon,
            size: 24.0,
            color: contentColor,
          ),
        if (hasIcon && hasLabel) const SizedBox(width: 8.0),
        if (hasLabel)
          Text(
            item.label!,
            style: TextStyle(color: contentColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}

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
  final void Function(
      (T itemValue, ConnectedMenuEntry<T> entry) selection)? onMenuItemSelected;
  final ValueChanged<T>? onChanged;
  final ValueChanged<T>? onPressed;
  final List<ConnectedButtonItem<T>> overflowMenu;
  final ConnectedButtonGroupThemeData theme;

  List<PopupMenuEntry<ConnectedMenuEntry<T>>> _buildMenuEntries(
      BuildContext context) {
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
      ConnectedMenuEntry<T> entry) {
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
        List<ConnectedMenuEntry<T>> menu) {
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
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
  final void Function(
      (T itemValue, ConnectedMenuEntry<T> entry) selection)? onMenuItemSelected;
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
          child: Icon(Icons.arrow_drop_down,
              size: 24.0, color: contentColor),
        ),
      ),
    );
    return Container(
      color: bgColor,
      child: Row(
        children: [
          Expanded(child: primaryChild),
          // Internal divider between primary and chevron.
          Container(
            width: 1.0,
            color: dividerColor,
            height: double.infinity,
          ),
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
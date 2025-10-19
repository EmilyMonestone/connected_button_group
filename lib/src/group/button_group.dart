import 'dart:math' as math;

import 'package:button_group/src/group/group_icon_button.dart';
import 'package:flutter/material.dart';

import '../theme/button_group_theme.dart';
import 'button_group_type.dart';
import 'group_shape.dart';
import 'group_size.dart';
import 'internal/row_info.dart';
import 'overflow_strategy.dart';
import 'split_button.dart';

/// Lays out a collection of normal Material buttons into a coherent group.
///
/// A [ButtonGroup] is a purely structural widget; it does not impose any
/// selection logic on its children.  Each child button remains independent
/// and fires its own callbacks when pressed.  The group provides an outer
/// container and orchestrates spacing, sizing, overflow handling and
/// optional row wrapping.
///
/// Two visual styles are supported via [type]:
///
/// * [ButtonGroupType.connected] produces a continuous pill or square
///   container with minimal spacing (2dp) between items.  When a child is
///   pressed, only that child changes shape.  This style is ideal for
///   closely related mode or view switches.
/// * [ButtonGroupType.standard] spaces its children more generously (gap
///   depends on [size]) and optionally applies a micro‑reflow on press.
///   Use this style when grouping independent actions such as toolbar
///   buttons.
///
/// The group will attempt to place all children on a single row when
/// possible. If the total width exceeds the available space the group
/// will behave according to [overflowStrategy]. By default
/// ([OverflowStrategy.menu]) the trailing items that no longer
/// fit are collapsed into a “More” menu on the first row. If even the
/// first item and the overflow control cannot fit then the group wraps
/// to multiple rows. Alternatively, use [OverflowStrategy.wrap] to
/// greedily wrap; when [maxLines] is reached, any remaining items on the
/// final allowed row are collapsed into a menu.
class ButtonGroup extends StatefulWidget {
  const ButtonGroup({
    super.key,
    required this.children,
    this.type = ButtonGroupType.connected,
    this.size = GroupSize.s,
    this.shape = GroupShape.round,
    this.overflowStrategy = OverflowStrategy.menu,
    this.maxLines,
    this.rowSpacing = 8,
    this.runPadding = const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
    this.moreBuilder,
    this.groupTheme,
    this.menuTheme,
  });

  /// The list of widgets to display within the group.  These should be
  /// standard Material buttons (e.g. [FilledButton], [ElevatedButton],
  /// [OutlinedButton], [IconButton], or [SplitButton]).
  final List<Widget> children;

  /// Selects the visual style of the group.  See [ButtonGroupType] for
  /// details.
  final ButtonGroupType type;

  /// Selects the size ramp used for the group.  The height of each row
  /// and the default spacing between items are derived from this value.
  final GroupSize size;

  /// Selects the outer shape of the group container.  See [GroupShape].
  final GroupShape shape;

  /// Determines how overflow is handled when the children exceed the
  /// available width.  Defaults to [OverflowStrategy.menu].
  final OverflowStrategy overflowStrategy;

  /// The maximum number of lines (rows) allowed.  When `null` there is
  /// no limit on the number of rows that may be produced by wrapping.
  final int? maxLines;

  /// Vertical spacing between rows.  Only applies when the group wraps
  /// onto multiple lines.
  final double rowSpacing;

  /// Padding applied around each row.  This controls the horizontal
  /// inset of the group container as well as vertical padding inside
  /// individual rows.
  final EdgeInsets runPadding;

  /// Optional builder for the overflow “More” button.  If provided this
  /// callback will be invoked to construct the overflow control; otherwise
  /// a simple [FilledButton] containing an ellipsis icon and the label
  /// “More” will be used.  The builder receives the current [BuildContext].
  final Widget Function(BuildContext context)? moreBuilder;

  /// Theme overrides applied to this group.  Only the properties that are
  /// non‑null will override the defaults.  See [ButtonGroupThemeData] for
  /// details.
  final ButtonGroupThemeData? groupTheme;

  /// Optional menu theme used by overflow menus created by this group.
  final MenuThemeData? menuTheme;

  @override
  State<ButtonGroup> createState() => _ButtonGroupState();
}

class _ButtonGroupState extends State<ButtonGroup> {
  /// A key assigned to each child in order to measure its width.
  late List<GlobalKey> _childKeys;

  /// Maps a child index to its measured width.
  final Map<int, double> _childWidths = {};

  /// Stores the most recent available width used to compute row packing.
  double _availableWidth = 0;

  /// Caches the computed rows.  Each entry contains the indices of the
  /// children that belong to that row and an optional list of indices that
  /// have been collapsed into the overflow menu on that row.
  List<RowInfo> _rows = [];

  @override
  void initState() {
    super.initState();
    _initializeChildKeys();
  }

  @override
  void didUpdateWidget(covariant ButtonGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length) {
      _initializeChildKeys();
    }
  }

  void _initializeChildKeys() {
    _childKeys = List.generate(widget.children.length, (index) => GlobalKey());
    _childWidths.clear();
    _rows = [];
  }

  /// Measures the width of each child after layout and updates the
  /// [_childWidths] map.  If any widths changed a rebuild will be
  /// scheduled.  This measurement occurs in a post‑frame callback to
  /// ensure the layout is complete.
  void _measureChildren() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool changed = false;
      for (var i = 0; i < _childKeys.length; i++) {
        final context = _childKeys[i].currentContext;
        if (context != null) {
          final size = context.size;
          if (size != null) {
            final width = size.width;
            if (_childWidths[i] != width) {
              _childWidths[i] = width;
              changed = true;
            }
          }
        }
      }
      if (changed) {
        setState(() {
          // Recompute rows on next build.
        });
      }
    });
  }

  /// Computes the row packing based on the measured child widths and
  /// available width.  The result is stored in [_rows].
  void _computeRows(double maxWidth) {
    final gap =
        widget.groupTheme?.intraGap ??
        (widget.type == ButtonGroupType.connected
            ? 2
            : widget.size.standardGap);
    final available = maxWidth - widget.runPadding.horizontal;

    // If we haven’t measured all children yet default to a provisional
    // width for those children to avoid degenerately computing a row per
    // child.  A reasonable guess is half the available width divided by
    // the number of remaining children.
    final provisionalWidth = available / math.max(widget.children.length, 1);
    final widths = <double>[];
    for (var i = 0; i < widget.children.length; i++) {
      widths.add(_childWidths[i] ?? provisionalWidth);
    }

    final rows = <RowInfo>[];

    // Helper: greedy wrap into multiple rows. Optionally collapse remainder
    // into overflow on the last row depending on strategy.
    void wrapGreedy({required bool collapseRemainderIntoMenu}) {
      int idx = 0;
      while (idx < widths.length) {
        double rowWidth = 0;
        final rowIndices = <int>[];
        while (idx < widths.length) {
          final w = widths[idx];
          final next = rowIndices.isEmpty ? w : rowWidth + gap + w;
          if (next <= available) {
            rowWidth = next;
            rowIndices.add(idx);
            idx++;
          } else {
            break;
          }
        }
        if (rowIndices.isEmpty) {
          rowIndices.add(idx);
          idx++;
        }
        // If maxLines reached, decide what to do with the remainder.
        if (widget.maxLines != null && rows.length + 1 >= widget.maxLines!) {
          if (collapseRemainderIntoMenu) {
            final overflow = <int>[];
            for (var j = idx; j < widths.length; j++) {
              overflow.add(j);
            }
            rows.add(
              RowInfo(rowIndices: rowIndices, overflowIndices: overflow),
            );
            idx = widths.length;
            break;
          } else {
            // Append all remaining items to this last row (no menu). The row
            // may overflow; _buildRow will make it scrollable.
            for (var j = idx; j < widths.length; j++) {
              rowIndices.add(j);
            }
            rows.add(RowInfo(rowIndices: rowIndices));
            idx = widths.length;
            break;
          }
        } else {
          rows.add(RowInfo(rowIndices: rowIndices));
        }
      }
    }

    final moreWidth = _estimateMoreButtonWidth();

    switch (widget.overflowStrategy) {
      case OverflowStrategy.menu:
        {
          // Try to keep a single visible row by collapsing trailing items into a
          // menu. If even the first item + menu cannot fit, fall back to wrapping.
          if (widths.isEmpty) {
            _rows = rows;
            return;
          }
          // Can we show at least the first item and a More button?
          final needFirstPlusMenu = widths.length > 1;
          final firstPlusMenuWidth =
              widths.first + (needFirstPlusMenu ? (gap + moreWidth) : 0);
          if (needFirstPlusMenu && firstPlusMenuWidth > available) {
            // Fallback: wrap greedily. When wrapping due to this fallback we do
            // not force per-row menus; standard wrap semantics apply (last row
            // may collapse at maxLines according to general rule).
            wrapGreedy(collapseRemainderIntoMenu: true);
            _rows = rows;
            return;
          }
          // Build the single row with as many leading items as fit, reserving
          // space for the More button if there are remaining items.
          double rowWidth = 0;
          final visible = <int>[];
          int i = 0;
          while (i < widths.length) {
            final w = widths[i];
            final add = (visible.isEmpty ? 0 : gap) + w;
            final remainingAfterThis = (i < widths.length - 1);
            final moreGap = (visible.length + 1) > 0
                ? gap
                : 0; // gap before More
            final required =
                rowWidth +
                add +
                (remainingAfterThis ? (moreGap + moreWidth) : 0);
            if (required <= available) {
              rowWidth += add;
              visible.add(i);
              i++;
            } else {
              break;
            }
          }
          // If nothing fit (extreme case), fall back to wrapping.
          if (visible.isEmpty) {
            wrapGreedy(collapseRemainderIntoMenu: true);
            _rows = rows;
            return;
          }
          final overflow = <int>[];
          for (var j = visible.length; j < widths.length; j++) {
            overflow.add(j);
          }
          rows.add(RowInfo(rowIndices: visible, overflowIndices: overflow));
          _rows = rows;
          return;
        }
      case OverflowStrategy.wrap:
        {
          // Greedy wrapping; collapse remainder into menu on the last row when
          // maxLines is reached.
          wrapGreedy(collapseRemainderIntoMenu: true);
          _rows = rows;
          return;
        }
    }
  }

  /// Estimates the width of the overflow “More” control.  The estimate is
  /// based on the label “More” rendered using the current theme’s
  /// [TextTheme.labelLarge] and padded similarly to a standard button.
  double _estimateMoreButtonWidth() {
    // Estimate text width using a TextPainter.
    final context = this.context;
    final textStyle =
        Theme.of(context).textTheme.labelLarge ??
        const TextStyle(fontSize: 14.0);
    final direction = Directionality.of(context);
    final painter = TextPainter(
      text: TextSpan(text: 'More', style: textStyle),
      textDirection: direction,
      maxLines: 1,
    )..layout();
    final textWidth = painter.width;
    // Allow some horizontal padding and an icon (ellipsis) width.
    final iconWidth = widget.size.iconSize;
    final horizontalPadding = 16.0;
    return textWidth + iconWidth + horizontalPadding;
  }

  /// Returns true if the given row's measured width (children + gaps
  /// and optional overflow button) exceeds the available width for a row.
  bool _rowWouldOverflow(RowInfo info) {
    final available = _availableWidth - widget.runPadding.horizontal;
    final gap =
        widget.groupTheme?.intraGap ??
        (widget.type == ButtonGroupType.connected
            ? 2
            : widget.size.standardGap);

    double total = 0;
    for (int i = 0; i < info.rowIndices.length; i++) {
      final idx = info.rowIndices[i];
      final w = _childWidths[idx] ?? 0;
      if (i == 0) {
        total += w;
      } else {
        total += gap + w;
      }
    }
    if (info.overflowIndices.isNotEmpty) {
      final moreWidth = _estimateMoreButtonWidth();
      total += (info.rowIndices.isEmpty ? 0 : gap) + moreWidth;
    }
    // Small epsilon for rounding/layout jitter.
    return total > available + 0.5;
  }

  @override
  Widget build(BuildContext context) {
    // Kick off measurement.  This will schedule a post‑frame callback.
    _measureChildren();
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        if (_availableWidth != maxWidth) {
          _availableWidth = maxWidth;
          _computeRows(maxWidth);
        }
        final rowsWidgets = <Widget>[];
        for (var i = 0; i < _rows.length; i++) {
          final rowInfo = _rows[i];
          rowsWidgets.add(_buildRow(context, rowInfo));
          if (i < _rows.length - 1) {
            rowsWidgets.add(SizedBox(height: widget.rowSpacing));
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rowsWidgets,
        );
      },
    );
  }

  Widget _buildRow(BuildContext context, RowInfo info) {
    // Resolve any theme extension and effective visual density.
    final baseTheme = Theme.of(context);
    final ext = baseTheme.extension<ButtonGroupThemeData>();
    final effectiveVisualDensity =
        widget.groupTheme?.visualDensity ?? ext?.visualDensity;

    // Compute effective height incorporating VisualDensity's vertical adjustment.
    final baseHeight = widget.size.containerHeight;
    final heightAdjustment =
        (effectiveVisualDensity?.baseSizeAdjustment.dy ?? 0);
    // Never let visual density reduce below the token height.
    final effectiveHeight = math.max(baseHeight, baseHeight + heightAdjustment);

    // Typography & icon sizing derived from GroupSize
    final double fontSize = widget.size.labelFontSize;
    final double iconSize = widget.size.iconSize;
    final TextStyle labelTextStyle =
        baseTheme.textTheme.labelLarge?.copyWith(fontSize: fontSize) ??
        TextStyle(fontSize: fontSize);

    final gap =
        widget.groupTheme?.intraGap ??
        (widget.type == ButtonGroupType.connected
            ? 2
            : widget.size.standardGap);
    final children = <Widget>[];
    // Build visible children.
    for (var i = 0; i < info.rowIndices.length; i++) {
      final index = info.rowIndices[i];
      var rawChild = widget.children[index];
      final isFirst = i == 0;
      final bool hasOverflow = info.overflowIndices.isNotEmpty;
      final bool isLastVisible = i == info.rowIndices.length - 1;
      final bool isLastSegment = isLastVisible && !hasOverflow;
      if (rawChild is SplitButton) {
        final sb = rawChild;
        // Ensure SplitButton inherits group size/shape.
        // For connected groups, apply position-based outer rounding.
        // For standard groups, keep fully rounded edges on both sides.
        final bool outerLeading = widget.type == ButtonGroupType.connected
            ? isFirst
            : true;
        final bool outerTrailing = widget.type == ButtonGroupType.connected
            ? isLastSegment
            : true;
        rawChild = SplitButton(
          key: sb.key,
          primaryChild: sb.primaryChild,
          menuEntries: sb.menuEntries,
          onPrimaryPressed: sb.onPrimaryPressed,
          size: widget.size,
          shape: widget.shape,
          style: sb.style,
          menuAlignment: sb.menuAlignment,
          outerOnLeadingEdge: outerLeading,
          outerOnTrailingEdge: outerTrailing,
        );
      }
      Widget wrappedChild = rawChild;
      if (wrappedChild is GroupIconButton) {
        final gib = wrappedChild as GroupIconButton;
        final double targetWidth = groupIconButtonTargetWidth(
          widget.size,
          gib.width,
        );
        wrappedChild = SizedBox(
          height: effectiveHeight,
          width: targetWidth,
          child: Center(child: wrappedChild),
        );
      } else if (wrappedChild is IconButton) {
        // Default Material IconButtons remain 1:1 (circle/square)
        wrappedChild = SizedBox(
          height: effectiveHeight,
          width: effectiveHeight,
          child: Center(child: wrappedChild),
        );
      }
      Widget wrapped = KeyedSubtree(
        key: _childKeys[index],
        child: wrappedChild,
      );
      if (widget.type == ButtonGroupType.connected) {
        final isFirst = i == 0;
        final bool hasOverflow = info.overflowIndices.isNotEmpty;
        final bool isLastVisible = i == info.rowIndices.length - 1;
        final bool isLastSegment = isLastVisible && !hasOverflow;
        final outerRadius = widget.shape == GroupShape.round
            ? widget.size.containerHeight / 2
            : widget.size.squareOuterRadius;
        final innerRadius = widget.size.connectedInnerRadius;
        final borderRadius = isFirst && isLastSegment
            ? BorderRadius.circular(outerRadius)
            : isFirst
            ? BorderRadius.only(
                topLeft: Radius.circular(outerRadius),
                bottomLeft: Radius.circular(outerRadius),
                topRight: Radius.circular(innerRadius),
                bottomRight: Radius.circular(innerRadius),
              )
            : isLastSegment
            ? BorderRadius.only(
                topLeft: Radius.circular(innerRadius),
                bottomLeft: Radius.circular(innerRadius),
                topRight: Radius.circular(outerRadius),
                bottomRight: Radius.circular(outerRadius),
              )
            : BorderRadius.all(Radius.circular(innerRadius));

        // Ensure the segment uses the correct inner radius even if the child
        // button defaults to a StadiumBorder. Also apply to SplitButton so
        // density and any default shapes are aligned; its internal styles will
        // override where needed.
        final shape = RoundedRectangleBorder(borderRadius: borderRadius);
        final theme = Theme.of(context);
        wrapped = Theme(
          data: theme.copyWith(
            visualDensity: effectiveVisualDensity ?? theme.visualDensity,
            iconButtonTheme: IconButtonThemeData(
              style: ButtonStyle(
                iconSize: WidgetStatePropertyAll<double>(iconSize),
                padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
                  EdgeInsets.zero,
                ),
                alignment: Alignment.center,
                minimumSize: WidgetStatePropertyAll<Size?>(Size.zero),
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: ButtonStyle(
                shape: WidgetStatePropertyAll<OutlinedBorder>(shape),
                minimumSize: WidgetStatePropertyAll<Size?>(
                  Size(0, effectiveHeight),
                ),
                fixedSize: WidgetStatePropertyAll<Size?>(
                  Size.fromHeight(effectiveHeight),
                ),
                textStyle: WidgetStatePropertyAll<TextStyle>(labelTextStyle),
                iconSize: WidgetStatePropertyAll<double>(iconSize),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                shape: WidgetStatePropertyAll<OutlinedBorder>(shape),
                minimumSize: WidgetStatePropertyAll<Size?>(
                  Size(0, effectiveHeight),
                ),
                fixedSize: WidgetStatePropertyAll<Size?>(
                  Size.fromHeight(effectiveHeight),
                ),
                textStyle: WidgetStatePropertyAll<TextStyle>(labelTextStyle),
                iconSize: WidgetStatePropertyAll<double>(iconSize),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: ButtonStyle(
                shape: WidgetStatePropertyAll<OutlinedBorder>(shape),
                minimumSize: WidgetStatePropertyAll<Size?>(
                  Size(0, effectiveHeight),
                ),
                fixedSize: WidgetStatePropertyAll<Size?>(
                  Size.fromHeight(effectiveHeight),
                ),
                textStyle: WidgetStatePropertyAll<TextStyle>(labelTextStyle),
                iconSize: WidgetStatePropertyAll<double>(iconSize),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                shape: WidgetStatePropertyAll<OutlinedBorder>(shape),
                minimumSize: WidgetStatePropertyAll<Size?>(
                  Size(0, effectiveHeight),
                ),
                fixedSize: WidgetStatePropertyAll<Size?>(
                  Size.fromHeight(effectiveHeight),
                ),
                textStyle: WidgetStatePropertyAll<TextStyle>(labelTextStyle),
                iconSize: WidgetStatePropertyAll<double>(iconSize),
              ),
            ),
          ),
          child: wrapped,
        );

        wrapped = ClipRRect(
          borderRadius: borderRadius,
          clipBehavior: Clip.antiAlias,
          child: wrapped,
        );
      } else {
        // Standard groups: apply size via themes so buttons match the group height.
        final theme = Theme.of(context);
        wrapped = Theme(
          data: theme.copyWith(
            visualDensity: effectiveVisualDensity ?? theme.visualDensity,
            iconButtonTheme: IconButtonThemeData(
              style: ButtonStyle(
                iconSize: WidgetStatePropertyAll<double>(iconSize),
                padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
                  EdgeInsets.zero,
                ),
                alignment: Alignment.center,
                minimumSize: WidgetStatePropertyAll<Size?>(Size.zero),
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: ButtonStyle(
                minimumSize: WidgetStatePropertyAll<Size?>(
                  Size(0, effectiveHeight),
                ),
                fixedSize: WidgetStatePropertyAll<Size?>(
                  Size.fromHeight(effectiveHeight),
                ),
                textStyle: WidgetStatePropertyAll<TextStyle>(labelTextStyle),
                iconSize: WidgetStatePropertyAll<double>(iconSize),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                minimumSize: WidgetStatePropertyAll<Size?>(
                  Size(0, effectiveHeight),
                ),
                fixedSize: WidgetStatePropertyAll<Size?>(
                  Size.fromHeight(effectiveHeight),
                ),
                textStyle: WidgetStatePropertyAll<TextStyle>(labelTextStyle),
                iconSize: WidgetStatePropertyAll<double>(iconSize),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: ButtonStyle(
                minimumSize: WidgetStatePropertyAll<Size?>(
                  Size(0, effectiveHeight),
                ),
                fixedSize: WidgetStatePropertyAll<Size?>(
                  Size.fromHeight(effectiveHeight),
                ),
                textStyle: WidgetStatePropertyAll<TextStyle>(labelTextStyle),
                iconSize: WidgetStatePropertyAll<double>(iconSize),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                minimumSize: WidgetStatePropertyAll<Size?>(
                  Size(0, effectiveHeight),
                ),
                fixedSize: WidgetStatePropertyAll<Size?>(
                  Size.fromHeight(effectiveHeight),
                ),
                textStyle: WidgetStatePropertyAll<TextStyle>(labelTextStyle),
                iconSize: WidgetStatePropertyAll<double>(iconSize),
              ),
            ),
          ),
          child: wrapped,
        );
      }
      children.add(wrapped);
      if (i < info.rowIndices.length - 1) {
        children.add(SizedBox(width: gap));
      }
    }
    // Add overflow button if needed.
    if (info.overflowIndices.isNotEmpty) {
      if (children.isNotEmpty) {
        children.add(SizedBox(width: gap));
      }
      // Build the "More" control and style it like a normal child segment.
      Widget more = _buildMoreButton(context, info.overflowIndices);
      if (widget.type == ButtonGroupType.connected) {
        final isFirst = info.rowIndices.isEmpty;
        final isLast = true;
        final outerRadius = widget.shape == GroupShape.round
            ? widget.size.containerHeight / 2
            : widget.size.squareOuterRadius;
        final innerRadius = widget.size.connectedInnerRadius;
        final borderRadius = isFirst && isLast
            ? BorderRadius.circular(outerRadius)
            : isFirst
            ? BorderRadius.only(
                topLeft: Radius.circular(outerRadius),
                bottomLeft: Radius.circular(outerRadius),
                topRight: Radius.circular(innerRadius),
                bottomRight: Radius.circular(innerRadius),
              )
            : BorderRadius.only(
                topLeft: Radius.circular(innerRadius),
                bottomLeft: Radius.circular(innerRadius),
                topRight: Radius.circular(outerRadius),
                bottomRight: Radius.circular(outerRadius),
              );
        final shape = RoundedRectangleBorder(borderRadius: borderRadius);
        final theme = Theme.of(context);
        more = Theme(
          data: theme.copyWith(
            visualDensity: effectiveVisualDensity ?? theme.visualDensity,
            iconButtonTheme: IconButtonThemeData(
              style: ButtonStyle(
                iconSize: WidgetStatePropertyAll<double>(iconSize),
                padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
                  EdgeInsets.zero,
                ),
                alignment: Alignment.center,
                minimumSize: WidgetStatePropertyAll<Size?>(Size.zero),
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: ButtonStyle(
                shape: WidgetStatePropertyAll<OutlinedBorder>(shape),
                minimumSize: WidgetStatePropertyAll<Size?>(
                  Size(0, effectiveHeight),
                ),
                fixedSize: WidgetStatePropertyAll<Size?>(
                  Size.fromHeight(effectiveHeight),
                ),
                textStyle: WidgetStatePropertyAll<TextStyle>(labelTextStyle),
                iconSize: WidgetStatePropertyAll<double>(iconSize),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                shape: WidgetStatePropertyAll<OutlinedBorder>(shape),
                minimumSize: WidgetStatePropertyAll<Size?>(
                  Size(0, effectiveHeight),
                ),
                fixedSize: WidgetStatePropertyAll<Size?>(
                  Size.fromHeight(effectiveHeight),
                ),
                textStyle: WidgetStatePropertyAll<TextStyle>(labelTextStyle),
                iconSize: WidgetStatePropertyAll<double>(iconSize),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: ButtonStyle(
                shape: WidgetStatePropertyAll<OutlinedBorder>(shape),
                minimumSize: WidgetStatePropertyAll<Size?>(
                  Size(0, effectiveHeight),
                ),
                fixedSize: WidgetStatePropertyAll<Size?>(
                  Size.fromHeight(effectiveHeight),
                ),
                textStyle: WidgetStatePropertyAll<TextStyle>(labelTextStyle),
                iconSize: WidgetStatePropertyAll<double>(iconSize),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                shape: WidgetStatePropertyAll<OutlinedBorder>(shape),
                minimumSize: WidgetStatePropertyAll<Size?>(
                  Size(0, effectiveHeight),
                ),
                fixedSize: WidgetStatePropertyAll<Size?>(
                  Size.fromHeight(effectiveHeight),
                ),
                textStyle: WidgetStatePropertyAll<TextStyle>(labelTextStyle),
                iconSize: WidgetStatePropertyAll<double>(iconSize),
              ),
            ),
          ),
          child: more,
        );
        more = ClipRRect(
          borderRadius: borderRadius,
          clipBehavior: Clip.antiAlias,
          child: more,
        );
      } else {
        final theme = Theme.of(context);
        more = Theme(
          data: theme.copyWith(
            visualDensity: effectiveVisualDensity ?? theme.visualDensity,
            iconButtonTheme: IconButtonThemeData(
              style: ButtonStyle(
                iconSize: WidgetStatePropertyAll<double>(iconSize),
                padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
                  EdgeInsets.zero,
                ),
                alignment: Alignment.center,
                minimumSize: WidgetStatePropertyAll<Size?>(Size.zero),
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: ButtonStyle(
                minimumSize: WidgetStatePropertyAll<Size?>(
                  Size(0, effectiveHeight),
                ),
                fixedSize: WidgetStatePropertyAll<Size?>(
                  Size.fromHeight(effectiveHeight),
                ),
                textStyle: WidgetStatePropertyAll<TextStyle>(labelTextStyle),
                iconSize: WidgetStatePropertyAll<double>(iconSize),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                minimumSize: WidgetStatePropertyAll<Size?>(
                  Size(0, effectiveHeight),
                ),
                fixedSize: WidgetStatePropertyAll<Size?>(
                  Size.fromHeight(effectiveHeight),
                ),
                textStyle: WidgetStatePropertyAll<TextStyle>(labelTextStyle),
                iconSize: WidgetStatePropertyAll<double>(iconSize),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: ButtonStyle(
                minimumSize: WidgetStatePropertyAll<Size?>(
                  Size(0, effectiveHeight),
                ),
                fixedSize: WidgetStatePropertyAll<Size?>(
                  Size.fromHeight(effectiveHeight),
                ),
                textStyle: WidgetStatePropertyAll<TextStyle>(labelTextStyle),
                iconSize: WidgetStatePropertyAll<double>(iconSize),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                minimumSize: WidgetStatePropertyAll<Size?>(
                  Size(0, effectiveHeight),
                ),
                fixedSize: WidgetStatePropertyAll<Size?>(
                  Size.fromHeight(effectiveHeight),
                ),
                textStyle: WidgetStatePropertyAll<TextStyle>(labelTextStyle),
                iconSize: WidgetStatePropertyAll<double>(iconSize),
              ),
            ),
          ),
          child: more,
        );
      }
      children.add(more);
    }
    // Determine outer shape and colour.
    final outerRadius = widget.shape == GroupShape.round
        ? widget.size.containerHeight / 2
        : widget.size.squareOuterRadius;
    final shape =
        widget.groupTheme?.containerShape ??
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(outerRadius),
        );
    final background = widget.groupTheme?.containerColor ?? Colors.transparent;
    Widget rowWidget = Padding(
      padding: widget.runPadding,
      child: Material(
        color: background,
        shape: shape,
        child: SizedBox(
          height: effectiveHeight,
          child: (() {
            final shouldScroll =
                _childWidths.length != widget.children.length ||
                _rowWouldOverflow(info);
            if (shouldScroll) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(mainAxisSize: MainAxisSize.min, children: children),
              );
            }
            return Row(mainAxisSize: MainAxisSize.min, children: children);
          })(),
        ),
      ),
    );

    if (effectiveVisualDensity != null) {
      final t = Theme.of(context);
      rowWidget = Theme(
        data: t.copyWith(visualDensity: effectiveVisualDensity),
        child: rowWidget,
      );
    }
    return rowWidget;
  }

  Widget? _findIconWidget(Widget? widget) {
    if (widget == null) return null;

    // Direct icon widgets
    if (widget is Icon) return Icon(widget.icon);
    if (widget is ImageIcon) return ImageIcon(widget.image);

    // Custom icon button used by this package
    if (widget is GroupIconButton) {
      final icon = widget.icon;
      if (icon is Icon) return Icon(icon.icon);
      if (icon is ImageIcon) return ImageIcon(icon.image);
      return icon;
    }

    // Standard IconButton
    if (widget is IconButton) {
      final icon = widget.icon;
      if (icon is Icon) return Icon(icon.icon);
      if (icon is ImageIcon) return ImageIcon(icon.image);
      return icon;
    }

    // SplitButton delegates to its primary child
    if (widget is SplitButton) {
      return _findIconWidget(widget.primaryChild);
    }

    // Common wrappers to traverse
    if (widget is Tooltip) {
      return _findIconWidget(widget.child);
    }
    if (widget is Semantics) {
      return _findIconWidget(widget.child);
    }

    // Material button families (Filled/Elevated/Outlined/Text)
    if (widget is ButtonStyleButton) {
      final child = widget.child;
      if (child != null) {
        final found = _findIconWidget(child);
        if (found != null) return found;
      }
      // Fallback: try to detect presence of an icon via debug string
      final iconFromString = _extractIconFromToString(widget);
      if (iconFromString != null) return iconFromString;
    }

    // Generic single/multi child traversal
    if (widget is SingleChildRenderObjectWidget) {
      return _findIconWidget(widget.child);
    }
    if (widget is MultiChildRenderObjectWidget) {
      for (final c in widget.children) {
        final found = _findIconWidget(c);
        if (found != null) return found;
      }
    }
    return null;
  }

  String? _findLabelInWidget(Widget? widget) {
    if (widget == null) return null;

    // Text and rich text cases
    if (widget is Text) {
      if (widget.data != null && widget.data!.trim().isNotEmpty) {
        return widget.data;
      }
      final span = widget.textSpan;
      if (span != null) {
        final plain = span.toPlainText();
        if (plain.trim().isNotEmpty) return plain;
      }
    }

    // Tooltip/Semantics can carry labels
    if (widget is GroupIconButton) {
      return widget.tooltip;
    }
    if (widget is IconButton) {
      return widget.tooltip;
    }
    if (widget is Tooltip) {
      final msg = widget.message;
      if (msg != null && msg.trim().isNotEmpty) return msg;
      return _findLabelInWidget(widget.child);
    }
    if (widget is Semantics) {
      // We don't reliably access Semantics.label across Flutter versions.
      // Traverse into the child instead.
      return _findLabelInWidget(widget.child);
    }

    // SplitButton delegates to its primary child
    if (widget is SplitButton) {
      return _findLabelInWidget(widget.primaryChild);
    }

    // Material button families (Filled/Elevated/Outlined/Text)
    if (widget is ButtonStyleButton) {
      final child = widget.child;
      final label = _findLabelInWidget(child);
      if (label != null && label.trim().isNotEmpty) return label;
      // If we still don't have a label, as a last resort parse the widget's
      // debug string for an embedded Text("...")
      final fromString = _extractLabelFromToString(widget);
      if (fromString != null && fromString.trim().isNotEmpty) return fromString;
    }

    // Generic single/multi child traversal
    if (widget is SingleChildRenderObjectWidget) {
      return _findLabelInWidget(widget.child);
    }
    if (widget is MultiChildRenderObjectWidget) {
      for (final c in widget.children) {
        final found = _findLabelInWidget(c);
        if (found != null) return found;
      }
    }

    // Last resort: attempt to parse a Text label from the widget's debug string
    final parsed = _extractLabelFromToString(widget);
    if (parsed != null && parsed.trim().isNotEmpty) return parsed;

    return null;
  }

  // Attempts to pull a user-visible label out of a widget's debug string.
  // This is a best-effort fallback for cases where icon constructors build
  // their internal Row(label+icon) without exposing it via the `child` field.
  String? _extractLabelFromToString(Widget widget) {
    try {
      final s = widget.toStringDeep();
      // Match Text("...")
      final m1 = RegExp(r'Text\(\"([^\"]+)\"').firstMatch(s);
      if (m1 != null) return m1.group(1);
      // Or Text('...')
      final m2 = RegExp(r"Text\('\s*([^']+?)\s*'\)").firstMatch(s);
      if (m2 != null) return m2.group(1);
      // Or text: "..."
      final m3 = RegExp(r'text:\s*\"([^\"]+)\"').firstMatch(s);
      if (m3 != null) return m3.group(1);
    } catch (_) {
      // ignore
    }
    return null;
  }

  // Best-effort detection of an icon presence from a widget's debug string.
  // We cannot map string -> IconData reliably, so we return a neutral circle
  // to avoid empty leading space in the menu when an icon likely exists.
  Widget? _extractIconFromToString(Widget widget) {
    try {
      final s = widget.toStringDeep();
      if (s.contains('Icon(')) {
        return const Icon(Icons.circle);
      }
    } catch (_) {
      // ignore
    }
    return null;
  }

  Widget _buildMoreButton(BuildContext context, List<int> overflowIndices) {
    // Default "More" control: looks like a normal enabled button but
    // lets PopupMenuButton handle the tap via AbsorbPointer.
    final defaultMoreButton = AbsorbPointer(
      absorbing: true,
      child: FilledButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.more_horiz),
        label: const Text('More'),
      ),
    );
    final button = widget.moreBuilder?.call(context) ?? defaultMoreButton;

    return PopupMenuButton<int>(
      tooltip: 'More',
      itemBuilder: (popupContext) {
        final entries = <PopupMenuEntry<int>>[];
        for (final index in overflowIndices) {
          final child = widget.children[index];

          Widget? iconWidget;
          String? label;

          if (child is GroupIconButton) {
            iconWidget = _findIconWidget(child);
            label = child.tooltip;
          } else if (child is IconButton) {
            iconWidget = _findIconWidget(child);
            label = child.tooltip;
          } else if (child is SplitButton) {
            iconWidget = _findIconWidget(child.primaryChild);
            label = _findLabelInWidget(child.primaryChild);
          } else if (child is ButtonStyleButton) {
            // Pass the button itself to allow internal/icon constructors to be handled
            // by our extraction helpers (including toStringDeep fallback).
            iconWidget = _findIconWidget(child);
            label = _findLabelInWidget(child);
          } else {
            iconWidget = _findIconWidget(child);
            label = _findLabelInWidget(child);
          }

          // If both are missing, fall back to a generic label.
          if (iconWidget == null && label == null) {
            label = 'Item ${index + 1}';
          }

          final rowChildren = <Widget>[];
          if (iconWidget != null) {
            rowChildren.add(
              IconTheme.merge(
                data: const IconThemeData(size: 20),
                child: iconWidget,
              ),
            );
            if (label != null) {
              rowChildren.add(const SizedBox(width: 8));
            }
          }
          if (label != null) {
            rowChildren.add(Flexible(child: Text(label)));
          }

          entries.add(
            PopupMenuItem<int>(
              value: index,
              child: Row(mainAxisSize: MainAxisSize.min, children: rowChildren),
            ),
          );
        }
        return entries;
      },
      onSelected: (index) {
        final child = widget.children[index];
        // Forward the press to the original button if possible.
        if (child is IconButton) {
          child.onPressed?.call();
        } else if (child is ButtonStyleButton) {
          child.onPressed?.call();
        }
      },
      position: PopupMenuPosition.under,
      child: button,
    );
  }
}

/// Private data structure that describes a row of items in the group.

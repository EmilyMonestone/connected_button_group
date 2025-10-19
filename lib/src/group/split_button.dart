import 'package:flutter/material.dart';

import '../menu/menu_entry.dart';
import 'group_shape.dart';
import 'group_size.dart';

/// The visual style of the trailing menu button in a [SplitButton].
/// If not provided, an attempt will be made to infer the style from
/// the [primaryChild] type.
enum SplitButtonStyle { elevated, filled, tonal, outlined }

/// A button that combines a primary action with a trailing chevron that
/// opens a menu of secondary actions. Implements sizing, spacing, and
/// stateful icon behavior per the Material 3 Expressive split button
/// guidance. The leading (primary) portion is provided by the caller; the
/// trailing portion is rendered to match the chosen [SplitButtonStyle].
class SplitButton extends StatefulWidget {
  /// Creates a split button.
  const SplitButton({
    super.key,
    required this.primaryChild,
    required this.menuEntries,
    this.onPrimaryPressed,
    this.size = GroupSize.s,
    this.shape = GroupShape.round,
    this.style,
    this.menuAlignment = AlignmentDirectional.bottomEnd,
    this.outerOnLeadingEdge = true,
    this.outerOnTrailingEdge = true,
  });

  /// The child used as the primary button. This should itself be a
  /// [ButtonStyleButton] such as [FilledButton], [ElevatedButton],
  /// [OutlinedButton], or [TextButton]. If it is not already configured
  /// with an [Icon], consider including one to better differentiate it
  /// from the chevron.
  final Widget primaryChild;

  /// The list of menu entries to display in the split button’s menu.
  final List<MenuEntry> menuEntries;

  /// Called when the primary button portion is pressed.
  final VoidCallback? onPrimaryPressed;

  /// Size ramp (XS, S, M, L, XL). Defaults to small per M3 guidance.
  final GroupSize size;

  /// Outer shape for the split container (round or square).
  final GroupShape shape;

  /// Visual style for the trailing button (elevated, filled, tonal, outlined).
  final SplitButtonStyle? style;

  /// Alignment for the popup menu anchor (kept for backward compatibility).
  final AlignmentGeometry menuAlignment;

  /// Whether the outer corner on the leading edge (start side) of the split
  /// should use the outer radius of the group (true) or the connected inner
  /// radius (false). Defaults to true for standalone usage. When placed inside
  /// a connected ButtonGroup, this will be set based on position.
  final bool outerOnLeadingEdge;

  /// Whether the outer corner on the trailing edge (end side) of the split
  /// should use the outer radius (true) or the connected inner radius (false).
  /// Defaults to true for standalone usage. When placed inside a ButtonGroup,
  /// this will be set based on position.
  final bool outerOnTrailingEdge;

  @override
  State<SplitButton> createState() => _SplitButtonState();
}

class _SplitButtonState extends State<SplitButton> {
  final GlobalKey _trailingKey = GlobalKey();
  bool _menuOpen = false;
  bool _hoverLeading = false;
  bool _hoverTrailing = false;

  // Token maps per size
  double get _height => widget.size.containerHeight;
  static const double _gap = 2; // 2dp between buttons

  // Inner corner radii follow GroupSize tokens used for connected groups.
  double get _innerRadiusBase => widget.size.connectedInnerRadius;

  // Icon size per size (use GroupSize tokens to match Material buttons)
  double get _iconSize => widget.size.iconSize;

  // Effective height that respects Theme.visualDensity.
  double _effectiveHeight(BuildContext context) {
    final density = Theme.of(context).visualDensity;
    final h = _height + density.baseSizeAdjustment.dy;
    return h < 0 ? 0 : h;
  }

  // Effective trailing padding that respects Theme.visualDensity width.
  EdgeInsets _effectiveTrailingPadding(BuildContext context) {
    final density = Theme.of(context).visualDensity;
    final dx = density.baseSizeAdjustment.dx;
    final base = _trailingPadding;
    final val = base.left + dx / 2;
    final hPad = val < 0 ? 0.0 : val;
    return EdgeInsets.symmetric(horizontal: hPad);
  }

  // Padding for trailing button per size
  EdgeInsets get _trailingPadding {
    switch (widget.size) {
      case GroupSize.xs:
      case GroupSize.s:
        return const EdgeInsets.symmetric(horizontal: 13);
      case GroupSize.m:
        return const EdgeInsets.symmetric(horizontal: 15);
      case GroupSize.l:
        return const EdgeInsets.symmetric(horizontal: 29);
      case GroupSize.xl:
        return const EdgeInsets.symmetric(horizontal: 43);
    }
  }

  // Optical icon offset when unselected (negative = towards inner edge in LTR)
  double get _iconOffsetX {
    // Center the trailing chevron horizontally; previously we applied a
    // size-dependent optical shift which caused visible off-centering.
    // Returning 0 ensures the icon remains centered within its segment
    // across sizes and densities.
    return 0;
  }

  SplitButtonStyle _inferStyle() {
    final child = widget.primaryChild;
    if (child is FilledButton) return SplitButtonStyle.filled;
    // FilledButton.tonal is a factory on FilledButton; we cannot detect directly
    // so allow user to pass [style] when needed.
    if (child is ElevatedButton) return SplitButtonStyle.elevated;
    if (child is OutlinedButton) return SplitButtonStyle.outlined;
    return SplitButtonStyle.filled;
  }

  OutlinedBorder _segmentShape({
    required bool trailing,
    required Set<MaterialState> states,
  }) {
    final textDir = Directionality.of(context);
    final isRtl = textDir == TextDirection.rtl;
    final outerRadius = widget.shape == GroupShape.round
        ? Radius.circular(widget.size.containerHeight / 2)
        : Radius.circular(widget.size.squareOuterRadius);

    // Inner radius morph: hover/focus/pressed => slightly larger; menu open => 50%
    final anyInteractive =
        states.contains(MaterialState.hovered) ||
        states.contains(MaterialState.pressed) ||
        states.contains(MaterialState.focused);

    double inner = _innerRadiusBase + (anyInteractive ? 2 : 0);
    if (_menuOpen && trailing) {
      final effH = _effectiveHeight(context);
      inner = effH / 2; // 50%
    }

    final innerRadius = Radius.circular(inner);

    BorderRadius borderRadius;
    final useOuterLeading = widget.outerOnLeadingEdge;
    final useOuterTrailing = widget.outerOnTrailingEdge;

    if (trailing) {
      // Trailing segment: inner on leading edge (split seam), configurable on trailing edge.
      if (!isRtl) {
        borderRadius = BorderRadius.only(
          topLeft: innerRadius,
          bottomLeft: innerRadius,
          topRight: useOuterTrailing ? outerRadius : innerRadius,
          bottomRight: useOuterTrailing ? outerRadius : innerRadius,
        );
      } else {
        borderRadius = BorderRadius.only(
          topLeft: useOuterTrailing ? outerRadius : innerRadius,
          bottomLeft: useOuterTrailing ? outerRadius : innerRadius,
          topRight: innerRadius,
          bottomRight: innerRadius,
        );
      }
    } else {
      // Leading segment: configurable on leading edge, inner on trailing edge (split seam).
      if (!isRtl) {
        borderRadius = BorderRadius.only(
          topLeft: useOuterLeading ? outerRadius : innerRadius,
          bottomLeft: useOuterLeading ? outerRadius : innerRadius,
          topRight: innerRadius,
          bottomRight: innerRadius,
        );
      } else {
        borderRadius = BorderRadius.only(
          topLeft: innerRadius,
          bottomLeft: innerRadius,
          topRight: useOuterLeading ? outerRadius : innerRadius,
          bottomRight: useOuterLeading ? outerRadius : innerRadius,
        );
      }
    }

    return RoundedRectangleBorder(borderRadius: borderRadius);
  }

  ButtonStyle _trailingButtonStyle(SplitButtonStyle style) {
    final MaterialStateProperty<OutlinedBorder?> shapeProp =
        MaterialStateProperty.all<OutlinedBorder>(
          _segmentShape(trailing: true, states: const {}),
        );
    final EdgeInsets effPadding = _effectiveTrailingPadding(context);
    final double effHeight = _effectiveHeight(context);
    final MaterialStateProperty<EdgeInsetsGeometry?> paddingProp =
        MaterialStateProperty.all<EdgeInsetsGeometry>(effPadding);
    final MaterialStateProperty<Size?> minSize =
        MaterialStateProperty.all<Size>(Size(0, effHeight));

    ButtonStyle raw;
    ButtonStyle? base;
    final theme = Theme.of(context);

    switch (style) {
      case SplitButtonStyle.elevated:
        raw =
            ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
            ).copyWith(
              shape: shapeProp,
              padding: paddingProp,
              minimumSize: minSize,
              fixedSize: MaterialStateProperty.all(Size.fromHeight(effHeight)),
            );
        base = theme.elevatedButtonTheme.style;
        break;
      case SplitButtonStyle.filled:
        raw =
            FilledButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
            ).copyWith(
              shape: shapeProp,
              padding: paddingProp,
              minimumSize: minSize,
              fixedSize: MaterialStateProperty.all(Size.fromHeight(effHeight)),
            );
        base = theme.filledButtonTheme.style;
        break;
      case SplitButtonStyle.tonal:
        raw = ButtonStyle(
          shape: shapeProp,
          padding: paddingProp,
          minimumSize: minSize,
          fixedSize: MaterialStateProperty.all(Size.fromHeight(effHeight)),
        );
        base = theme.filledButtonTheme.style;
        break;
      case SplitButtonStyle.outlined:
        raw =
            OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
            ).copyWith(
              shape: shapeProp,
              padding: paddingProp,
              minimumSize: minSize,
              fixedSize: MaterialStateProperty.all(Size.fromHeight(effHeight)),
            );
        base = theme.outlinedButtonTheme.style;
        break;
    }
    return base?.merge(raw) ?? raw;
  }

  Future<void> _showTrailingMenu() async {
    final renderObject = _trailingKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final box = renderObject;
    final offset = box.localToGlobal(Offset.zero, ancestor: overlay);
    final rect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      box.size.width,
      box.size.height,
    );
    setState(() => _menuOpen = true);
    final selected = await showMenu<MenuEntry>(
      context: context,
      position: RelativeRect.fromRect(
        rect.translate(0, box.size.height + 4), // 4dp below the split button
        Offset.zero & overlay.size,
      ),
      items: [
        for (final entry in widget.menuEntries)
          PopupMenuItem<MenuEntry>(
            value: entry,
            child: Row(
              children: [
                if (entry.icon != null) ...[
                  Icon(entry.icon as IconData?, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(entry.label),
              ],
            ),
          ),
      ],
    );
    if (mounted) setState(() => _menuOpen = false);
    selected?.onSelected?.call();
  }

  @override
  Widget build(BuildContext context) {
    final textDir = Directionality.of(context);
    final isRtl = textDir == TextDirection.rtl;
    final style = widget.style ?? _inferStyle();

    // Leading segment wrapper to apply size and inner corner clipping.
    EdgeInsetsGeometry _leadingPadding(TextDirection dir) {
      // Leading button spaces per spec (leading/trailing):
      // XS: 12/10, S: 16/12, M: 24/24, L: 48/48, XL: 64/64
      double leadingSpace;
      double trailingSpace;
      switch (widget.size) {
        case GroupSize.xs:
          leadingSpace = 12;
          trailingSpace = 10;
          break;
        case GroupSize.s:
          leadingSpace = 16;
          trailingSpace = 12;
          break;
        case GroupSize.m:
          leadingSpace = 24;
          trailingSpace = 24;
          break;
        case GroupSize.l:
          leadingSpace = 48;
          trailingSpace = 48;
          break;
        case GroupSize.xl:
          leadingSpace = 64;
          trailingSpace = 64;
          break;
      }
      // Apply VisualDensity width adjustment evenly to both sides
      final dx = Theme.of(context).visualDensity.baseSizeAdjustment.dx;
      final add = dx / 2;
      leadingSpace = (leadingSpace + add);
      trailingSpace = (trailingSpace + add);
      if (leadingSpace < 0) leadingSpace = 0;
      if (trailingSpace < 0) trailingSpace = 0;
      return dir == TextDirection.rtl
          ? EdgeInsetsDirectional.only(start: trailingSpace, end: leadingSpace)
          : EdgeInsetsDirectional.only(start: leadingSpace, end: trailingSpace);
    }

    ButtonStyle _leadingButtonStyle(TextDirection dir) {
      final double effHeight = _effectiveHeight(context);
      return ButtonStyle(
        shape: MaterialStateProperty.all(
          _segmentShape(trailing: false, states: const {}),
        ),
        padding: MaterialStateProperty.all(_leadingPadding(dir)),
        minimumSize: MaterialStateProperty.all(Size(0, effHeight)),
        fixedSize: MaterialStateProperty.all(Size.fromHeight(effHeight)),
      );
    }

    Widget _applyLeadingTheme(
      Widget child,
      SplitButtonStyle s,
      TextDirection dir,
    ) {
      final style = _leadingButtonStyle(dir);
      switch (s) {
        case SplitButtonStyle.elevated:
          return ElevatedButtonTheme(
            data: ElevatedButtonThemeData(style: style),
            child: child,
          );
        case SplitButtonStyle.filled:
          return FilledButtonTheme(
            data: FilledButtonThemeData(style: style),
            child: child,
          );
        case SplitButtonStyle.tonal:
          return FilledButtonTheme(
            data: FilledButtonThemeData(style: style),
            child: child,
          );
        case SplitButtonStyle.outlined:
          return OutlinedButtonTheme(
            data: OutlinedButtonThemeData(style: style),
            child: child,
          );
      }
    }

    final leading = MouseRegion(
      onEnter: (_) => setState(() => _hoverLeading = true),
      onExit: (_) => setState(() => _hoverLeading = false),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: _effectiveHeight(context),
          maxHeight: _effectiveHeight(context),
        ),
        child: Material(
          type: MaterialType.transparency,
          shape: _segmentShape(
            trailing: false,
            states: _hoverLeading ? {MaterialState.hovered} : const {},
          ),
          clipBehavior: Clip.antiAlias,
          child: _applyLeadingTheme(
            widget.onPrimaryPressed != null
                ? InkWell(
                    onTap: widget.onPrimaryPressed,
                    customBorder: _segmentShape(
                      trailing: false,
                      states: _hoverLeading
                          ? {MaterialState.hovered}
                          : const {},
                    ),
                    child: widget.primaryChild,
                  )
                : widget.primaryChild,
            style,
            textDir,
          ),
        ),
      ),
    );

    // Trailing segment as a real Material button to match style.
    final trailingButton = Builder(
      builder: (context) {
        final buttonChild = AnimatedRotation(
          duration: const Duration(milliseconds: 200),
          turns: _menuOpen ? 0.5 : 0.0, // rotate 180° when open
          child: Transform.translate(
            offset: _menuOpen
                ? Offset.zero
                : Offset((isRtl ? -1 : 1) * _iconOffsetX, 0),
            child: Icon(Icons.expand_more, size: _iconSize),
          ),
        );

        final onPressed = () => _showTrailingMenu();

        switch (style) {
          case SplitButtonStyle.elevated:
            return ElevatedButton(
              key: _trailingKey,
              onPressed: onPressed,
              style: _trailingButtonStyle(style),
              child: buttonChild,
            );
          case SplitButtonStyle.filled:
            return FilledButton(
              key: _trailingKey,
              onPressed: onPressed,
              style: _trailingButtonStyle(style),
              child: buttonChild,
            );
          case SplitButtonStyle.tonal:
            return FilledButton.tonal(
              key: _trailingKey,
              onPressed: onPressed,
              style: _trailingButtonStyle(style),
              child: buttonChild,
            );
          case SplitButtonStyle.outlined:
            return OutlinedButton(
              key: _trailingKey,
              onPressed: onPressed,
              style: _trailingButtonStyle(style),
              child: buttonChild,
            );
        }
      },
    );

    return Directionality(
      textDirection: textDir,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: leading),
          const SizedBox(width: _gap),
          trailingButton,
        ],
      ),
    );
  }
}

part of 'connected_button_group.dart';

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
      mainAxisAlignment: hasLabel
          ? MainAxisAlignment.center
          : MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasIcon) Icon(item.icon, size: 24.0, color: contentColor),
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

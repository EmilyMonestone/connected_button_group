part of 'connected_button_group.dart';

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
  final void Function((T itemValue, ConnectedMenuEntry<T> entry) selection)?
  onMenuItemSelected;
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

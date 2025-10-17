part of 'connected_button_group.dart';

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

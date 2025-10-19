// ignore_for_file: public_member_api_docs

/// Internal data structure that describes a row of items in a button group.
///
/// The [ButtonGroup] packs its children into one or more rows based on
/// available width and the selected [OverflowStrategy].  Each row is
/// represented by a [RowInfo] which lists the indices of the children that
/// appear on that row and, optionally, a list of indices that should be
/// collapsed into an overflow menu on that row.  This class is internal
/// and not exported from the package API.
class RowInfo {
  /// Creates a new [RowInfo] with the given child indices.
  const RowInfo({required this.rowIndices, this.overflowIndices = const []});

  /// The indices of the children that appear on this row.
  final List<int> rowIndices;

  /// The indices of the children that are collapsed into the overflow menu.
  /// This list is empty when no overflow occurs on the row.
  final List<int> overflowIndices;

  /// Returns a copy of this [RowInfo] with the provided fields replaced.
  RowInfo copyWith({List<int>? rowIndices, List<int>? overflowIndices}) {
    return RowInfo(
      rowIndices: rowIndices ?? this.rowIndices,
      overflowIndices: overflowIndices ?? this.overflowIndices,
    );
  }
}
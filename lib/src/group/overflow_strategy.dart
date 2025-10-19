/// Defines how a [ButtonGroup] deals with horizontal overflow.
///
/// See the Material button group guidance for recommendations on when to
/// collapse trailing items into a menu versus wrapping to multiple lines.
///
/// Simplified to two strategies:
/// - [OverflowStrategy.menu] (default): Keep a single visible row by collapsing
///   trailing items into a “More” menu. If even the first item and the overflow
///   control cannot fit, fall back to wrapping.
/// - [OverflowStrategy.wrap]: Greedy wrapping across multiple rows; when
///   [ButtonGroup.maxLines] is reached, collapse the remainder of that row into
///   a “More” menu.
enum OverflowStrategy {
  /// Always collapse overflow into a menu on a single row. If even the
  /// first item and the overflow button cannot fit, the group will wrap
  /// instead. This strategy is the default used by [ButtonGroup].
  menu,

  /// First attempt to wrap items to new rows; if the final allowed row still
  /// has remaining items (due to [ButtonGroup.maxLines]), collapse those
  /// trailing items on that row into a menu.
  wrap,
}

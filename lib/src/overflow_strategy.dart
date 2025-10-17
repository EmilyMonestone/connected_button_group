/// Overflow strategies supported by [ConnectedButtonGroup].
///
/// A connected button group can choose how to handle items that do not fit
/// within a single row.  The default [`menuThenWrap`] strategy first
/// collapses trailing items into an overflow menu and, if the items still
/// cannot fit, allows the remaining items to wrap onto additional rows.

enum ConnectedOverflowStrategy {
  /// Never use an overflow menu; if a row overflows, it will simply wrap
  /// onto the next line (up to [ConnectedButtonGroup.maxLines]).
  none,

  /// Always enforce a single row when possible.  When a row would
  /// overflow, the trailing items are collapsed into an overflow menu
  /// represented by a special "More" item.  If even a single item plus
  /// the overflow handle does not fit, the group falls back to wrapping.
  menu,

  /// First attempt to collapse trailing items into an overflow menu; if
  /// collapsing still does not reduce the row enough to fit, start a new
  /// row.  This is the default behaviour since it keeps most items visible
  /// while avoiding horizontal scrolling.
  menuThenWrap,

  /// Try to wrap items onto new rows before resorting to an overflow menu.
  /// If a row still cannot fit all of its assigned items, the trailing
  /// items of that row are collapsed into an overflow menu.
  wrapThenMenu,
}
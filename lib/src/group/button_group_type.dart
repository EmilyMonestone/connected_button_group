/// Defines the visual style used by [ButtonGroup].
///
/// * [ButtonGroupType.connected] lays out its children in a continuous
///   pill‑shaped or square container (depending on [GroupShape]).  Spacing
///   between buttons is fixed at 2dp regardless of the size ramp.  Pressing
///   one button does not affect the neighbours.
/// * [ButtonGroupType.standard] lays out its children with a size‑dependent
///   gap between them.  When a button is pressed the width of that button
///   subtly compresses or expands while its immediate neighbours reflow
///   slightly to produce a micro‑interaction.  See the Material 3 specs for
///   guidance on these behaviours.
enum ButtonGroupType {
  /// A connected group renders its children inside a single continuous
  /// container.  Spacing between buttons is minimal and constant across
  /// sizes.  Only the pressed button’s shape changes when interacted with.
  connected,

  /// A standard group applies a larger gap between items and introduces a
  /// subtle reflow effect on press.  This is often used to group related
  /// actions in toolbars or cards where the group does not need to appear
  /// as one continuous pill.
  standard,
}

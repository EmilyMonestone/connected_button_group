/// Defines the outer shape of the [ButtonGroup].
///
/// * [GroupShape.round] renders the group with fully rounded
///   stadium‑like ends.  When combined with [ButtonGroupType.connected] this
///   results in a continuous pill.  When combined with
///   [ButtonGroupType.standard] each row is still wrapped in the same
///   fully rounded container.
/// * [GroupShape.square] renders the group with square corners whose
///   radii depend on the selected [GroupSize].  See [GroupSize.squareOuterRadius]
///   for the per‑size values.  This shape aligns with the square button
///   group tokens in the Material design specifications.
enum GroupShape {
  /// Fully rounded outer corners.
  round,

  /// Square outer corners whose radius increases with size.
  square,
}
/// Defines the size ramp used by [ButtonGroup].
///
/// These values correspond to the Material 3 size ramps used for button
/// groups.  The heights and intragap spacing for both the standard and
/// connected variants are documented in the Material design
/// specifications and can be looked up via the `ButtonGroupMetrics`
/// extension.
enum GroupSize {
  /// Extra small.
  xs,

  /// Small.
  s,

  /// Medium (default).
  m,

  /// Large.
  l,

  /// Extra large.
  xl,
}

/// Extension on [GroupSize] that exposes constant metrics derived from the
/// Material design specifications.  These values are used internally by
/// [ButtonGroup] to size and space its children.
extension ButtonGroupMetrics on GroupSize {
  /// Returns the container height for the given [GroupSize] in logical
  /// pixels.  Both the standard and connected variants use the same
  /// container heights.
  double get containerHeight {
    switch (this) {
      case GroupSize.xs:
        return 32;
      case GroupSize.s:
        return 40;
      case GroupSize.m:
        return 56;
      case GroupSize.l:
        return 96;
      case GroupSize.xl:
        return 136;
    }
  }

  /// Returns the intragap spacing between buttons for the standard
  /// variant.  The connected variant always uses 2dp of spacing.
  double get standardGap {
    switch (this) {
      case GroupSize.xs:
        return 18;
      case GroupSize.s:
        return 12;
      case GroupSize.m:
        return 8;
      case GroupSize.l:
        return 8;
      case GroupSize.xl:
        return 8;
    }
  }

  /// Returns the inner corner radius applied to individual buttons inside
  /// a connected group.  See the Material design tokens for more detail.
  double get connectedInnerRadius {
    switch (this) {
      case GroupSize.xs:
        return 4;
      case GroupSize.s:
        return 8;
      case GroupSize.m:
        return 8;
      case GroupSize.l:
        return 16;
      case GroupSize.xl:
        return 20;
    }
  }

  /// Returns the base outer radius used when the [GroupShape] is set to
  /// [GroupShape.square].  This matches the inner radius values defined
  /// above so that square button groups still have slightly rounded outer
  /// corners at larger sizes.
  double get squareOuterRadius => connectedInnerRadius;

  /// Returns the default icon size for the given [GroupSize] in dp.
  double get iconSize {
    switch (this) {
      case GroupSize.xs:
        return 20;
      case GroupSize.s:
        return 20;
      case GroupSize.m:
        return 24;
      case GroupSize.l:
        return 32;
      case GroupSize.xl:
        return 40;
    }
  }

  /// Returns the default label text font size in sp for the [GroupSize].
  /// XS and S keep the typical 14sp label; larger sizes scale up.
  double get labelFontSize {
    switch (this) {
      case GroupSize.xs:
        return 14;
      case GroupSize.s:
        return 14;
      case GroupSize.m:
        return 16;
      case GroupSize.l:
        return 20;
      case GroupSize.xl:
        return 24;
    }
  }
}

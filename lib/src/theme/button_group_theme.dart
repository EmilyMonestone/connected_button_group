import 'dart:ui';

import 'package:flutter/material.dart';

/// A theme configuration for [ButtonGroup].
///
/// A [ButtonGroupThemeData] can be provided via [ThemeExtension] to
/// override default shape, spacing and colours.  Only the properties that
/// are non‑null will override the corresponding default values.
@immutable
class ButtonGroupThemeData extends ThemeExtension<ButtonGroupThemeData> {
  /// Creates a [ButtonGroupThemeData].
  const ButtonGroupThemeData({
    this.containerShape,
    this.intraGap,
    this.containerColor,
    this.dividerColor,
    this.pressImpulseDuration,
    this.pressImpulseCurve,
    this.visualDensity,
  });

  /// Overrides the outer shape of the button group container.  When null,
  /// the group will use a [StadiumBorder] for round shapes or a
  /// [RoundedRectangleBorder] with a radius derived from the current
  /// [GroupSize] for square shapes.
  final ShapeBorder? containerShape;

  /// Overrides the spacing between buttons.  The default depends on the
  /// [ButtonGroupType] and [GroupSize].
  final double? intraGap;

  /// The background colour of the group container.  When null the
  /// underlying [ButtonGroup] will not paint a container; instead it will
  /// rely on each child button’s own background.
  final Color? containerColor;

  /// The colour of the divider lines drawn between items in a connected
  /// group.  When null, no dividers are drawn.
  final Color? dividerColor;

  /// The duration of the micro‑reflow impulse used by the standard group
  /// variant when a button is pressed.  This animation scales the width
  /// of the pressed button and its neighbours by a small multiplier.
  final Duration? pressImpulseDuration;

  /// The easing curve of the micro‑reflow impulse.  Defaults to
  /// [Curves.fastOutSlowIn].
  final Curve? pressImpulseCurve;

  /// Overrides Material's visual density for controls within a ButtonGroup.
  /// When provided, the group will wrap its children in a Theme with this
  /// [VisualDensity] so that inner buttons adapt their tap target size and
  /// layout consistent with the density.
  final VisualDensity? visualDensity;

  @override
  ButtonGroupThemeData copyWith({
    ShapeBorder? containerShape,
    double? intraGap,
    Color? containerColor,
    Color? dividerColor,
    Duration? pressImpulseDuration,
    Curve? pressImpulseCurve,
    VisualDensity? visualDensity,
  }) {
    return ButtonGroupThemeData(
      containerShape: containerShape ?? this.containerShape,
      intraGap: intraGap ?? this.intraGap,
      containerColor: containerColor ?? this.containerColor,
      dividerColor: dividerColor ?? this.dividerColor,
      pressImpulseDuration: pressImpulseDuration ?? this.pressImpulseDuration,
      pressImpulseCurve: pressImpulseCurve ?? this.pressImpulseCurve,
      visualDensity: visualDensity ?? this.visualDensity,
    );
  }

  @override
  ButtonGroupThemeData lerp(
    ThemeExtension<ButtonGroupThemeData>? other,
    double t,
  ) {
    if (other is! ButtonGroupThemeData) return this;
    return ButtonGroupThemeData(
      containerShape: t < 0.5 ? containerShape : other.containerShape,
      intraGap: lerpDouble(intraGap, other.intraGap, t),
      containerColor: Color.lerp(containerColor, other.containerColor, t),
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t),
      pressImpulseDuration: t < 0.5
          ? pressImpulseDuration
          : other.pressImpulseDuration,
      pressImpulseCurve: t < 0.5 ? pressImpulseCurve : other.pressImpulseCurve,
      visualDensity: t < 0.5 ? visualDensity : other.visualDensity,
    );
  }
}

## 0.1.1
- ButtonGroupType.connected: enforce 2dp inner gap and token-aligned inner radii for segment corners (XS: 4, S: 8, M: 8, L: 16, XL: 20).
- For round groups, outer corners remain fully rounded (height/2); inner segment corners use the per-size radii.
- For square groups, outer corners use the same per-size radii.
- Additionally, connected groups now override child ButtonStyleButtons' shapes via local themes to prevent StadiumBorder from making inner seams fully rounded. SplitButton is excluded to preserve its own segment shapes.

- Also apply connected-group segment shape enforcement and visual density to SplitButton children so they match adjacent segments; SplitButton’s internal styles continue to override where appropriate.

- SplitButton inside a ButtonGroup now automatically inherits the group’s size and shape so its rounding and height match neighbouring segments (fixes inner/outer corner mismatches).
- Fix: SplitButton placed inside a connected ButtonGroup now uses inner radii on its external edges when in the middle of a group (and outer radii only on the group’s outermost edges). Implemented via new parameters outerOnLeadingEdge/outerOnTrailingEdge controlled by ButtonGroup based on position. Ensures seams between Create/Edit/Export/Share use the token inner radius (e.g., 8dp for M) instead of appearing fully rounded.
- Standard round groups: When ButtonGroupType.standard and GroupShape.round, SplitButton now keeps fully rounded left and right edges regardless of position in the row (outerOnLeadingEdge/outerOnTrailingEdge forced to true). This matches expectations for non-connected groups.
- Center the trailing chevron in SplitButton: removed size-dependent horizontal offset so the arrow is visually centered across sizes, densities and directions.

- Connected groups with overflow menu: the last visible button before the overflow menu no longer gets a fully rounded trailing edge. It now uses the token inner radius on its trailing edge, since the menu button follows it, ensuring a correct inner seam between the button and the menu segment.
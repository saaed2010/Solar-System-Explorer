# STEP 2 visual audit

Baseline inspected before editing on the `step-2-final-polish` branch.

## Viewports reviewed

- 320 × 740
- 360 × 740
- 390 × 844
- 768 × 1024
- 1440 × 900

## Confirmed issues

1. Opening size comparison from a details page rendered Material ancestor errors because the pushed comparison route had no `Scaffold`.
2. Wide layouts stretched the comparison laboratory and bottom navigation across the entire desktop viewport, weakening hierarchy and grouping.
3. The featured Betelgeuse action said “Open true scale” but opened the details page instead.
4. Solar-system focus dimmed other bodies, but its scale-only feedback did not create a convincing camera movement.
5. Planet surfaces were clear and consistent but some terrestrial bodies and stars read as simple gradients at large detail sizes.
6. Reduced-motion mode correctly stopped continuous animation, but the status label read only “Paused” and did not explain why controls were disabled.
7. Existing tests covered one compact viewport but not the 320 px edge case, larger layouts, extreme ratios, details-to-comparison navigation, or reduced motion.

## Baseline quality retained

- True-scale comparison math uses one shared linear scale.
- Readable mode is explicitly marked as not to scale.
- Search, category filters, details content, navigation, and motion controls are functional.
- Procedural rendering is performant and visually consistent enough to refine in place.
- No analyzer issues and all 14 baseline tests pass.

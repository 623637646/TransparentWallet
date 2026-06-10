## Context

Currently, the application manages the active screen by rebuilding the home widget of a single `MaterialApp` based on the active `AppMode` state. However:
1. When pages like `SettingsScreen` are pushed onto the routing stack, they overlay the root route. Even when the root route changes to `OnboardingScreen` after a wallet reset, the settings screen remains on top, blocking the UI.
2. Switching from light-themed hot wallet to dark-themed onboarding (and vice versa) causes instant color flashing across components.

To resolve these, we will wrap the application in a top-level `Stack` managing two separate `MaterialApp` instances during app mode transitions, running a circular clip reveal.

## Goals / Non-Goals

**Goals:**
- **Automatic Navigation Cleanup**: The old navigation stack (and any pushed routes) must be completely disposed of when resetting the app without setting-specific Navigator pop calls.
- **Symmetrical Radial Reveal Transition**: Transition animations must feel premium, symmetric (both entering and resetting the wallet), and smooth.
- **Visual Theme Isolation**: The old page and the new page must maintain their independent colors and layouts during the transition without color flashing.
- **User Event Blocking**: Prevent accidental taps on the outgoing page during transitions.

**Non-Goals:**
- Replacing the standard `Navigator` for normal sub-page navigation.
- Customizing individual sub-page push/pop transitions.

## Decisions

### Decision 1: Dual-MaterialApp Stack Switcher
We will build a custom stateful switcher `AppModeRevealSwitcher` at the root of `MyApp` (directly under the `ProviderScope`). When `AppMode` changes, instead of instantly replacing the page, the switcher places a new `MaterialApp` instance with its own independent theme and router on top of the old `MaterialApp` inside a `Stack`.
* **Rationale**: Discarding the entire `MaterialApp` widget on animation completion automatically destroys its navigator stack and garbage-collects all pushed pages (like `SettingsScreen`), solving the routing cleanup cleanly.
* **Alternatives considered**: Manually pops on the Navigator using a `GlobalKey`. This was rejected because it requires managing keys and doesn't cleanly support animating the reveal over the settings screen.

### Decision 2: IgnorePointer on Outgoing MaterialApp
Wrap the outgoing `MaterialApp` (positioned at the bottom of the Stack) in an `IgnorePointer(ignoring: true)` during the transition.
* **Rationale**: Because the incoming `MaterialApp` is clipped to a growing circle, tap events outside the circle would normally pass through to the bottom `MaterialApp`. `IgnorePointer` ensures all touch interactions outside the revealed area are ignored.

### Decision 3: Custom RadialRevealClipper for Circular Transition
Implement a `CustomClipper<Path>` that clips the top `MaterialApp` to an expanding circle.
* **Center**: `Offset(size.width / 2, size.height / 2)`
* **Radius**: `maxRadius * fraction`, where `maxRadius` is the screen diagonal length `math.sqrt(w*w + h*h) / 2` and `fraction` is driven by an `AnimationController` (from `0.0` to `1.0`).

## Risks / Trade-offs

- **[Risk] Memory / Widget Tree Overhead during Transition** → *Mitigation*: The dual `MaterialApp` tree structures only exist concurrently during the `650ms` animation window. On animation completion, the bottom widget is removed, immediately reclaiming resources.
- **[Risk] Performance on Lower-End Devices** → *Mitigation*: Both pages in the transition are mostly static during the reveal, and we mark the bottom child as `IgnorePointer` to disable gesture calculation, minimizing layout and paint overhead.

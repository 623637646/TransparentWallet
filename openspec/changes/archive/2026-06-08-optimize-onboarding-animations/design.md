## Context

The `OnboardingScreen` uses a `PageView` with 4 slides. Each slide contains a stateful `OnboardingAnimatedIcon` widget. Currently, the widget initializes and runs an `AnimationController` on every page if `isActive` is true. However, page 0 and page 3 do not define any animations, meaning they render a static child but still trigger rebuilds on every frame. Furthermore, page 2 (Hot Wallet) uses the `Opacity` widget to create a pulsing/fade effect on its ripple circles. This causes expensive offscreen rendering (`saveLayer`), consuming significant CPU and GPU.

## Goals / Non-Goals

**Goals:**
- Eliminate idle CPU utilization on `OnboardingScreen` when the user is on static pages (pages 0 and 3).
- Significantly reduce CPU and GPU overhead on the animated Hot Wallet page (page 2) by removing the expensive `Opacity` widget.
- Retain the exact visual design, timing, and aesthetics of the onboarding screen.

**Non-Goals:**
- Modify visual assets, icons, or text content on the onboarding screen.
- Redesign the onboarding flow or navigation.
- Implement any new pages or app states.

## Decisions

### 1. Bypass Animation Tickers on Non-Animated Pages
- **Description**: Add a helper method `_hasAnimation(int index)` returning true only for pages 1 and 2. Tickers will only run (`_controller.repeat()`) if `widget.isActive && _hasAnimation(widget.pageIndex)`.
- **Rationale**: Completely avoids registering and firing frame tickers on pages 0 and 3, reducing idle CPU usage of those pages to baseline.
- **Alternatives Considered**: Creating separate widgets for animated and static slides. Rejected because it would introduce duplicate layout code and lose the uniform configuration of slides.

### 2. Bypass AnimatedBuilder for Static Slides
- **Description**: In the `build` method of `_OnboardingAnimatedIconState`, if `_hasAnimation` is false, return the static container child directly without wrapping it in an `AnimatedBuilder`.
- **Rationale**: Prevents `AnimatedBuilder` from wrapping static children, reducing widget tree depth and memory allocations.

### 3. Replace Opacity Widget with Direct Color Alpha
- **Description**: Replace the `Opacity` widget wrapping the ripple `Container` on the Hot Wallet animation (page 2) with direct color alpha manipulation: `tokens.colors.primary.withValues(alpha: 0.3 * pulseOpacity)`.
- **Rationale**: Using the `Opacity` widget triggers `saveLayer`, which is highly expensive. Animating the border color's alpha directly performs the opacity blend during the main draw pass, avoiding offscreen blending.
- **Alternatives Considered**: Using `AnimatedOpacity`. Rejected because `AnimatedOpacity` still incurs layout/offscreen layers overhead when animating continuously. Modifying paint alpha is the most efficient approach.

## Risks / Trade-offs

- **[Risk]** Flutter SDK Compatibility of `withValues` API.
  - **Mitigation**: Checked `lib/src/utils/design_tokens.dart` and confirmed `withValues` is already used in the project, so it is fully supported by the active Flutter SDK version.

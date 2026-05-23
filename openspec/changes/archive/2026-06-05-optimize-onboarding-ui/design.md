## Context

The current onboarding page has three slides. Sliding to the last slide causes a vertical layout jump due to the actions container expanding from a single button (54px) to two stacked buttons (124px). Additionally, the page icons are static, and there is no specific slide detailing the Cold and Hot wallet modes separately.

## Goals / Non-Goals

**Goals:**
- Expand the onboarding carousel to four distinct pages: Welcome, Cold Wallet introduction, Hot Wallet introduction, and Choose Mode (selection).
- Add custom, looping micro-animations for the icons on each of the 4 slides to deliver a premium feel.
- Stabilize the bottom controls layout to ensure the page indicators and slide contents do not shift vertically when transitioning to the final slide.
- Smoothly transition the button states using `AnimatedSwitcher`'s cross-fade.

**Non-Goals:**
- Modifying the main application mode flow or database persistence logic.
- Adding external animation dependencies (e.g., Lottie, Rive) or custom raster assets. All animations will be built using standard Flutter widgets and controllers.

## Decisions

### Decision 1: Fixed-Height Actions Container
- **Approach**: Wrap the bottom button container in a `SizedBox(height: 124)`. On slides 0-2, the single "Next" button will be aligned to the top within this 124px box, leaving the bottom transparent. On slide 3, the two stacked buttons (54px each + 16px space) will occupy the full 124px.
- **Rationale**: Keeps the height of the bottom Column constant, eliminating any layout shifts of the indicators or page content.
- **Alternatives Considered**:
  - *AnimatedContainer*: Animating the height would still cause the indicators and slide text to slide up and down, which is visually distracting. A fixed-height container keeps the layout completely static and clean.

### Decision 2: Cross-Fade Button Transition
- **Approach**: Wrap the actions in an `AnimatedSwitcher` with a duration of 300ms, using a standard `FadeTransition` or `ScaleTransition` wrapper.
- **Rationale**: Smoothly cross-fades the single arrow-forward button into the stacked Cold/Hot wallet button layout.

### Decision 3: Custom Programmatic Icon Animations
- **Approach**: Implement a stateful widget `OnboardingIconAnimator` for each page's icon. The animations will use `AnimationController`s that run continuously when active (`isActive` parameter based on the current page index):
  1. **Page 0 (Welcome)**: Floating wallet. Uses a vertical translation animation (up/down by 6-8px via `Transform.translate` with a sine curve) and a very slow scale breathing (0.95 to 1.05).
  2. **Page 1 (Cold Wallet)**: Rotating snowflake. Uses a continuous 360-degree `RotationTransition` (completing a rotation every 10-12 seconds) combined with a gentle breathing scale.
  3. **Page 2 (Hot Wallet)**: Flickering flame. Uses a faster, offset-flickering animation (rapidly fluctuating scale between 0.92 and 1.05 and micro-rotations between -3 and +3 degrees).
  4. **Page 3 (Choose Mode)**: Pulsing security shield. Emits a concentric circular ripple effect from the icon background (drawing an outer circle that scales up from 1.0 to 1.5 and fades out).
- **Rationale**: Programmatic canvas animations in Flutter are extremely performant, responsive to styling, and avoid the overhead of heavy third-party assets.

## Risks / Trade-offs

- **Risk: Performance overhead of running multiple looping animation controllers.**
  - *Mitigation*: Only play/enable the animation controller when the page is active (`isActive == true`). Pause or stop the animation when the page is off-screen.
- **Risk: Resource leakage if controllers are not properly disposed.**
  - *Mitigation*: Implement standard stateful widget lifecycle discipline, overriding `dispose()` to properly close all `AnimationController` instances.

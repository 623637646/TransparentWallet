## Why

The onboarding screen currently suffers from high CPU utilization and potential battery drain. This is caused by:
1. Animation controllers running continuously at 60/120 FPS on static pages (pages 0 and 3) that do not have any visual animations.
2. The use of the GPU-expensive `Opacity` widget in the Hot Wallet pulsing ripple animation, which triggers offscreen rendering layer switches (`saveLayer`).

## What Changes

- **Avoid Redundant Tickers**: Update `OnboardingAnimatedIcon`'s state lifecycle to only start the animation controller if the slide has an animation defined (pages 1 and 2).
- **Bypass AnimatedBuilder**: Return the static widget directly without wrapping it in an `AnimatedBuilder` for slides that do not have animations, reducing widget-tree depth and rebuilding overhead.
- **Direct Color Alpha Animation**: Refactor the Hot Wallet pulsing ripple animation to directly animate the color's alpha channel on the container border, completely eliminating the expensive `Opacity` widget.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `onboarding-animations`: Add performance and resource constraints for onboarding icon animations, ensuring static pages do not run frame tickers and the ripple animation avoids expensive offscreen rendering layers.


## Impact

- **Affected Code**: `lib/src/widgets/onboarding_screen.dart` is the only file affected.
- **Dependencies**: No external dependency or Rust FFI changes are required.
- **Compatibility**: Backwards compatible, no breaking changes.

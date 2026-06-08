## 1. Onboarding Screen Optimization

- [x] 1.1 Implement the `_hasAnimation` helper function in `_OnboardingAnimatedIconState` inside `lib/src/widgets/onboarding_screen.dart`.
- [x] 1.2 Modify `initState` and `didUpdateWidget` in `_OnboardingAnimatedIconState` to check `_hasAnimation` before starting/repeating `_controller`.
- [x] 1.3 Update the `build` method in `_OnboardingAnimatedIconState` to return a static container child directly without wrapping it in an `AnimatedBuilder` for non-animated pages.
- [x] 1.4 Refactor the Hot Wallet pulsing ripple animation (`case 2` in the `build` method of `_OnboardingAnimatedIconState`) to remove the `Opacity` widget and directly animate the border color's alpha channel.

## 2. Verification

- [x] 2.1 Run local tests to ensure no regressions in onboarding screen code or compilation.
- [x] 2.2 Verify that onboarding animations (Cold and Hot wallet) still display and animate correctly as defined in the spec.

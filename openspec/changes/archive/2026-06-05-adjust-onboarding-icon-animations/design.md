## Context

The onboarding carousel contains 4 pages:
- Page index 0: Welcome / Get Started
- Page index 1: Cold Wallet Introduction
- Page index 2: Hot Wallet Introduction
- Page index 3: Choose Mode / Security

Currently, all 4 pages have looping micro-animations on their icons. The user wishes to remove animations from Pages 0 and 3, and move Page 3's pulsing animation to Page 2.

## Goals / Non-Goals

**Goals:**
- Disable animations for Page 0 (Welcome) and Page 3 (Choose Mode/Security).
- Relocate the pulsing outer-ring ripple animation (originally on Page 3) to Page 2 (Hot Wallet).
- Retain the rotation/breathing animation on Page 1 (Cold Wallet).

**Non-Goals:**
- Creating new animations or changing the transition between pages.
- Changing onboarding text, button behavior, or layout.

## Decisions

### 1. Refactor `OnboardingAnimatedIcon` Animation Mapping
We will update the `_getDuration()` and `AnimatedBuilder` inside `_OnboardingAnimatedIconState` in `lib/src/widgets/onboarding_screen.dart` as follows:
- **`case 0` & `case 3`**: Return `child!` without any transformations or extra widgets. In `_getDuration()`, return `const Duration(seconds: 2)` or keep them simple since no animation runs, but return `Duration.zero` or similar if appropriate. Actually, if `widget.isActive` is true, it repeats the controller. If there's no animation, keeping it simple is fine.
- **`case 2`**: Change the animation duration in `_getDuration()` to `const Duration(milliseconds: 2000)` (matching the pulsing animation's period). In the `AnimatedBuilder`, move the outer-ring ripple stack logic from `case 3` to `case 2`.

## Risks / Trade-offs

- **Risk**: Moving the pulsing outer ring logic to Page 2 might cause layout changes if the container dimensions differ.
- **Mitigation**: The pulsing container width/height is 120, which is the same as the base child's container (120x120), so it aligns perfectly without layout shifts.

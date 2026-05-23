## Why

The user requested adjustments to the premium onboarding icon animations to refine the first-run user experience:
1. Simplify pages with minimal visual distraction (removing animations from page 1 and the final page).
2. Reuse and reallocate the pulsing animation from the final page to the Hot Wallet introduction page, making it more dynamic.

## What Changes

- **Remove animation** from the first page (Welcome page).
- **Remove animation** from the last page (Choose Mode/Security page).
- **Apply pulsing animation** (originally on the last page) to the third page (Hot Wallet page).
- **Update existing specifications** for onboarding animations to reflect these adjustments.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `onboarding-animations`: Update the requirements for onboarding icon animations on Page 1, Page 3 (Hot Wallet), and Page 4.

## Impact

- `lib/src/widgets/onboarding_screen.dart`: Modify the `OnboardingAnimatedIcon` widget logic, animations, and durations to match the new animation layout.
- `openspec/specs/onboarding-animations/spec.md`: Update or add a delta specification.

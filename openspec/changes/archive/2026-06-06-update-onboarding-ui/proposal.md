## Why

The onboarding screen layout is currently cluttered with top bar actions (Skip and Back buttons) and a bottom "Next" button. Streamlining the UI by removing these elements and moving the page indicator to a clean, stable bottom position will offer a more focused, modern, and premium first-run experience.

## What Changes

- Remove the top navigation bar containing the "Skip" and "Back" buttons.
- Remove the "Next" action button from pages 1, 2, and 3.
- Re-position the page indicators (progress dots/pills) to the bottom of the screen, below the mode selection buttons on the final page, maintaining a stable position across all pages to prevent layout shifts.

## Capabilities

### New Capabilities
<!-- Capabilities being introduced. Replace <name> with kebab-case identifier (e.g., user-auth, data-export, api-rate-limiting). Each creates specs/<name>/spec.md -->

### Modified Capabilities
<!-- Existing capabilities whose REQUIREMENTS are changing (not just implementation).
     Only list here if spec-level behavior changes. Each needs a delta spec file.
     Use existing spec names from openspec/specs/. Leave empty if no requirement changes. -->
- `user-onboarding`: Update onboarding carousel controls to remove skip/back/next buttons and specify new page indicator placement.

## Impact

- `lib/src/widgets/onboarding_screen.dart`: UI adjustments for the onboarding layout.

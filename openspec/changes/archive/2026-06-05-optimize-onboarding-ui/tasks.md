## 1. Localization Updates

- [x] 1.1 Update English Fluent locales: add `onboarding-title-cold`, `onboarding-body-cold`, `onboarding-title-hot`, `onboarding-body-hot` to `rust_wallet/locales/en/main.ftl`.
- [x] 1.2 Update Chinese Fluent locales: add `onboarding-title-cold`, `onboarding-body-cold`, `onboarding-title-hot`, `onboarding-body-hot` to `rust_wallet/locales/zh/main.ftl`.

## 2. Core Onboarding Screen Structure & Layout

- [x] 2.1 Update the page count variable `_numPages` to `4` in `lib/src/widgets/onboarding_screen.dart`.
- [x] 2.2 Reorganize `PageView` children to present the 4 onboarding slides: Welcome, Cold Wallet introduction, Hot Wallet introduction, and Choose Mode (selection).
- [x] 2.3 Stabilize bottom controls layout by wrapping the action buttons in a fixed-height container of `124.0` pixels, aligning the "Next" button within this container to prevent layout shifting.
- [x] 2.4 Integrate `AnimatedSwitcher` to transition smoothly with a fade between the "Next" button on slides 0-2 and the "Cold/Hot Wallet" button stack on slide 3.

## 3. Premium Animated Onboarding Icons

- [x] 3.1 Implement dedicated premium animation classes (or a single configurable animated icon widget) to handle custom looping movements for each page:
  - Welcome: Floating vertical translation + slow breathing scale.
  - Cold Wallet: Continuous rotation + slow breathing scale.
  - Hot Wallet: Flickering scale + slight rotation wiggles.
  - Choose Mode: Concealed or nested outer glowing pulsing rings.
- [x] 3.2 Inject the current page active state (`isActive: _currentPage == index`) into the animated icon widgets.
- [x] 3.3 Ensure correct disposal of all animation controllers inside `dispose()` of the onboarding stateful widgets.

## 4. Verification and Directory Structure

- [x] 4.1 Verify the project builds successfully and runs local tests.
- [x] 4.2 Validate visually/manually that the page indicators and slide contents remain perfectly stationary during swiping.
- [x] 4.3 Update directory structure documentation in `AGENTS.md` using the `update-directory-structure` skill.


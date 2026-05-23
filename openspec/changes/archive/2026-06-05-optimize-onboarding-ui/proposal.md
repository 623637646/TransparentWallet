## Why

The current onboarding UI lacks polish and does not clearly present the distinct capabilities of the two wallet modes:
1. The Cold Wallet and Hot Wallet features are combined into a single, high-level mode summary, reducing user understanding before selection.
2. The onboarding page icons are static and lack engaging, premium micro-animations.
3. When sliding to the final screen, the bottom action buttons expand from a single button to a double-button stack, causing a layout height shift that pushes the page indicators and slide content upwards, creating a discordant user experience.

## What Changes

- **Onboarding Page Expansion**: Split the onboarding carousel into four pages (Welcome, Cold Wallet details, Hot Wallet details, Choose Mode selection).
- **Premium Icon Animations**: Implement custom, high-quality, looping micro-animations for the illustration icons of each slide, tailored to the slide's theme (e.g., floating for welcome, slow rotation for cold wallet snowflake, flickering scale/wiggle for hot wallet fire, protective pulsing for security shield).
- **Bottom Layout Stability**: Wrap the bottom buttons section in a fixed-height container (124px) to prevent vertical layout shifts, and use `AnimatedSwitcher` to transition smoothly between the single Next button and the stacked Cold/Hot buttons.
- **Localization Updates**: Add English and Chinese strings describing the Cold Wallet and Hot Wallet modes separately.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `user-onboarding`: Extend the carousel pages from 3 to 4, split cold/hot wallets into distinct slides, and enforce vertical UI stability for indicators.
- `onboarding-animations`: Specify the premium animation requirements (looping motions, transition durations, and theme styling) for onboarding page illustration icons.

## Impact

- **Flutter layer**:
  - [onboarding_screen.dart](file:///Users/yawang/Documents/janus_wallet-worktrees/AI/lib/src/widgets/onboarding_screen.dart): Implement the 4-page flow, the fixed-height actions container, `AnimatedSwitcher` transitions, and the animated icon widgets.
- **Localization layer**:
  - [main.ftl (English)](file:///Users/yawang/Documents/janus_wallet-worktrees/AI/rust_wallet/locales/en/main.ftl): Add new slide localization strings.
  - [main.ftl (Chinese)](file:///Users/yawang/Documents/janus_wallet-worktrees/AI/rust_wallet/locales/zh/main.ftl): Add new slide localization strings.

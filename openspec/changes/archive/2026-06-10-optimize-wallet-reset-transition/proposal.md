## Why

Currently, when the user resets the wallet, the database and secure storage are correctly reset, but the UI settings screen (pushed via `Navigator.push`) remains visible at the top of the route stack, leaving the app visually stuck on the settings screen. Additionally, the transition between onboarding and the cold/hot wallet dashboards is instant and jarring.

Implementing a responsive routing stack cleanup and a premium radial reveal transition animation will dramatically elevate the app's visual quality and interaction flow.

## What Changes

- **Automatic Router Stack Clearing (BREAKING)**: Eliminate the need for pages (like `SettingsScreen`) to handle route popping on reset. When `AppMode` switches to `AppMode.init`, the old `MaterialApp` widget (containing the entire navigation/route stack) is completely discarded and destroyed.
- **Dual-MaterialApp Stack Switcher**: Wrap the top-level app in a custom `Stack` switcher that manages the transition between two independent `MaterialApp` instances (the old mode and the new mode) during app mode changes.
- **Symmetrical Radial Reveal Animation**: Implement a circular clipping reveal animation centered on the screen. The new page (represented by the new `MaterialApp`) is clipped to an expanding circle that reveals it smoothly over the old page.
- **Touch Event Shielding**: Wrap the bottom `MaterialApp` in an `IgnorePointer` during transitions to prevent any interaction or touch event leakage to the old page.
- **Independent Theme Contexts**: Each `MaterialApp` maintains its own `ThemeData` based on its corresponding design tokens, preventing color flashing when transitioning between light/dark themes.

## Capabilities

### Modified Capabilities
- `settings-page`: Remove manual navigator stack popping on wallet reset; delegate navigation cleanup to the root app mode switcher.
- `user-onboarding`: Transition into and out of onboarding screens using a radial reveal transition.

## Impact

- `lib/src/widgets/my_app.dart`: Replaced direct reactive home rebuilding with a stateful `AppModeRevealSwitcher` managing a `Stack` of `MaterialApp`s.
- `lib/src/widgets/settings_screen.dart`: Removed `Navigator` manipulation inside the reset button's callback, keeping the action purely state-driven.
- Performance: Slight temporary increase in widget tree depth and resource usage during the 650ms transition window due to rendering two `MaterialApp` instances concurrently.

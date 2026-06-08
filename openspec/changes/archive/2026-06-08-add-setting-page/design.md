## Context

The current Janus Wallet implementation has a "Reset App Mode" button directly in the center of the `ColdWalletHome` and `HotWalletHome` screens. These buttons are placeholders and need to be replaced with a cleaner navigation flow to a dedicated settings page.

## Goals / Non-Goals

**Goals:**
- Implement a dedicated `SettingsScreen` widget in `lib/src/widgets/settings_screen.dart`.
- Integrate entry points (settings icon) in the navigation headers of `ColdWalletHome` and `HotWalletHome`.
- Remove legacy "Reset App Mode" buttons from home screens.
- Use the existing design token framework to style the `SettingsScreen` dynamically according to the active wallet mode (Cold Wallet mode vs. Hot Wallet mode).
- Integrate internationalization using `LocalizedText`.

**Non-Goals:**
- Introducing complex multi-page nested settings or other settings configurations not requested.

## Decisions

### 1. Dedicated Settings Screen
We will create `lib/src/widgets/settings_screen.dart` with a `SettingsScreen` widget. It will:
- Display an `AppBar` with a back button and a title (`settings-title`).
- Display list items for "Change Language" and "Reset Wallet Mode".
- Leverage `DesignTheme.of(context)` for consistent styling.

```dart
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  // ...
}
```

### 2. Settings Entry Point
Modify `ColdWalletHome` and `HotWalletHome` to add an `AppBar` containing a settings action button:
- Background color of AppBar: `Colors.transparent`
- Elevation: `0`
- Icon: `Icons.settings_outlined` with color `tokens.colors.ink`
- Route: Pushes `SettingsScreen` using `Navigator.of(context).push(...)`.

### 3. Reset App Mode Navigation & State Cleanup
When "Reset Wallet Mode" is pressed:
- Trigger `await appContext.setAppMode(appMode: AppMode.init);`.
- Rebuilding `MyApp`'s `StreamBuilder<AppMode>` automatically transitions the home widget to `OnboardingScreen`.
- We should also clean up the navigator stack by calling `Navigator.of(context).popUntil((route) => route.isFirst);` or simply pop the settings page if it was pushed on top, to ensure there are no orphaned pushed screens.

### 4. Color / Design Consistency
- List tile background color: `tokens.colors.surfaceTile1` or `tokens.colors.surfacePearl`
- Text colors: `tokens.colors.ink` for primary title, `tokens.colors.bodyMuted` for description/secondary labels.
- Borders/dividers: `tokens.colors.dividerSoft`

## Risks / Trade-offs

### [Risk] Route Stack Persistence
When transitioning `appMode` via the stream, if the `SettingsScreen` is still in the navigator stack, it could overlay the `OnboardingScreen`.
*Mitigation:* Before or immediately after invoking `appContext.setAppMode`, we pop/reset the navigator stack, ensuring we return to the root widget.

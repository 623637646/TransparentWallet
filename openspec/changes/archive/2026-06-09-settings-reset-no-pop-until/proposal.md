## Why

During the App reset flow in the Settings screen, calling `Navigator.of(context).popUntil((route) => route.isFirst)` can cause unwanted side effects or routing issues because invalidating `appContextProvider` already causes `MyApp` to rebuild and route the user back to the onboarding screen. Eliminating this explicit pop action simplifies the UI reset flow and prevents potential navigation errors.

## What Changes

- Remove the call to `Navigator.of(context).popUntil((route) => route.isFirst)` in `settings_screen.dart` when performing the app mode reset.
- Update the specifications for the settings page reset behavior to no longer require popping navigation routes from the stack.

## Capabilities

### New Capabilities

### Modified Capabilities

- `settings-page`: Remove the requirement to pop routes from the navigation stack during wallet mode reset.

## Impact

- `lib/src/widgets/settings_screen.dart`: Removed `Navigator.of(context).popUntil(...)` block.
- `openspec/specs/settings-page`: Modified the requirements to reflect the removal of the pop action.

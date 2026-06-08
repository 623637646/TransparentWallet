## Why

Currently, when the user triggers the "Reset Wallet Mode" (Reset App) option in the settings, calling a reset function on the `Context` causes it to invalidate and consume the underlying Rust `WalletApp` instance. Any subsequent FFI calls or stream events utilizing the old context reference will result in a runtime crash. 

To resolve this, we need a clean lifecycle management strategy for the application context:
1. Re-initialize a fresh `Context` via Riverpod's invalidation system.
2. Clear the UI navigation stack back to the root onboarding screen so no obsolete views attempt to query the destroyed context.

## What Changes

- **Change App Reset Action Flow**: Modify the Reset App interaction on the Settings Screen to invoke the async `appContext.resetApp()` FFI method, pop the navigator stack, and invalidate `appContextProvider`.
- **Introduce App Context Lifecycle Management**: Leverage Riverpod's `ref.invalidate` mechanism to tear down the old context, show the app loading screen, initialize a brand-new Rust context with a fresh database schema, and transition back to the onboarding screen.

## Capabilities

### New Capabilities
*None*

### Modified Capabilities
- `settings-page`: Modify the "Reset Wallet Mode" requirement to perform a full app database reset and safely re-initialize the app context provider instead of just calling `setAppMode`.

## Impact

- **UI Layer**:
  - `lib/src/widgets/settings_screen.dart`: Update reset action to pop navigation and invalidate the app context provider.
  - `lib/src/widgets/my_app.dart`: The root widget will automatically handle provider transition from loading to new context data.
- **Provider Layer**:
  - `lib/src/utils/app_context.dart`: Invalidation will trigger `initAppContext` which recreates database files and secure storage mappings.

## Context

In `settings_screen.dart`, when the user confirms the app reset, `appContext.resetApp()` is called, and then `Navigator.of(context).popUntil((route) => route.isFirst)` is executed right before `ref.invalidate(appContextProvider)`.

Invalidating `appContextProvider` triggers `MyApp` to rebuild. Because `MyApp` watches `appContextProvider` and rebuilds the root `MaterialApp` with the new onboarding or initial state (AppMode.init), the navigation stack is naturally reset to the root screen. Therefore, calling `Navigator.popUntil` is redundant and can cause visual glitching or routing errors during the reinitialization phase.

## Goals / Non-Goals

**Goals:**
- Simplify the reset app routing flow by removing `Navigator.of(context).popUntil((route) => route.isFirst)`.
- Ensure the application successfully transitions to the Onboarding Screen on reset without route-related exceptions.

**Non-Goals:**
- Changing any database or Rust-side reset logic.
- Redesigning the `appContextProvider` initialization or how `MyApp` watches the state.

## Decisions

### Decision 1: Remove `popUntil` from the reset transaction
- **Option A (Chosen)**: Remove `Navigator.of(context).popUntil(...)` entirely. Rely on Riverpod's invalidation of `appContextProvider` which rebuilds the root `MaterialApp` and effectively resets the navigation history.
  - *Rationale*: Rebuilding the root `MaterialApp` with a new `home` widget automatically mounts the onboarding screen as the root and destroys any settings screen route stack, making `popUntil` unnecessary and prone to transition errors.
- **Option B**: Keep the `popUntil` but wrap it in additional checks or delay it.
  - *Rationale*: Unnecessarily complex and still risks race conditions during the Riverpod state transition.

## Risks / Trade-offs

- **Risk**: Leaving the settings screen temporarily on top during the asynchronous reset if Riverpod takes a moment to update.
  - *Mitigation*: The reset operation is very fast, and Riverpod invalidation immediately switches `appContextProvider` to a loading state, which renders a loader screen at the root, instantly tearing down the settings screen anyway.

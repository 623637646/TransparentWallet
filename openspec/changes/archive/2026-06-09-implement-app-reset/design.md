## Context

In the current architecture, the application `Context` is instantiated at startup and exposed globally via the Riverpod `appContextProvider` (a `FutureProvider<Context>`).

When resetting the app, the Rust-side `reset_app(self)` method consumes ownership of the `WalletApp` instance to clean up resources, rendering the old Dart-side `Context` handle completely invalid. If any widget continues to access the invalid handle or listen to its streams, the app will crash.

To address this, we must align the Dart-side `Context` lifecycle with the Rust-side cleanup by resetting the provider state and clearing obsolete UI widgets.

## Goals / Non-Goals

**Goals:**
- Perform a complete application reset (databases and secure storage) safely via Rust FFI.
- Cleanly reset the Riverpod provider `appContextProvider` so it provides a newly initialized `Context` instance.
- Ensure the UI returns back to the root onboarding screen upon reset without runtime crashes.

**Non-Goals:**
- Refactoring the routing structure (e.g., migrating to GoRouter).
- Implementing multi-profile database setups.

## Decisions

### Decision 1: Invalidate appContextProvider using Riverpod
- **Options**:
  1. Manually update a state notifier containing the context.
  2. Use `ref.invalidate(appContextProvider)`.
- **Selected Option**: Option 2. Invalidating the `FutureProvider` causes it to transition to `AsyncLoading` and run `initAppContext` again. In `MyApp`, watching the provider automatically replaces the old widget tree with a loading spinner while the new context initializes. Once ready, the `data` state mounts the new widgets (and stream builders) with the new context.

### Decision 2: Clear Navigation Stack Before Invalidation
- **Rationale**: Popping the navigation stack back to the root route (`Navigator.popUntil((route) => route.isFirst)`) before invalidating the provider ensures that the settings screen is cleanly closed, preventing any unmounted contexts or navigation state issues when `MyApp` rebuilds.

## Risks / Trade-offs

- **[Risk]**: Concurrency / Race conditions if the user double-clicks the reset option.
  - **Mitigation**: The confirmation alert dialog actions should be dismissed immediately, and a loading barrier can be shown if the reset operation takes significant time.
- **[Risk]**: Stream callbacks trying to fire after database deletion.
  - **Mitigation**: Tearing down the old `MaterialApp` widget tree upon invalidation automatically cancels all active `RustStreamBuilder` subscriptions.

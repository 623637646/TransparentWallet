## Context

In the current architecture, Flutter communicates with the Rust core through an FFI bridge. Subscriptions to Rust streams are managed via `convertSubscriptionToStream` (defined in `lib/src/utils/bridge_helper.dart`). 

When implementing UI widgets that consume these streams (e.g., `LocalizedText`, language settings), developers write stateful widgets that:
1. Define a local `Stream<T>` variable.
2. Initialize it in `initState` via `convertSubscriptionToStream`.
3. Handle updates in `didUpdateWidget` by recreating the stream.
4. Render using a `StreamBuilder` in `build`.

This boilerplate is repetitive and prone to lifecycle bugs (such as failing to handle updates or disposing of subscriptions incorrectly).

## Goals / Non-Goals

**Goals:**
- Design a single, reusable `RustStreamBuilder<T, E extends Object>` widget that encapsulates FFI subscription creation and reactive UI rendering.
- Ensure proper resource disposal by automatically cancelling/disposing of subscriptions when the widget is disposed.
- Provide dependency tracking (`keys` array) to prevent unnecessary unsubscribe/resubscribe cycles during parent widget rebuilds.
- Provide custom hooks/builders for loading and error states to ensure clean UI presentation.

**Non-Goals:**
- Completely replace all state management (e.g., migrating to Riverpod) in this task.
- Rewrite all existing widgets in one go; we will implement the common widget and optionally migrate a representative widget (e.g., `LocalizedText` or a part of `settings_screen.dart`) to verify it.

## Decisions

### 1. Unified Stateful Wrapper around StreamBuilder
We will implement `RustStreamBuilder` as a `StatefulWidget` that internally manages a `Stream<T>` constructed via `convertSubscriptionToStream`.
- **Alternatives considered**: Writing a custom inherited widget or hooks.
- **Rationale**: A `StatefulWidget` with a nested `StreamBuilder` matches Flutter's native architecture, requires no extra dependencies (like `flutter_hooks`), and is very easy to use for any developer. Additionally, the subscription builder callback will be invoked with the global `appContext` (the Rust `Context` instance) so that callers can call Rust FFI stream APIs directly on it.

### 2. Dependency Tracking via `keys`
Since subscription builders are typically passed as anonymous closures (which are recreated on every rebuild and thus fail simple reference equality checks), the widget will take an optional `List<Object?>? keys` parameter.
- **Alternatives considered**: Comparing the builder function directly.
- **Rationale**: Direct comparison of closures always returns false if defined in-line, causing constant unsubscribe/resubscribe cycles. The `keys` list allows callers to specify which parameters actually trigger a resubscription (e.g. `keys: [textId, args]`), similar to React's `useEffect` dependencies.

### 3. Pluggable Loading & Error Builders
The widget will expose `loadingBuilder` and `errorBuilder`.
- **Rationale**: Different parts of the application require different loaders (e.g., a full-screen spinner vs. a small inline loader or an empty box) and error fallbacks.

## Risks / Trade-offs

- **[Risk] Improper Disposal / Memory Leaks** → *Mitigation*: The `convertSubscriptionToStream` utility automatically calls `dispose()` on the `BridgeSubscription` when the stream is cancelled. By using `StreamBuilder` and letting it manage the stream lifecycle, the subscription is closed and disposed of when the widget is removed from the tree.
- **[Risk] Redundant Subscriptions** → *Mitigation*: The `didUpdateWidget` lifecycle method will check if `keys` have changed. If `keys` is null, the subscription is created once and never recreated, which is the safest default behavior.

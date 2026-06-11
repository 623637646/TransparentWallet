## Context

During cryptographic operations (such as Argon2 derivation in the PIN module) or FFI write operations, the user must be prevented from dismissing the current screen or making extra inputs to prevent race conditions or invalid states. 

## Goals / Non-Goals

**Goals:**
- Implement a global loading overlay that covers the entire viewport.
- Fully block all touch events and gestures while loading is active.
- Control the overlay declaratively using a global Riverpod provider.
- Implement a high-fidelity, premium animated loader without text.
- Integrate the overlay into all PIN bottom sheet operations (create, modify, verify).

**Non-Goals:**
- Displaying loading messages or progress percentages.
- Custom loading indicators on a per-page basis (one global aesthetic).

## Decisions

### Decision 1: Declarative Overlay Placement via `MaterialApp.builder`
- **Alternative:** Imperative management using `Overlay.of(context).insert(...)`.
- **Rationale:** `MaterialApp.builder` wraps the inner `Navigator`. This ensures the overlay automatically sits above all pages, dialogs, and modal bottom sheets pushed inside the navigator, while still inheriting the `DesignTheme` and `MediaQuery` from `MaterialApp`.

### Decision 2: Riverpod State Provider for Control
- **Alternative:** Custom singleton class or passing callbacks.
- **Rationale:** A simple Riverpod `StateProvider<bool>` is clean, fully reactive, easy to test, and enables any widget or notifier across the app to toggle loading state easily.

### Decision 3: High-Fidelity Custom rotating Spinner UI
- **Alternative:** Standard Material `CircularProgressIndicator`.
- **Rationale:** Standard loaders look cheap. We will design a custom rotating spinner with a gradient arc and glow effect using `CustomPainter` to align with the premium design guidelines in the project.

## Risks / Trade-offs

- **[Risk] App permanently locked on unhandled exception** → **[Mitigation]** Wrap all async calls modifying the loading state in `try...finally` blocks to guarantee loading is reset to `false` in all execution paths.

## Context

The `MyApp` widget is the root of the Flutter application. It listens to the FFI `appModeStream` using `RustStreamBuilder` to route the user to the onboarding screen or the cold/hot wallet homepages. Currently, the tree structure returned by the loading and error builder functions differs from the one returned by the main builder. This causes the entire `MaterialApp` widget tree to be torn down and rebuilt when the stream changes states.

## Goals / Non-Goals

**Goals:**
- Unify the root widget hierarchy of `MyApp` across all stream states (loading, error, ready) to prevent `MaterialApp` unmounting and rebuilds.
- Centralize `MaterialApp` parameters to keep the layout code DRY.
- Replace hardcoded text styling parameters in the error display with design token typography values.

**Non-Goals:**
- Modifying the internal implementation of `RustStreamBuilder`.
- Introducing state management tools (like Riverpod) for routing at this stage.

## Decisions

### 1. Unified App Builder Method
We will introduce a private helper method `_buildApp({required DesignTokens tokens, required Widget home})` that returns:
```
DesignTheme -> MaterialApp -> Scaffold/Page
```
This wrapper will be used in `loadingBuilder`, `errorBuilder`, and `builder`. Since the runtime type at the root of all three callbacks is now `DesignTheme`, Flutter's element tree will reuse the existing `MaterialApp` element when transitioning between states, updating only the parameters (e.g. theme and body).

### 2. Design Token Typography in Error State
Currently, the error display uses a hardcoded `TextStyle(fontFamily: 'Inter', fontSize: 16)`. We will replace it with `DesignTokens.typography.body.copyWith(color: initialTokens.colors.ink)` to comply with design token usage guidelines.

## Risks / Trade-offs

- **[Risk] Widget state mismatch if keys change** → *Mitigation*: The `_buildApp` method retains identical keys and type structure, so Flutter can update the properties cleanly without resetting the state.

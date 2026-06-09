## Why

The root `MyApp` widget currently instantiates three separate `MaterialApp` widgets in its `loadingBuilder`, `errorBuilder`, and `builder` callbacks of `RustStreamBuilder`. This causes a full unmount and rebuild of the entire `MaterialApp` widget tree whenever `RustStreamBuilder` transitions between states (e.g. from loading to ready). This results in startup flickering, loss of navigator/overlay states, and unnecessary runtime overhead. In addition, the error state contains hardcoded typography parameters (fontFamily, fontSize), which violates the project's styling guidelines.

## What Changes

- Refactor `my_app.dart` to use a single, unified private helper method `_buildApp` that wraps page content with the `DesignTheme` inherited widget and `MaterialApp`.
- Ensure that the widget tree root structure is identical (`DesignTheme` -> `MaterialApp`) across all builder states (loading, error, and ready) so that Flutter can reuse the `MaterialApp` element/state and avoid recreating the entire app tree.
- Eliminate duplicated `MaterialApp` settings (such as debugShowCheckedModeBanner, fontFamily, and theme configuration) by centralizing them in `_buildApp`.
- Refactor the hardcoded text styling in `errorBuilder` to consume typography tokens from `DesignTokens.typography` instead of hardcoding text properties.

## Capabilities

### New Capabilities
- `app-configuration`: Streamlining and optimizing root MaterialApp and design theme configuration across stream lifecycle states.

### Modified Capabilities
- None

## Impact

- `lib/src/widgets/my_app.dart`: Refactored to unify the app builder structure and remove hardcoded typography tokens.
- Dynamic theme switches: Transitioning from the initial loading state to the ready state (either hot or cold wallet) will be completely smooth and flicker-free.

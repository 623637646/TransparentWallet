## Why

The current implementation of `AppContext` relies on a global, mutable `late Context appContext` variable. This approach can lead to initialization race conditions, makes testing and mocking difficult, and violates clean state management principles. By refactoring `AppContext` to use Riverpod, we establish a robust dependency injection and state management foundation that ensures type-safe, lifecycle-managed, and easily testable access to the Rust core context.

## What Changes

- Add the `flutter_riverpod` package to the project dependencies.
- Remove the global mutable `late Context appContext` variable and `initAppContext()` global initialization helper.
- Introduce an `appContextProvider` provider that exposes the initialized `Context`.
- Wrap the app root with `ProviderScope` to enable Riverpod state management.
- Refactor `RustStreamBuilder` to be a `ConsumerStatefulWidget` that reads the `Context` from `appContextProvider` automatically, eliminating the need to pass `appContext` to it.
- Refactor `LocalizedText` to not require `appContext` to be passed via its constructor.
- Refactor all widgets that consume `appContext` directly (e.g., settings, onboarding, PIN bottom sheet) to use `ConsumerWidget` or `ConsumerStatefulWidget` to read the context from Riverpod.

## Capabilities

### New Capabilities
- `riverpod-state-management`: Manages the lifecycle and distribution of the Rust `Context` using Riverpod providers.

### Modified Capabilities

## Impact

- **Dependencies**: Adds `flutter_riverpod` to `pubspec.yaml`.
- **Initialization**: App initialization in `main.dart` is updated to wrap the root widget in a `ProviderScope` and inject the asynchronously initialized `Context`.
- **API Contracts**: Refactors the constructor signature of `LocalizedText` and internal subscription builders to omit manual context propagation.
- **Component Architecture**: Changes several key Flutter UI components to extend Riverpod widgets (`ConsumerWidget` or `ConsumerStatefulWidget`).

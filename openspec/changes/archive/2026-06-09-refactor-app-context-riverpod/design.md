## Context

Currently, the Flutter layer of the Janus Wallet uses a global mutable `late Context appContext` variable to access the Rust core FFI context. This was initialized inside a global `initAppContext()` function. This approach has several drawbacks:
- Global variables create implicit dependencies across widgets, making them harder to mock and test.
- Changing app initialization or reset flows with global variables is error-prone.
- Hardcoded propagation of the context through constructors (like `LocalizedText(..., appContext: appContext)`) clutches widget interfaces.

Integrating Riverpod enables elegant dependency injection and state management.

## Goals / Non-Goals

**Goals:**
- Eliminate the global mutable `late Context appContext` variable.
- Centralize `Context` lifecycle and lookup through a Riverpod provider (`appContextProvider`).
- Simplify widget constructors by removing the need to manually pass down `appContext`.
- Ensure all tests still pass and the build is clean.

**Non-Goals:**
- Refactoring the entire app state to Riverpod. (We will only refactor `AppContext` and the widgets that depend on it).
- Modifying Rust core logic.

## Decisions

### 1. Initialization and Provider Configuration
- **Decision**: Define a `FutureProvider<Context>` to handle the asynchronous initialization of the context:
  ```dart
  final appContextProvider = FutureProvider<Context>((ref) async {
    return initAppContext();
  });
  ```
  In `main()`, we no longer await `initAppContext()`. The root widget `MyApp` watches `appContextProvider` and uses `.when()` to display a loading or error widget. Descendant widgets can safely access the context synchronously via `ref.watch(appContextProvider).requireValue` since they are only rendered after the context is fully loaded.
- **Rationale**: This is the standard, idiomatic way in Riverpod to handle asynchronous startup dependencies. It is completely self-contained, type-safe, and avoids unconventional placeholder provider overrides that throw `UnimplementedError` at runtime.

### 2. Stream Builder Refactoring
- **Decision**: Refactor `RustStreamBuilder` to extend `ConsumerStatefulWidget` and `ConsumerState`. Inside its state initialization, read the `Context` from `appContextProvider` via `ref.read(appContextProvider)` and pass it into the user's `subscriptionBuilder` callback.
- **Rationale**: This decouples `RustStreamBuilder`'s callers from having to supply the context manually. Callers only need to provide the stream builder function.

### 3. Widget Refactoring
- **Decision**:
  - Remove `appContext` parameter from the `LocalizedText` constructor since `RustStreamBuilder` will resolve it.
  - Refactor other widgets that call FFI methods directly (e.g. `SettingsScreen`, `OnboardingScreen`, `PinBottomSheet`) to use `ConsumerWidget` or `ConsumerStatefulWidget`, reading the context using `ref.read(appContextProvider)`.

## Risks / Trade-offs

- **Risk**: Missing provider overrides or missing `ProviderScope` in tests.
  - **Mitigation**: Update test files to wrap widgets in a `ProviderScope` and override `appContextProvider` with a mocked or initialized context.

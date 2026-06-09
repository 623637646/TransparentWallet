## Context

Currently, the FFI subscription stream helper `convertSubscriptionToStream` is defined as a public API in `lib/src/utils/bridge_helper.dart`. Flutter widgets like `MyApp`, `LanguageSelectionBottomSheet`, `OnboardingScreen`, and `SettingsScreen` consume this helper directly to create streams and manage subscriptions manually using `StreamBuilder`. This introduces boilerplate code and increases the risk of memory leaks due to improper subscription disposal.

We aim to encapsulate the stream conversion logic inside `RustStreamBuilder` as a private API, and refactor all existing widgets to use the unified `RustStreamBuilder` widget instead.

## Goals / Non-Goals

**Goals:**
- Relocate the stream conversion logic to `lib/src/widgets/common/rust_stream_builder.dart` as a private helper `_convertSubscriptionToStream`.
- Delete the now obsolete `lib/src/utils/bridge_helper.dart` file.
- Refactor the widgets `MyApp`, `LanguageSelectionBottomSheet`, `OnboardingScreen`, and `SettingsScreen` to use `RustStreamBuilder` instead of `convertSubscriptionToStream`.
- Refactor `lib/src/utils/logger.dart` to subscribe to the Rust log stream directly using FFI callbacks.

**Non-Goals:**
- Modifying any Rust-side FFI APIs or stream subscription managers.
- Changing any visual layout, styles, or user-visible behaviors.

## Decisions

### 1. Private Stream Conversion Helper in `rust_stream_builder.dart`
Move the definition of `convertSubscriptionToStream` into `lib/src/widgets/common/rust_stream_builder.dart` and rename it to `_convertSubscriptionToStream`.
- *Rationale*: This utility is only needed by `RustStreamBuilder` to convert a future subscription builder into a stream. Keeping it private ensures encapsulation and prevents other modules from bypassing `RustStreamBuilder` to manage streams manually.

### 2. Direct FFI Callbacks in `logger.dart`
Refactor `initRustLogger` in `lib/src/utils/logger.dart` to call `initLogger` directly.
- *Rationale*: Since the logger is a global singleton utility and not a UI widget, it does not need a `RustStreamBuilder` or a Flutter stream. Directly providing `onNext` and `onTermination` callbacks to the FFI bridge avoids the overhead of Stream and StreamController, and matches the application lifecycle.

## Risks / Trade-offs

- **[Risk] Resource leaks in logger** → *Mitigation*: The logger is initialized once on application start and remains active throughout the application lifetime. There is no requirement to dispose of the logger subscription during runtime. Changing `_loggerSubscription` to a `Future<BridgeSubscription>` still allows tracing and verification of the initialization status.
- **[Risk] Widget lifecycle mismatch when using RustStreamBuilder** → *Mitigation*: Ensure `RustStreamBuilder` handles updates and key changes correctly via `didUpdateWidget` (as it already does) to resubscribe when necessary.

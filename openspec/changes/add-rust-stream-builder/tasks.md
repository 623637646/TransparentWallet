## 1. Core Widget Implementation

- [x] 1.1 Create the file `lib/src/widgets/common/rust_stream_builder.dart`.
- [x] 1.2 Implement the class `RustStreamBuilder<T, E extends Object>` extending `StatefulWidget` with required parameters `subscriptionBuilder` (taking Rust Context) and `builder`.
- [x] 1.3 Add optional parameters `initialData`, `loadingBuilder`, `errorBuilder`, and `keys` to `RustStreamBuilder`.
- [x] 1.4 Implement stream conversion in `initState` utilizing `convertSubscriptionToStream` and the global `appContext`.
- [x] 1.5 Implement dependency check in `didUpdateWidget` using the `keys` list to recreationally subscribe to the FFI stream only when keys change.
- [x] 1.6 Implement rendering logic using `StreamBuilder` and wire up the `builder`, `loadingBuilder`, and `errorBuilder`.

## 2. Verification & Cleanup

- [x] 2.1 Refactor `lib/src/widgets/common/localized_text.dart` to use the new `RustStreamBuilder` widget to verify its correctness.
- [x] 2.2 Run static analysis (`flutter analyze`) and run unit tests if any to verify compilation and runtime safety.
- [x] 2.3 Run the `update-directory-structure` skill to document `rust_stream_builder.dart` in `AGENTS.md`.

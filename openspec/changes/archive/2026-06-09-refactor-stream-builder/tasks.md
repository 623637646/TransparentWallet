## 1. Relocate and Encapsulate Stream Conversion

- [x] 1.1 Move the `convertSubscriptionToStream` definition into `lib/src/widgets/common/rust_stream_builder.dart` as a private top-level helper function named `_convertSubscriptionToStream` and update imports.

## 2. Refactor Widgets to use RustStreamBuilder

- [x] 2.1 Refactor `lib/src/widgets/my_app.dart` to use `RustStreamBuilder` instead of manual `StreamBuilder` and `convertSubscriptionToStream`.
- [x] 2.2 Refactor `lib/src/widgets/common/language_selection_bottom_sheet.dart` to use `RustStreamBuilder` instead of manual `StreamBuilder` and `convertSubscriptionToStream`.
- [x] 2.3 Refactor `lib/src/widgets/onboarding_screen.dart` to use `RustStreamBuilder` instead of manual `StreamBuilder` and `convertSubscriptionToStream`.
- [x] 2.4 Refactor `lib/src/widgets/settings_screen.dart` to use `RustStreamBuilder` instead of manual `StreamBuilder` and `convertSubscriptionToStream`.

## 3. Refactor Logger

- [x] 3.1 Refactor `lib/src/utils/logger.dart` to call `initLogger` directly with FFI callbacks, replacing the `convertSubscriptionToStream` usage.

## 4. Cleanup and Documentation

- [x] 4.1 Delete the obsolete file `lib/src/utils/bridge_helper.dart`.
- [x] 4.2 Update `AGENTS.md` directory structure and guidelines using the `update-directory-structure` skill or manually.

## 5. Verification

- [x] 5.1 Build the application and run Dart analyzers to verify there are no compilation errors or warnings.
- [x] 5.2 Run automated tests to ensure existing functionalities are not broken.

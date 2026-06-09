## Why

Currently, `convertSubscriptionToStream` is exposed as a public API in `lib/src/utils/bridge_helper.dart`. This leads to widgets manually managing stream lifecycles, leading to unnecessary boilerplate and potential memory leaks. Moving this logic to a private API within `RustStreamBuilder` and replacing manual streams with `RustStreamBuilder` improves code maintainability, encapsulation, and resource management.

## What Changes

- **Encapsulate Stream Logic**: Move `convertSubscriptionToStream` from `lib/src/utils/bridge_helper.dart` into `lib/src/widgets/common/rust_stream_builder.dart` and make it a private API.
- **Delete Obsolete Bridge Helper**: Delete `lib/src/utils/bridge_helper.dart` entirely since its sole utility is relocated.
- **Refactor Widgets**: Replace all manual usages of `convertSubscriptionToStream` (in `MyApp`, `LanguageSelectionBottomSheet`, `OnboardingScreen`, and `SettingsScreen`) with `RustStreamBuilder`.
- **Refactor Logger**: Refactor `lib/src/utils/logger.dart` to subscribe to the Rust log stream using direct FFI callbacks instead of relying on `convertSubscriptionToStream`.

## Capabilities

### New Capabilities
None.

### Modified Capabilities
None.

## Impact

- `lib/src/utils/bridge_helper.dart` (Deleted)
- `lib/src/widgets/common/rust_stream_builder.dart` (Modified)
- `lib/src/utils/logger.dart` (Modified)
- `lib/src/widgets/my_app.dart` (Modified)
- `lib/src/widgets/onboarding_screen.dart` (Modified)
- `lib/src/widgets/settings_screen.dart` (Modified)
- `lib/src/widgets/common/language_selection_bottom_sheet.dart` (Modified)

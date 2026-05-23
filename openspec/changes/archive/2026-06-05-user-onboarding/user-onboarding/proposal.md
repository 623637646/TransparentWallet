## Why

Currently, when the Janus Wallet is launched for the first time, `MyApp` is completely unimplemented and throws an error. There is no onboarding flow to guide first-time users or allow them to choose their wallet execution mode (Cold Wallet or Hot Wallet) before entering the main application interface.

## What Changes

- Add a beautiful, multi-page, swipeable user onboarding carousel page using Flutter and following the Uber-inspired design tokens specified in `DESIGN.md`.
- Implement routing logic in `MyApp` to display the onboarding page if the `AppMode` stream emits `AppMode.init`.
- Integrate two action buttons ("Cold Wallet" and "Hot Wallet") on the onboarding pages that set the appropriate app mode using the Rust context API (`setAppMode`), allowing future launches to bypass the onboarding page.
- Add localization keys in English (`en/main.ftl`) and Chinese (`zh/main.ftl`) for onboarding page content and use the `LocalizedText` widget for reactive rendering.

## Capabilities

### New Capabilities

- `user-onboarding`: Covers the user onboarding carousel flow, including first-run detection using AppMode, page swiping layout, localized text, and setting the wallet execution mode (Cold/Hot wallet).

### Modified Capabilities

<!-- None. There are no existing specifications or capabilities defined. -->

## Impact

- **Flutter / Dart UI Layer**: Update `lib/src/widgets/my_app.dart` to handle routing based on `appModeStream`; create onboarding page widgets inside `lib/src/widgets/` or `lib/src/widgets/common/`.
- **Localization**: Update `rust_wallet/locales/en/main.ftl` and `rust_wallet/locales/zh/main.ftl` with onboarding strings.
- **State Management**: Consume `appModeStream` and call `setAppMode` from `appContext` in Dart.

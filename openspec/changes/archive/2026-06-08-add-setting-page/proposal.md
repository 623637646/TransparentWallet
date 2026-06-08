## Why

Currently, resetting the app mode is implemented via basic buttons directly placed on the placeholder home screens for Cold Wallet and Hot Wallet. To provide a cleaner, more professional interface, we need a dedicated settings screen. This screen will centralize application configuration, including system language switching and resetting the wallet mode, while removing the clutter from the main home screens.

## What Changes

- **NEW** Settings Screen containing two main configurations:
  1. Change Language (using the existing `LanguageSelectionBottomSheet` logic).
  2. Reset Wallet Mode (returns to the onboarding/init state).
- **NEW** Entry points (settings icons/buttons) in the top-right corner of both the Cold Wallet Home and Hot Wallet Home screens.
- **REMOVE** The placeholder "Reset App Mode" buttons from both Cold Wallet Home and Hot Wallet Home screens.
- **NEW** Localization keys for the Settings page titles and actions.

## Capabilities

### New Capabilities
- `settings-page`: Adds a dedicated settings page containing options to change language and reset the wallet mode, with entry points from cold/hot wallet home pages.

### Modified Capabilities

## Impact

- `lib/src/widgets/cold_wallet_home.dart`: Remove old reset button, add top-right settings icon/button.
- `lib/src/widgets/hot_wallet_home.dart`: Remove old reset button, add top-right settings icon/button.
- `lib/src/widgets/settings_screen.dart` (New): Implement the settings UI with language selection and wallet mode reset options.
- `rust_wallet/locales/en/main.ftl`, `rust_wallet/locales/zh/main.ftl`: Add setting-related localized strings.

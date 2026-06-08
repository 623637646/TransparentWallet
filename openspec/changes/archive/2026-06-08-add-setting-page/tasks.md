## 1. Localization Setup

- [x] 1.1 Add settings-related Fluent localization keys to `rust_wallet/locales/en/main.ftl`
- [x] 1.2 Add settings-related Fluent localization keys to `rust_wallet/locales/zh/main.ftl`

## 2. Implement Settings Screen

- [x] 2.1 Create `lib/src/widgets/settings_screen.dart`
- [x] 2.2 Implement `SettingsScreen` UI layout and styling using design tokens from `DesignTheme.of(context)`
- [x] 2.3 Add language selection action to open `LanguageSelectionBottomSheet`
- [x] 2.4 Add wallet mode reset action calling `appContext.setAppMode(appMode: AppMode.init)` and popping navigation stack

## 3. Update Wallet Home screens

- [x] 3.1 Update `lib/src/widgets/cold_wallet_home.dart` to remove old reset button and add top-right settings icon button
- [x] 3.2 Update `lib/src/widgets/hot_wallet_home.dart` to remove old reset button and add top-right settings icon button

## 4. Verification and Guidelines

- [x] 4.1 Update the Directory Structure in `AGENTS.md` using the `update-directory-structure` skill
- [x] 4.2 Verify everything builds successfully and tests pass

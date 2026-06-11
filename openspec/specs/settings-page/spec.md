# Settings Page

## Purpose
Provides a settings screen for configuring application settings, such as switching languages and resetting the wallet mode.
## Requirements
### Requirement: Settings screen entry point and removal of legacy buttons
The application SHALL remove the legacy "Reset App Mode" buttons from both the Cold Wallet Home and Hot Wallet Home screens. Instead, both screens SHALL feature a Settings icon/button in the top-right corner of their layouts. Tapping this button SHALL navigate the user to the Settings Screen.

#### Scenario: Navigate to Settings Screen from Cold Wallet Home
- **WHEN** the user is on the Cold Wallet Home screen and taps the Settings button in the top-right corner
- **THEN** the application navigates to the Settings Screen

#### Scenario: Navigate to Settings Screen from Hot Wallet Home
- **WHEN** the user is on the Hot Wallet Home screen and taps the Settings button in the top-right corner
- **THEN** the application navigates to the Settings Screen

### Requirement: Settings Screen layout and styling
The Settings Screen SHALL display a clean, high-contrast settings list using the colors, spacing, typography, and border radius parameters from `design_tokens.dart` resolved via the active `DesignTheme.of(context)`. The settings page SHALL use `LocalizedText` for all user-visible labels and titles. The Settings Screen SHALL include a standard navigation header allowing the user to return to the previous screen.

#### Scenario: Settings Screen renders correctly
- **WHEN** the Settings Screen is displayed
- **THEN** the UI is styled according to the current DesignTheme tokens, displaying setting options for language selection and wallet mode reset

### Requirement: Settings Screen language selection
The Settings Screen SHALL offer a "Change Language" setting option. Tapping this option SHALL trigger the display of the `LanguageSelectionBottomSheet` popup, allowing the user to switch the system/app language.

#### Scenario: Tapping Change Language triggers bottom sheet
- **WHEN** the user is on the Settings Screen and taps the "Change Language" option
- **THEN** the language selection bottom sheet is displayed, showing options for English, Chinese, and System Language

### Requirement: Settings Screen PIN action item
The Settings Screen SHALL display a PIN action item.
1. If no PIN is configured, the item's label SHALL be "Create PIN" (or equivalent translation). Tapping it SHALL show the PIN creation UI.
2. If a PIN is configured, the item's label SHALL be "Modify PIN" (or equivalent translation). Tapping it SHALL show the PIN modification UI.

#### Scenario: PIN action item displays "Create PIN" when no PIN is configured
- **WHEN** the user is on the Settings Screen and no PIN is configured
- **THEN** the PIN action item is labeled "Create PIN" and tapping it opens the PIN creation UI

#### Scenario: PIN action item displays "Modify PIN" when a PIN is configured
- **WHEN** the user is on the Settings Screen and a PIN is configured
- **THEN** the PIN action item is labeled "Modify PIN" and tapping it opens the PIN modification UI

### Requirement: Settings Screen wallet mode reset
The Settings Screen SHALL offer a "Reset Wallet Mode" setting option. Tapping this option SHALL prompt the user with a warning dialog stating that resetting will delete all local data. Only if the user explicitly confirms the reset, the application SHALL set the application mode to `AppMode.init` by calling `appContext.setAppMode(appMode: AppMode.init)` and return to the onboarding screen.

#### Scenario: Tapping Reset Wallet Mode and user cancels
- **WHEN** the user is on the Settings Screen, taps the "Reset Wallet Mode" option, and cancels the warning dialog
- **THEN** the application does NOT reset the wallet mode and remains on the Settings Screen

#### Scenario: Tapping Reset Wallet Mode and user confirms
- **WHEN** the user is on the Settings Screen, taps the "Reset Wallet Mode" option, and confirms the warning dialog
- **THEN** the application calls `appContext.setAppMode(appMode: AppMode.init)` and navigates back to the first-run onboarding screen



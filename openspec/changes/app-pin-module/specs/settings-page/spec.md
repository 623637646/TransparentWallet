## ADDED Requirements

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

## MODIFIED Requirements

### Requirement: Settings Screen wallet mode reset
The Settings Screen SHALL offer a "Reset Wallet Mode" setting option. Tapping this option SHALL prompt the user with a warning dialog stating that resetting will delete all local data. Only if the user explicitly confirms the reset, the application SHALL set the application mode to `AppMode.init` by calling `appContext.setAppMode(appMode: AppMode.init)` and return to the onboarding screen.

#### Scenario: Tapping Reset Wallet Mode and user cancels
- **WHEN** the user is on the Settings Screen, taps the "Reset Wallet Mode" option, and cancels the warning dialog
- **THEN** the application does NOT reset the wallet mode and remains on the Settings Screen

#### Scenario: Tapping Reset Wallet Mode and user confirms
- **WHEN** the user is on the Settings Screen, taps the "Reset Wallet Mode" option, and confirms the warning dialog
- **THEN** the application calls `appContext.setAppMode(appMode: AppMode.init)` and navigates back to the first-run onboarding screen


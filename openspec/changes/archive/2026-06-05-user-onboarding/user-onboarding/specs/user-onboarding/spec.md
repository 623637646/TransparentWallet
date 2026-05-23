## ADDED Requirements

### Requirement: First-run onboarding page redirection
The application SHALL listen to the `appModeStream` from `appContext` at startup. If the emitted mode is `AppMode.init`, the application SHALL display the onboarding screen.

#### Scenario: Launch application for the first time
- **WHEN** the application is launched and the `appModeStream` emits `AppMode.init`
- **THEN** the application displays the user onboarding carousel screen instead of throwing an UnimplementedError

### Requirement: Onboarding carousel swiping and UI design
The onboarding screen SHALL feature a swipeable carousel container displaying multi-page onboarding slides. The onboarding screens SHALL follow `DESIGN.md` styling:
- Text font families: `UberMove` for headers (display-lg, display-md), and `UberMoveText` for body text.
- Layout and margins: padding and spacing matching `DESIGN.md` base units (multiples of 4px).
- Styling: Flat white canvas (`#ffffff`) background, high contrast, clean geometry.
- Controls: Page indicators (dots/pills) showing current slide progress, with smooth transition animations.
- Localization: All text elements SHALL use `LocalizedText` referencing keys from the Fluent locales, Reacting dynamically to language switches.

#### Scenario: Swiping onboarding carousel slides
- **WHEN** the user swipes horizontally on the onboarding carousel screen
- **THEN** the active slide updates with a smooth animation and the page indicator updates to reflect the new slide index

### Requirement: Wallet mode selection and persistence
The final onboarding slide (or global layout actions) SHALL display two primary actions: "Cold Wallet" and "Hot Wallet". Selecting either option SHALL call `appContext.setAppMode` with the corresponding `AppMode` value (`AppMode.coldWallet` or `AppMode.hotWallet`). Once the app mode is set, the application SHALL automatically navigate to the chosen wallet execution screen.

#### Scenario: User selects Cold Wallet mode
- **WHEN** the user taps the "Cold Wallet" button on the onboarding carousel screen
- **THEN** the application calls `appContext.setAppMode(appMode: AppMode.coldWallet)` and updates the UI stream to display the Cold Wallet interface

#### Scenario: User selects Hot Wallet mode
- **WHEN** the user taps the "Hot Wallet" button on the onboarding carousel screen
- **THEN** the application calls `appContext.setAppMode(appMode: AppMode.hotWallet)` and updates the UI stream to display the Hot Wallet interface

# User Onboarding

## Purpose
Handles the first-run onboarding carousel user experience and execution mode selection (Cold Wallet / Hot Wallet).
## Requirements
### Requirement: First-run onboarding page redirection
The application SHALL listen to the `appModeStream` from `appContext` at startup. If the emitted mode is `AppMode.init`, the application SHALL display the onboarding screen.

#### Scenario: Launch application for the first time
- **WHEN** the application is launched and the `appModeStream` emits `AppMode.init`
- **THEN** the application displays the user onboarding carousel screen instead of throwing an UnimplementedError

### Requirement: Onboarding carousel swiping and UI design
The onboarding screen SHALL feature a swipeable carousel container displaying 4 onboarding slides (Welcome, Cold Wallet Details, Hot Wallet Details, and Choose Mode). The onboarding screens SHALL follow `DESIGN.md` styling:
- Text font families: SF Pro Display / SF Pro Text (with Inter fallback) as defined in DesignTokens.
- Layout and margins: padding and spacing matching `DESIGN.md` base units (multiples of 4px).
- Styling: Flat white canvas (`#ffffff`) background, high contrast, clean geometry.
- Controls: Page indicators (dots/pills) showing current slide progress, with smooth transition animations. The indicators SHALL be positioned at the bottom of the controls area, below the actions.
- Bottom actions: The bottom controls and actions area MUST maintain a stable layout height of 180px across all slides (with no buttons displayed on earlier pages, and mode selection buttons displayed on the final page) to prevent vertical shifts of page indicators and slide contents during swiping.
- Localization: All text elements SHALL use `LocalizedText` referencing keys from the Fluent locales, reacting dynamically to language switches.

#### Scenario: Swiping onboarding carousel slides
- **WHEN** the user swipes horizontally on the onboarding carousel screen
- **THEN** the active slide updates with a smooth animation, the page indicator updates to reflect the new slide index, and the vertical position of page indicators remains completely stable with no layout shift.

### Requirement: Wallet mode selection and persistence
The final onboarding slide SHALL transition the bottom controls area to display two primary actions: "Cold Wallet" (elevated primary button) and "Hot Wallet" (outlined secondary button). Selecting either option SHALL call `appContext.setAppMode` with the corresponding `AppMode` value (`AppMode.coldWallet` or `AppMode.hotWallet`). Once the app mode is set, the application SHALL automatically navigate to the chosen wallet execution screen.
The transition between the empty action space on earlier slides and the stacked wallet mode buttons on the final slide MUST be animated smoothly using `AnimatedSwitcher` without modifying the height of the bottom controls container.

#### Scenario: User selects Cold Wallet mode
- **WHEN** the user taps the "Cold Wallet" button on the onboarding carousel screen
- **THEN** the application calls `appContext.setAppMode(appMode: AppMode.coldWallet)` and updates the UI stream to display the Cold Wallet interface

#### Scenario: User selects Hot Wallet mode
- **WHEN** the user taps the "Hot Wallet" button on the onboarding carousel screen
- **THEN** the application calls `appContext.setAppMode(appMode: AppMode.hotWallet)` and updates the UI stream to display the Hot Wallet interface


### Requirement: Language selection and configuration during onboarding
The onboarding screen SHALL feature a language selection button displaying the currently active language (e.g. "English" or "简体中文"). When the user taps the language selection button, the application SHALL display a modal bottom sheet popup showing all available language options (English, Chinese) and a "System Language" option. Selecting an option SHALL trigger `appContext.setLanguage`. Specifically:
- If the user selects "System Language", the application SHALL call `appContext.setLanguage(language: null)`.
- If the user selects a specific language, the application SHALL call `appContext.setLanguage(language: Language.<selected>)`.
The language selection button SHALL dynamically display the actual resolved/effective language (e.g., "English" or "简体中文") in the current UI language, regardless of whether the selected language setting is a specific language or set to "System Language".

#### Scenario: Displaying current resolved language on onboarding screen
- **WHEN** the application is on the onboarding screen and the active language resolved by the system is Chinese
- **THEN** the language selection button displays "简体中文"

#### Scenario: Selecting a specific language from bottom sheet
- **WHEN** the user taps the language selection button, selects "English" from the bottom sheet
- **THEN** the application calls `appContext.setLanguage(language: Language.english)` and the UI updates to English

#### Scenario: Selecting System Language from bottom sheet
- **WHEN** the user taps the language selection button, selects "System Language" from the bottom sheet
- **THEN** the application calls `appContext.setLanguage(language: null)` and the UI language updates to match the system language



## MODIFIED Requirements

### Requirement: Onboarding carousel swiping and UI design
The onboarding screen SHALL feature a swipeable carousel container displaying 4 onboarding slides (Welcome, Cold Wallet Details, Hot Wallet Details, and Choose Mode). The onboarding screens SHALL follow `DESIGN.md` styling:
- Text font families: `UberMove` for headers (display-lg, display-md), and `UberMoveText` for body text.
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

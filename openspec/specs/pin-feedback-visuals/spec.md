# PIN Feedback Visuals (Toast Notifications)

## Purpose
Provides a reusable top-floating Toast notification system and integrates it with PIN operations.

## Requirements

### Requirement: Reusable top-floating Toast notification
The system SHALL provide a reusable `Toast` component that displays messages floating at the top of the screen.
- The Toast notification MUST overlay all other UI elements, positioned near the top of the screen (below the system status bar).
- The Toast notification SHALL feature an entry and exit animation (e.g., slide down/up or fade).
- The Toast notification SHALL support visual styling matching the active theme context (background color, typography, border radius).

#### Scenario: Displaying Toast notification
- **WHEN** a Toast notification is triggered with a message
- **THEN** the Toast animates into view at the top of the screen, floating above the current UI.

### Requirement: Non-blocking Toast interactions
The `Toast` overlay MUST NOT intercept or block touch gestures/events intended for the underlying UI.
- The Toast overlay widget tree SHALL be configured to pass all touch interactions through to the active screen widgets beneath it, except optionally taps on the Toast itself if interactive behavior is desired.
- The user MUST be able to tap, scroll, and interact with the background UI normally while the Toast is visible.

#### Scenario: Interacting with UI while Toast is visible
- **WHEN** a Toast is displayed on the screen
- **THEN** the user can tap background buttons, scroll lists, and perform underlying UI actions without interference from the Toast.

### Requirement: Dynamic Toast auto-dismiss duration
The `Toast` notification SHALL automatically dismiss itself after a duration calculated dynamically based on the length of the message text.
- The display duration SHALL scale with the message text length.
- A base duration of at least 1500 milliseconds SHALL be applied.
- The calculation formula SHALL ensure longer messages remain on screen for a longer duration to allow complete reading, up to a maximum cap (e.g., 4000 milliseconds).

#### Scenario: Auto-dismissing short message Toast
- **WHEN** a Toast is displayed with a short message (e.g., "PIN verified")
- **THEN** it automatically dismisses itself after a short calculated duration (e.g., ~1500ms).

#### Scenario: Auto-dismissing long message Toast
- **WHEN** a Toast is displayed with a longer message
- **THEN** it automatically dismisses itself after a longer calculated duration (e.g., ~3000ms).

### Requirement: PIN operation Toast integration
Upon successful completion of any PIN operation (creation, modification, verification) in `PinBottomSheet`:
- The bottom sheet SHALL be dismissed immediately.
- A success `Toast` notification displaying the corresponding localized success message SHALL be triggered at the top of the screen.

#### Scenario: PIN creation success toast
- **WHEN** the user successfully creates a PIN
- **THEN** the bottom sheet closes immediately, and a success Toast showing "PIN created" is displayed at the top of the screen.

#### Scenario: PIN modification success toast
- **WHEN** the user successfully modifies their PIN
- **THEN** the bottom sheet closes immediately, and a success Toast showing "PIN modified" is displayed at the top of the screen.

#### Scenario: PIN verification success toast
- **WHEN** the user successfully verifies their current PIN
- **THEN** the bottom sheet closes immediately, and a success Toast showing "PIN verified" is displayed at the top of the screen.

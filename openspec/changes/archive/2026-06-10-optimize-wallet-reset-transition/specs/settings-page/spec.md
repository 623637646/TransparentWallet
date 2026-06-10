## MODIFIED Requirements

### Requirement: Settings Screen wallet mode reset
The Settings Screen SHALL offer a "Reset Wallet Mode" setting option. Tapping this option SHALL trigger a complete application reset by:
1. Invoking `appContext.resetApp()`, which resets the database and clears the secure storage in the Rust layer.
2. Invalidating the `appContextProvider` Riverpod provider to trigger reinitialization of a fresh application context.
The Settings Screen itself SHALL NOT perform manual navigation or route popping to return to the onboarding screen.

#### Scenario: Tapping Reset Wallet Mode returns to onboarding screen
- **WHEN** the user is on the Settings Screen, taps the "Reset Wallet Mode" option, and confirms the reset dialog
- **THEN** the application invokes `appContext.resetApp()`, invalidates `appContextProvider`, and the page remains passive, relying on root mode transition to clean the route stack

## MODIFIED Requirements

### Requirement: Settings Screen wallet mode reset
The Settings Screen SHALL offer a "Reset Wallet Mode" setting option. Tapping this option SHALL trigger a complete application reset by:
1. Invoking `appContext.resetApp()`, which resets the database and clears the secure storage in the Rust layer.
2. Popping all routes from the navigation stack back to the root.
3. Invalidating the `appContextProvider` Riverpod provider to trigger reinitialization of a fresh application context.
Upon completion, the application SHALL directly return to the onboarding screen with the new context.

#### Scenario: Tapping Reset Wallet Mode returns to onboarding screen
- **WHEN** the user is on the Settings Screen and taps the "Reset Wallet Mode" option
- **THEN** the application invokes `appContext.resetApp()`, pops the navigation stack, invalidates `appContextProvider`, and displays the onboarding screen using a fresh app context

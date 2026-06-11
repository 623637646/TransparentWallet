## ADDED Requirements

### Requirement: Global loading overlay integration during PIN processing
During PIN creation, modification, or verification processing, the `PinBottomSheet` SHALL trigger the global loading overlay to block user interactions and screen dismissal.

#### Scenario: Global loading overlay displayed during PIN verification
- **WHEN** the user submits the PIN for verification
- **THEN** the global loading overlay SHALL be displayed, blocking all gestures and preventing dismissal of the bottom sheet until processing completes.

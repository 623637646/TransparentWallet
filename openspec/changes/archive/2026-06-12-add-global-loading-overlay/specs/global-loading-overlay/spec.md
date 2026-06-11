## ADDED Requirements

### Requirement: Global loading overlay display
The system SHALL support displaying a full-screen, gesture-blocking loading overlay when active.
- The overlay MUST blur the underlying content (e.g., using `BackdropFilter`).
- The overlay MUST absorb all touch gestures and tap events to prevent interactions with widgets underneath it.
- The overlay SHALL sit above all routes, dialogs, and modal bottom sheets.
- The overlay SHALL feature a high-fidelity animated spinner without text.

#### Scenario: Loading overlay blocks gesture input
- **WHEN** the global loading overlay is active
- **THEN** all gestures (taps, swipes) are blocked, and no interaction with background widgets or bottom sheets is allowed.

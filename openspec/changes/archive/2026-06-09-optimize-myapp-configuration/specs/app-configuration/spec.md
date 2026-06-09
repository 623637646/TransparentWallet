## ADDED Requirements

### Requirement: Unified app tree structure
The system SHALL maintain a single, consistent root MaterialApp and design theme across the loading, error, and ready stream lifecycle states of the application.

#### Scenario: Transitioning from loading state to ready state
- **WHEN** the app mode stream transitions from loading to ready
- **THEN** the root widget tree remains mounted, the MaterialApp element is reused, and the navigator state is preserved without any flicker.

### Requirement: Centralized design tokens for error styling
The system SHALL use design tokens typography settings instead of hardcoding text styles when rendering the error display screen.

#### Scenario: Rendering the error state display
- **WHEN** the FFI stream encounters an error and the error screen is shown
- **THEN** the error message is styled using typography parameters from DesignTokens.typography.

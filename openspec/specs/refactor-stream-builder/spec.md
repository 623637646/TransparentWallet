# Refactor Stream Builder

Purpose: Encapsulation of FFI subscription stream logic and transition to a unified reactive builder widget.

## Requirements

### Requirement: Encapsulate Stream Conversion
The system SHALL encapsulate the FFI stream conversion logic inside `RustStreamBuilder` as a private helper.

#### Scenario: Subscribing to FFI stream
- **WHEN** a widget uses `RustStreamBuilder` to subscribe to a Rust stream
- **THEN** the subscription is managed reactively and disposed of automatically on widget destruction.

# FFI Hook Logging Spec

## Purpose
Define requirements for zero-boilerplate middleware and logging hooks at the FFI boundary between Dart and Rust, enabling automatic intercepting, logging, execution timing, and sensitive parameter redaction.

## Requirements

### Requirement: FFI Call Interception
The system SHALL intercept all asynchronous and synchronous Dart-Rust FFI calls.

#### Scenario: Intercept FFI calls
- **WHEN** Dart initiates an asynchronous or synchronous FFI call to Rust
- **THEN** the FFI logging hook intercepts the execution and outputs a start log with the FFI method name and masked parameters

### Requirement: Sensitive Parameter Redaction
The system SHALL mask sensitive parameters (such as PINs, passwords, secrets, private keys, and seeds) in FFI arguments before logging.

#### Scenario: Redact sensitive parameters
- **WHEN** Dart calls an FFI method passing arguments that contain sensitive keys (e.g., "pin", "oldPin", "newPin", "secret", "password", "key", "seed")
- **THEN** the FFI logging hook replaces their values with "<REDACTED>" in the log output

### Requirement: FFI Timing Measurement
The system SHALL measure and log the execution duration in milliseconds for each FFI call.

#### Scenario: Log successful call timing
- **WHEN** an FFI call completes successfully
- **THEN** the FFI logging hook outputs a success log message specifying the elapsed time in milliseconds

#### Scenario: Log failed call timing
- **WHEN** an FFI call fails and throws an error
- **THEN** the FFI logging hook outputs an error log message specifying the elapsed time in milliseconds along with the error and stack trace

### Requirement: FFI Callback Interception
The system SHALL intercept and log Dart functions invoked from Rust via FFI.

#### Scenario: Log Rust-to-Dart callback
- **WHEN** Rust invokes a Dart callback function via FFI
- **THEN** the FFI logging hook logs the callback invocation event along with its arguments

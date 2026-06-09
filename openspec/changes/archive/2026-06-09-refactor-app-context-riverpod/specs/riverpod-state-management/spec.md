# Riverpod State Management Spec

## ADDED Requirements

### Requirement: Centralized app context provider
The system SHALL expose the initialized FFI `Context` through a Riverpod provider named `appContextProvider`.

#### Scenario: Accessing context in UI components
- **WHEN** a widget needs to access the Rust core `Context`
- **THEN** it SHALL retrieve it from `appContextProvider` via Riverpod `WidgetRef` or `ConsumerState` instead of using a global variable.

### Requirement: Automatic context injection in stream builder
The `RustStreamBuilder` widget SHALL automatically read the `Context` from the Riverpod `appContextProvider` and pass it to the subscription builder callback.

#### Scenario: Subscribing to FFI stream
- **WHEN** a widget builds a `RustStreamBuilder` without passing a manual context
- **THEN** `RustStreamBuilder` SHALL retrieve the FFI `Context` from `appContextProvider` and successfully initialize the subscription.

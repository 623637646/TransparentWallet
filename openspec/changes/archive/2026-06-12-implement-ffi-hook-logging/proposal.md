## Why

Currently, there is no centralized logging mechanism for Dart-Rust FFI interactions. Adding logging manually to each FFI API call is tedious, error-prone, and leads to code duplication. Implementing a centralized FFI logging hook will improve debuggability, allow tracking execution durations of FFI calls, and ease tracking down FFI issues across the bridge, without modifying individual API signatures or implementations.

## What Changes

- Add a custom `BaseHandler` implementation (`CustomLoggingHandler`) to intercept all Dart-Rust FFI executions.
- Hook into asynchronous task executions (`executeNormal`), synchronous task executions (`executeSync`), and Dart callback invocations from Rust (`dartFnInvoke`).
- Inject execution duration measurements for all FFI tasks.
- Implement an argument masking system to dynamically filter out sensitive data (such as PINs or credentials) before printing them to the logs.
- Register `CustomLoggingHandler` during `RustLib.init()` inside the application startup (`main.dart`).

## Capabilities

### New Capabilities
- `ffi-hook-logging`: Centralized, automatic FFI logging with execution timing and sensitive data masking.

### Modified Capabilities

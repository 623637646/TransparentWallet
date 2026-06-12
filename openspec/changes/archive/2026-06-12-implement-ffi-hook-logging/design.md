## Context

The application uses `flutter_rust_bridge` (v2.12.0) to bind Flutter/Dart with a Rust back-end. FFI calls represent critical business logic (PIN verification, secure storage access, settings modification, database initialization, etc.). Currently, there is no automatic global logging of FFI calls, making FFI performance tracing and parameter/exception debugging manual and tedious.

## Goals / Non-Goals

**Goals:**
- Centralize logging of FFI call inputs, success/failure outputs, and execution duration.
- Dynamically detect and redact sensitive parameters (like PINs, seeds, keys) to prevent logging plain-text credentials.
- Intercept callback functions executed from Rust to Dart.

**Non-Goals:**
- Modifying individual generated FFI wrappers.
- Writing custom logger wrappers around each Dart repository call.
- Implementing custom handlers/thread pools on the Rust side (we will keep the standard Rust-side `DefaultHandler` execution).

## Decisions

### Decision 1: Subclass `BaseHandler` in Dart
- **Rationale:** `flutter_rust_bridge`'s generated entrypoint `RustLib.init()` accepts a custom `BaseHandler` instance. Extending `BaseHandler` allows us to override `executeNormal` (for async calls) and `executeSync` (for sync calls) to transparently wrap all calls with logging and time-tracking logic.
- **Alternatives Considered:** 
  1. Creating a custom FFI wrapper function for every call: Rejected due to significant boilerplate and difficulty keeping up with new generated code.
  2. Subclassing `FLUTTER_RUST_BRIDGE_HANDLER` on the Rust side: Rejected because Rust-side logging doesn't easily integrate with Dart's `logger` package configuration (color formatting, platform-specific outputs) and makes parameter inspection harder.

### Decision 2: Dynamic Name-Based Argument Redaction
- **Rationale:** By converting the task argument keys to lowercase and checking for substrings (like `pin`, `password`, `secret`, `key`, `seed`), we can dynamically redact sensitive fields without maintaining an explicit list of sensitive methods.
- **Alternatives Considered:**
  1. No redaction: Rejected due to high risk of exposing user PINs and credentials in application logs.
  2. Explicit method-based filter lists: Rejected as it is highly error-prone and easy to forget when new sensitive FFI endpoints are added.

## Risks / Trade-offs

- **[Risk] Logging overhead** → *Mitigation:* The logging and redaction logic is extremely lightweight (simple dictionary loop and key matching), adding sub-microsecond latency, which is negligible compared to the FFI serialization/deserialization overhead.
- **[Risk] Exposing sensitive binary payloads** → *Mitigation:* The word-matching filter is case-insensitive and checks for broad substrings. Any parameter containing keywords like `key`, `seed`, or `pin` will be completely replaced by `<REDACTED>`.

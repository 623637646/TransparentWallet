# Development Guidelines

If any requirements are unclear, please ask for clarification before proceeding.

## 1. Understand the Project

Refer to README.md for general project information.

Refer to the **Directory Structure** section in this document to understand the project's layout. Familiarize yourself with the purpose of each directory and file, and identify which modules should be reused to avoid duplication.

## 2. UI Development

This section apply specifically to UI development. You may ignore this section if your task does not involve the UI.

### 2.1. Design

- Refer to `DESIGN.md` for UI design specifications. Remember that your design should be in line with the **Flutter mobile** user experience. 

### 2.2. UI Coding

Implement the UI strictly according to the design.

- **Component Reusability**: Pay attention to the reuse of UI components. During development, if a component might be reused by multiple modules, abstract it out and place it in an appropriate location.
- **Reactive Rendering**: Use `StreamBuilder` to consume the `Stream` returned by `convertSubscriptionToStream` to drive UI updates.
- **Internationalization (i18n)**: All user-visible text must be internationalized with no hardcoded strings.
  - **References**:
    - Widget wrapper: `lib/src/widgets/common/localized_text.dart`
    - Locale resources: `rust_wallet/locales/`
  - **Maintenance**: Promptly update multi-language files when adding or modifying text. Regularly clean up the locale resources by deleting invalid or obsolete translation data, and correct any problematic or inaccurate entries.

## 3. Logging

Add logging to critical business paths and error-handling blocks to ensure issues are easily traceable.

| Language | Tool |
|----------|------|
| Dart     | `lib/src/utils/logger.dart` |
| Rust     | `log` crate |

## 4. Build

Ensure the project builds successfully locally. Resolve any compilation errors before marking a task as complete.

## 5. Testing

Run the local test suite and verify that all tests pass before marking a task as complete.

## 6. Update Directory Structure

Before completing a task, verify if your changes affect the **Directory Structure** section of this document. If new files or directories are added, or existing ones modified, update the documentation accordingly.

---

# Directory Structure

## Requirements

This section serves the following purposes:
1. Provides a comprehensive and detailed overview of the directory and file structure within the following paths:
   - `/lib`
   - `/rust`
   - `/rust_secret/src`
   - `/rust_wallet/src`
2. Outlines a one-sentence summary of when this file should be involved? Note, it's not about summarizing the function of each API inside.
3. Ignores the following files: 
   - auto-generated files.

## Contents

```
janus_wallet/
│
│── ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ FLUTTER / DART LAYER ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
│
├── lib/
│   ├── main.dart                          — Modify this file when changing the global app initialization sequence or startup configurations.
│   │
│   └── src/
│       ├── utils/                         — Modify files here when adding or updating reusable Dart utilities.
│       │   ├── app_context.dart           — Modify this file when changing how the global appContext, secure storage, or system languages are initialized.
│       │   ├── bridge_helper.dart         — Import this utility whenever you need to consume Rust observable streams within a Flutter StreamBuilder.
│       │   ├── logger.dart                — Import this file whenever you need to log messages from the Dart side.
│       │   └── secure_storage.dart        — Modify this file when updating platform-specific secure storage options or wrappers.
│       │
│       └── widgets/                       — Add or modify files here when developing Flutter UI components.
│           ├── my_app.dart                — Modify this file when updating the root material app configuration, routing, or global theme.
│           ├── onboarding_screen.dart     — Modify this file when changing the horizontal onboarding slides, page indicators, or mode selection.
│           ├── cold_wallet_home.dart      — Modify this file when changing the layout or actions of the cold wallet dashboard placeholder.
│           ├── hot_wallet_home.dart       — Modify this file when changing the layout or actions of the hot wallet dashboard placeholder.
│           │
│           └── common/                    — Add new widgets here when they are meant to be reused across multiple UI modules.
│               └── localized_text.dart    — Use this widget for all user-visible text to ensure reactive i18n rendering.
│
│── ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ RUST FFI BRIDGE ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
│
├── rust/                                  — Modify this crate when exposing new Rust functionality to Dart.
│   └── src/
│       ├── lib.rs                         — Modify this file when adding new top-level FFI modules.
│       │
│       ├── api/                           — Add or modify files here when creating new FFI endpoints for Dart to call.
│       │   ├── mod.rs                     — Modify this file when adding new API modules to the FFI layer.
│       │   ├── context.rs                 — Modify this file when adding new Context methods or altering the Rust initialization flow.
│       │   ├── app_mode.rs                — Modify this file when exposing new app mode functionality to Dart.
│       │   ├── localization.rs            — Modify this file when exposing new localization features or language queries to Dart.
│       │   ├── logger.rs                  — Modify this file when changing how the Rust logger is initialized or exposed to Dart.
│       │   └── pin.rs                     — Modify this file when exposing new PIN management operations to Dart.
│       │
│       └── utils/                         — Modify files here when updating FFI utility types.
│           ├── mod.rs                     — Modify this file when adding new FFI utility modules.
│           ├── bridge_helper.rs           — Use this pattern when exposing new rx-rust Observable streams to Dart.
│           └── never.rs                   — Reference this file when wrapping Infallible types for FRB compatibility.
│
│── ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ RUST CORE LIBRARIES ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
│
├── rust_wallet/                           — Modify this crate when updating core wallet business logic or database interactions.
│   └── src/
│       ├── lib.rs                         — Modify this file when adding new modules to the core wallet crate.
│       ├── app.rs                         — Modify this file when changing the top-level app container or its initialized managers.
│       ├── error.rs                       — Modify this file when defining new wallet-level error types.
│       ├── logger.rs                      — Modify this file when changing how Rust logs are formatted or streamed to Dart.
│       │
│       └── managers/                      — Add new modules here when introducing new business logic entities.
│           ├── mod.rs                     — Modify this file when registering new business logic managers.
│           │
│           ├── db.rs                      — Modify this file when changing global database configurations or memory DB test setups.
│           │
│           ├── secure_storage.rs          — Modify this file when changing the secure storage trait or its Dart-provided closures.
│           │
│           ├── app_mode/                  — Modify files in this directory when changing how the app mode is managed or persisted.
│           │   ├── mod.rs                 — Modify this file when adding submodules to the app mode manager.
│           │   ├── entities.rs            — Modify this file when updating the sea-orm database schema for the app mode.
│           │   └── manager.rs             — Modify this file when altering the logic for getting or setting the app mode.
│           │
│           ├── localization/              — Modify files in this directory when changing how translations are loaded or resolved.
│           │   ├── mod.rs                 — Modify this file when adding submodules to the localization manager.
│           │   ├── entities.rs            — Modify this file when updating the sea-orm database schema for localization.
│           │   └── manager.rs             — Modify this file when changing the logic for reactive i18n lookups.
│           │
│           └── pin/                       — Modify files in this directory when updating PIN security or verification logic.
│               ├── mod.rs                 — Modify this file when adding submodules to the pin manager.
│               ├── entities.rs            — Modify this file when updating the sea-orm database schema for PIN data.
│               └── manager.rs             — Modify this file when updating PIN creation, verification, or failure-tracking logic.
│
└── rust_secret/                           — Modify this crate when updating low-level cryptographic primitives.
    └── src/
        ├── lib.rs                         — Modify this file when exposing new cryptographic modules.
        ├── secret_context.rs              — Modify this file when altering core security context logic, keypairs, or encryption flows.
        ├── asymmetric.rs                  — Modify this file when changing ECDH or AES-GCM asymmetric encryption protocols.
        ├── symmetric.rs                   — Modify this file when updating symmetric AES-256-GCM encryption implementations.
        ├── pin_key.rs                     — Modify this file when altering Argon2 key derivation parameters.
        └── nonce.rs                       — Modify this file when changing how cryptographic random nonces are generated.
```
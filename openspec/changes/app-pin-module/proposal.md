## Why

A PIN-based authentication mechanism is essential for securing wallet operations, ensuring that sensitive activities (such as viewing critical data or resetting the wallet mode) are protected from unauthorized access.

## What Changes

- Add a bottom-sheet based 6-digit PIN input and validation UI.
- Support PIN creation flow with confirmation logic.
- Support PIN verification flow (for custom actions or third-party callers).
- Support PIN modification flow, verifying the old PIN before creating the new PIN.
- Update Settings Page to show "Create PIN" or "Modify PIN" dynamically based on whether a PIN is currently set.
- Add PIN verification flow before executing the "Reset Wallet Mode" operation, if a PIN has been set.

## Capabilities

### New Capabilities
- `app-pin-security`: Implements a 6-digit numeric PIN entry, verification, and modification bottom sheet module, providing APIs to verify and manage PIN state.

### Modified Capabilities
- `settings-page`: Adds a PIN action item (Create/Modify) and integrates PIN verification before resetting the wallet mode if a PIN is configured.

## Impact

- **UI**: Added PIN bottom sheet overlays, updated `SettingsScreen`.
- **Rust/FFI**: Consume the existing `pin_manager` methods (`has_pin_stream`, `create_pin`, `update_pin`, `verify_pin`) in Flutter via `appContext`.
- **Localization**: Added translation strings for PIN creation, verification, modification, error hints, and settings buttons in `zh` and `en` locales.

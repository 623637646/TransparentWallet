## Why

PIN module operations (creation, modification, verification) involve cryptographic key derivation (Argon2) and secure storage access. During these asynchronous operations, the user can currently dismiss the bottom sheet or tap other keys, creating race conditions. A global loading overlay is needed to temporarily block all user gestures and sit on top of all pages until processing completes.

## What Changes

- Implement a declarative Riverpod-based loading state provider.
- Implement a custom, high-fidelity `GlobalLoadingOverlay` that blurs the background and absorbs all user gestures.
- Inject the overlay into `MaterialApp.builder` to ensure it sits on top of all pages, dialogs, and bottom sheets.
- Update the PIN bottom sheet to set the loading state during processing, blocking gestures and preventing sheet dismissal.

## Capabilities

### New Capabilities
- `global-loading-overlay`: A new global overlay system that blocks user gestures and displays a high-fidelity visual loading state.

### Modified Capabilities
- `pin-feedback-visuals`: Update the PIN submission feedback loops to use the global loading overlay during processing.

## Impact

- `lib/src/widgets/my_app.dart`: Sits the overlay above the app navigators.
- `lib/src/widgets/common/pin_bottom_sheet.dart`: Triggers the global loading overlay state.
- `lib/src/widgets/common/loading_overlay.dart` (New): Defines the loading provider and high-fidelity custom spinner overlay UI.

## Why

Currently, when a user successfully completes a PIN operation (creation, modification, verification), there is no visual feedback. To solve this in an elegant, non-blocking way, we need a reusable, top-floating Toast notification system that informs the user without interrupting their flow or blocking interactions with the underlying UI.

## What Changes

- Create a reusable, independent floating `Toast` component that displays at the very top of the screen.
- The `Toast` component will meet the following requirements:
  - **Auto-dismiss**: Automatically hides after a calculated duration.
  - **Non-blocking**: Uses `IgnorePointer` to ensure it does not block user gestures/interactions with the underlying screen.
  - **Dynamic duration**: Computes show duration based on message length (e.g., longer messages stay visible longer).
  - **Independent/Reusable**: Placed in a shared UI utility class/widget.
- Integrate the `Toast` component with `PinBottomSheet` so that when a PIN operation succeeds, a success toast is triggered immediately, and the bottom sheet dismisses itself.

## Capabilities

### New Capabilities
- `toast-notifications`: Specifies the requirements, behavior, and design for the reusable top-floating, non-blocking, dynamic-duration Toast notification component.
- `pin-toast-integration`: Specifies the integration requirements for launching Toast notifications when PIN operations successfully complete.

### Modified Capabilities

## Impact

- `lib/src/widgets/common/toast.dart`: New file containing the reusable `Toast` component and utility logic.
- `lib/src/widgets/common/pin_bottom_sheet.dart`: Integrate the `Toast` trigger upon successful PIN operations.
- Localization files under `rust_wallet/locales/`: Add/update Fluent keys for PIN operation success messages.

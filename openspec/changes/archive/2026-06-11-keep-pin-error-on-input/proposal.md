## Why

Currently, when a red reminder/error message (such as PIN mismatch or incorrect PIN) is displayed on the PIN bottom sheet, any subsequent user input (key tap or backspace) causes the error message to disappear immediately. This proposal preserves the error message during input to ensure the user remains aware of the error context until their next submission or flow transition.

## What Changes

- The error message displayed on the PIN screen will persist while the user enters or edits their next PIN attempt.
- The error message will not be cleared by numeric key taps or backspace taps in `PinBottomSheet`.
- The error message will be cleared only when transitioning between PIN steps/flows or when a new PIN verification attempt is submitted.

## Capabilities

### New Capabilities

<!-- No new capabilities are introduced by this change. -->

### Modified Capabilities

- `app-pin-security`: Update requirements for PIN flows to specify that error messages must persist during input and only clear on submit or flow transition.

## Impact

- `lib/src/widgets/common/pin_bottom_sheet.dart`: Modify state management to prevent clearing error messages during key input.

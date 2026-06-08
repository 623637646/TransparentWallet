## 1. Localization Update

- [x] 1.1 Add English localized strings for PIN actions (e.g., enter pin, mismatch, creation success, settings actions) in `rust_wallet/locales/en/main.ftl`
- [x] 1.2 Add Chinese localized strings for PIN actions in `rust_wallet/locales/zh/main.ftl`


## 2. Common Widget Implementation

- [x] 2.1 Create the `PinBottomSheet` stateful widget under `lib/src/widgets/common/pin_bottom_sheet.dart` with a custom grid-based numeric keypad
- [x] 2.2 Implement the PIN creation, confirmation, and error display logic using DesignTheme tokens
- [x] 2.3 Implement the FFI calls in `PinBottomSheet` for `createPin`, `updatePin`, and `verifyPin`


## 3. Settings Screen Integration

- [x] 3.1 Update `lib/src/widgets/settings_screen.dart` to display the PIN action item dynamically ("Create PIN" or "Modify PIN") based on the current PIN state stream
- [x] 3.2 Add navigation to show the `PinBottomSheet` for creation/modification when tapping the PIN action item
- [x] 3.3 Update the "Reset Wallet Mode" action in `lib/src/widgets/settings_screen.dart` to verify the PIN first if a PIN is configured, and only proceed on success


## 4. Verification

- [x] 4.1 Verify that the Flutter application compiles successfully
- [x] 4.2 Run tests and verify that the UI works and resets appropriately


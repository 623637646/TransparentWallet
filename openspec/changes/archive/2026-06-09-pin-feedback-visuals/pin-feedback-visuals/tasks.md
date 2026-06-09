## 1. Localization Setup

- [x] 1.1 Add/verify success message keys (`pin-create-success`, `pin-modify-success`, `pin-verify-success`) in `rust_wallet/locales/en/main.ftl`
- [x] 1.2 Add/verify success message keys (`pin-create-success`, `pin-modify-success`, `pin-verify-success`) in `rust_wallet/locales/zh/main.ftl`

## 2. Reusable Toast Widget

- [x] 2.1 Create the reusable `Toast` API and private stateful `_ToastWidget` in `lib/src/widgets/common/toast.dart`
- [x] 2.2 Implement the FFI localization subscription and dynamic timer in `_ToastWidget`
- [x] 2.3 Implement the slide-down/fade animations and `IgnorePointer(ignoring: true)` overlay structure in `toast.dart`

## 3. PIN Bottom Sheet Integration

- [x] 3.1 Integrate the `Toast.show` triggers into the success paths of `PinBottomSheet` in `lib/src/widgets/common/pin_bottom_sheet.dart`
- [x] 3.2 Ensure the bottom sheet closes immediately on success, delegating visual feedback to the Toast

## 4. Formatting & Verification

- [x] 4.1 Format modified Dart files using `dart format`
- [x] 4.2 Verify compile and run: show PIN bottom sheet and test all success flows to verify the Toast works as expected and doesn't block gestures

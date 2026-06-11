## 1. PinBottomSheet State Code Modification

- [x] 1.1 Remove error message state clearing from `_onKeyTap` in `lib/src/widgets/common/pin_bottom_sheet.dart`
- [x] 1.2 Remove error message state clearing from `_onBackspace` in `lib/src/widgets/common/pin_bottom_sheet.dart`
- [x] 1.3 Add explicit error state clearing in `_onSubmit` when transitioning to confirmation step (`PinStep.createConfirmNew`)
- [x] 1.4 Add explicit error state clearing in `_onSubmit` when transitioning to new PIN step in modify flow (`PinStep.createEnterNew`)

## 2. Formatting and Verification

- [x] 2.1 Format modified Dart source code files with `dart format`
- [x] 2.2 Verify the project builds and runs successfully

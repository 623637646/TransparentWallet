## 1. Setup and Loading Overlay Implementation

- [x] 1.1 Create `lib/src/widgets/common/loading_overlay.dart` defining the Riverpod `globalLoadingProvider` and UI.
- [x] 1.2 Implement `GlobalLoadingOverlay` using `BackdropFilter` (blur: 8.0) and `AbsorbPointer` to block all interactions.
- [x] 1.3 Implement `ElegantSpinner` custom painter rotating animation without any text.

## 2. Global Integration

- [x] 2.1 Modify `lib/src/widgets/my_app.dart` to include `GlobalLoadingOverlay` in `MaterialApp.builder` of `_buildApp`.
- [x] 2.2 Ensure the overlay functions correctly during transition state animations in `AppModeRevealSwitcher`.

## 3. PIN Bottom Sheet Integration

- [x] 3.1 Modify `lib/src/widgets/common/pin_bottom_sheet.dart` to import `globalLoadingProvider` and toggle it to `true` inside `_onSubmit()`, wrapping it in a `try...finally` block.
- [x] 3.2 Remove the legacy inline `CircularProgressIndicator` and related layout constraints from the PIN sheet.

## 4. Verification and Formatting

- [x] 4.1 Verify the app builds and runs successfully.
- [x] 4.2 Run `dart format` on all modified Dart files.
- [x] 4.3 Update the directory structure in `AGENTS.md`.

## 1. UI Layer Modification

- [x] 1.1 Update the reset wallet mode action in `lib/src/widgets/settings_screen.dart` to await `appContext.resetApp()`.
- [x] 1.2 Add logic in `lib/src/widgets/settings_screen.dart` to pop the navigator stack back to the root page.
- [x] 1.3 Call `ref.invalidate(appContextProvider)` in `lib/src/widgets/settings_screen.dart` to trigger fresh app context creation.
- [x] 1.4 Add `skipLoadingOnRefresh: false` in `my_app.dart` to force unmounting old stream builder on provider invalidation.

## 2. Verification and Testing

- [x] 2.1 Run the Flutter app and verify that pressing the "Reset Wallet Mode" button clears the database and redirects the user back to the onboarding screen.
- [x] 2.2 Verify that the app context is completely re-created and there are no FFI errors or crashes after reset.
- [x] 2.3 Run local test suite to ensure that all tests pass successfully.
- [x] 2.4 Update the directory structure in `AGENTS.md` to match the latest changes.

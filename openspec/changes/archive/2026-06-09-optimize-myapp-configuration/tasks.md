## 1. Refactor Root App Layout

- [x] 1.1 Add private `_buildApp` helper method in `lib/src/widgets/my_app.dart` to unify `DesignTheme` and `MaterialApp` structures.
- [x] 1.2 Update the `loadingBuilder`, `errorBuilder`, and `builder` callbacks in `RustStreamBuilder` inside `lib/src/widgets/my_app.dart` to use the `_buildApp` helper.
- [x] 1.3 Replace hardcoded typography parameters (fontFamily, fontSize) in the error state of `my_app.dart` with design tokens from `DesignTokens.typography`.

## 2. Verification and Testing

- [x] 2.1 Run local compiler / static analyzer to ensure no compiler warnings or errors are introduced.
- [x] 2.2 Verify app launch and state switching (Onboarding / Cold Wallet / Hot Wallet) visually to check for flicker-free transitions.
- [x] 2.3 Run tests to verify the suite passes.

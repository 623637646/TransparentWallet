## 1. Setup Theme Provider

- [x] 1.1 Implement the `DesignTheme` `InheritedWidget` inside `lib/src/utils/design_tokens.dart`.
- [x] 1.2 Refactor `lib/src/widgets/my_app.dart` to hoist `StreamBuilder<AppMode>`, wrap the application with `DesignTheme`, and dynamically configure `ThemeData`.

## 2. Refactor Onboarding Screen

- [x] 2.1 Refactor `lib/src/widgets/onboarding_screen.dart` to consume design tokens for background, typography, and button configurations.
- [x] 2.2 Refactor onboarding button widgets to consume `buttonPrimary` and custom outlines from design tokens.
- [x] 2.3 Refactor page indicators, typography headers, body styles, and animation container shapes to use design tokens.

## 3. Refactor Wallet Dashboard Screens

- [x] 3.1 Refactor `lib/src/widgets/cold_wallet_home.dart` to consume design tokens for scaffold background, text styles, and reset button styling.
- [x] 3.2 Refactor `lib/src/widgets/hot_wallet_home.dart` to consume design tokens for scaffold background, text styles, and reset button styling.

## 4. Verification

- [x] 4.1 Perform local Dart compilation and verify successful build.
- [x] 4.2 Run tests to ensure no regressions in onboarding or layout behaviors.

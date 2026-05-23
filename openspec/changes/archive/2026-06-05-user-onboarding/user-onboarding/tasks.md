## 1. Localization Setup

- [x] 1.1 Add onboarding and wallet mode localization keys to `rust_wallet/locales/en/main.ftl`
- [x] 1.2 Add onboarding and wallet mode localization keys to `rust_wallet/locales/zh/main.ftl`

## 2. Onboarding Screen Implementation

- [x] 2.1 Create the onboarding screen widget with a horizontally swipeable `PageView` layout
- [x] 2.2 Implement slide page indicators and layout complying with Uber-inspired design tokens in `DESIGN.md`
- [x] 2.3 Add action buttons ("Cold Wallet" and "Hot Wallet") that invoke `appContext.setAppMode` to set the selected wallet execution mode

## 3. App Routing Integration

- [x] 3.1 Implement simple `ColdWalletHome` and `HotWalletHome` placeholder screen widgets
- [x] 3.2 Update `lib/src/widgets/my_app.dart` to listen to `appModeStream` and perform reactive routing based on the active mode

## 4. Verification and Testing

- [x] 4.1 Verify code compiles and local tests pass
- [x] 4.2 Manually verify the user onboarding carousel flow, page swiping, localization updates, and wallet mode switching

# Quickstart: Welcome Mode Choice Onboarding

## Prerequisites
- Flutter stable channel (Dart 3.9) installed and configured.
- Rust toolchain 1.77+ with `cargo`.
- Mobile simulator/emulator or web target available.
- Localization files updated with new onboarding keys (EN + zh).

## Setup Steps
1. Run `flutter pub get` to ensure dependencies (including `flutter_secure_storage`) are installed.
2. Execute `cargo build --manifest-path rust/Cargo.toml` to confirm Rust crate compiles after onboarding additions.
3. Regenerate FFI bindings after introducing `onboarding.rs` changes:
   ```bash
   dart run flutter_rust_bridge:generate
   ```

## Running the Onboarding Flow
1. Clean install or reset app data to clear `FirstRunState`:
   ```bash
   flutter run --dart-define=RESET_FIRST_RUN=true
   ```
   (Flag handled in code to wipe onboarding markers in debug.)
2. Launch the app; verify the onboarding carousel renders instead of the previous placeholder home.
3. Swipe through each panel, observing localized copy and accessibility labels (toggle device language to zh to confirm translations).
4. On the final slide, choose `Cold Wallet` and confirm offline messaging appears on the restored home screen.
5. Reset and repeat choosing `Hot Wallet`; confirm network guidance appears and hot-specific actions unlock.

## Testing Checklist
- `flutter analyze` passes with no new warnings.
- `flutter test` executes onboarding widget tests (including reduced-motion scenario).
- Flutter integration test (`integration_test/onboarding_flow_test.dart`) runs and verifies mode persistence.
- `cargo test --manifest-path rust/Cargo.toml` exercises `OnboardingViewModel` unit coverage.
- Manual smoke: change system language between EN ↔ zh and confirm all onboarding panels render without truncation.

## Troubleshooting
- If onboarding reappears after completion, check secure storage permissions and verify `WalletModePreference` persisted.
- Cold mode attempting network calls indicates isolation guard not wired; ensure feature flags conditionalize hot-only services.
- Missing translations raise assertions during QA build; run `flutter gen-l10n` to refresh localization bundles.

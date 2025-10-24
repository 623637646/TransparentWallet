# Repository Guidelines

Transparent Wallet pairs a Flutter client with a Rust library via flutter_rust_bridge.

## Project Structure & Module Organization
- Flutter app source sits under `lib/`; shared UI flows live in `lib/src`.
- Rust bindings generated in `lib/src/rust` — do not edit files in it.
- Native Rust crate lives in `rust/` (`src/api` for exported functions, `src/lib.rs` entry point).
- Tests: widget/unit under `test/`, integration flows in `integration_test/`, platform shells under `android/`, `ios/`, plus `rust_builder/` for the packaged Rust binaries.

## Build, Test, and Development Commands
- `flutter pub get` installs Dart dependencies before any build.
- `flutter run --dart-define=...` runs the app on a connected device or emulator.
- `flutter test` executes Dart unit/widget tests; add `--coverage` when collecting reports.
- `flutter analyze` enforces the `flutter_lints` ruleset.
- `cargo test --manifest-path rust/Cargo.toml` validates the Rust crate.
- `dart run flutter_rust_bridge:generate` regenerates bridge code after editing `rust/src/api`.

## Coding Style & Naming Conventions
- Follow Flutter defaults: 2-space indentation, UpperCamelCase for classes, lowerCamelCase for members.
- Keep Dart files formatted with `dart format .`; Rust code uses `cargo fmt --all`.
- Exported Rust functions should remain snake_case, mirroring generated Dart methods living in `lib/src/rust/api`.
- Co-locate new feature code under `lib/src/<feature>` and expose Rust FFI APIs through `api/` modules.

## Testing Guidelines
- Write Dart tests in files suffixed `_test.dart`; mirror package paths.
- Place integration scenarios in `integration_test/` and drive them with `flutter test integration_test`.
- Rust logic requires unit tests alongside implementations using `#[cfg(test)]`; prefer exercising FFI-safe types.

## Commit & Pull Request Guidelines
- Craft concise, present-tense commit subjects (`Add wallet list view`); keep body wrapped at 72 chars when needed.
- Reference linked issues or specs in PR descriptions and note platform/device coverage of manual testing.
- Attach screenshots or logs for UI-affecting changes; call out migrations or schema updates explicitly.
- Ensure PRs pass `flutter analyze`, `flutter test`, and `cargo test` before requesting review.

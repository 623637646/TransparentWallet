# Repository Guidelines

## Project Structure & Module Organization
- Flutter client code lives in `lib/`; shared widgets and flows are under `lib/src`.
- Generated Rust bindings reside in `lib/src/rust`; treat these files as read-only.
- The native Rust crate is in `rust/` (`rust/src/api` exposes FFI functions, `rust/src/lib.rs` is the entry point).
- Tests mirror runtime code: Dart unit and widget tests in `test/`, integration flows under `integration_test/`, and platform shells in `android/`, `ios/`, plus `rust_builder/` for packaged Rust binaries.

## Build, Test, and Development Commands
- `flutter pub get` installs Dart dependencies; run after editing `pubspec.yaml`.
- `flutter test` executes Dart unit and widget suites (`flutter test --coverage` for reports).
- `flutter analyze` applies the `flutter_lints` ruleset across the Dart sources.
- `cargo test --manifest-path rust/Cargo.toml` validates the Rust crate and its FFI surface.
- `dart run flutter_rust_bridge:generate` regenerates bindings after changing `rust/src/api`.
- `flutter run --dart-define=ENV=prod` launches the app on a connected device or emulator with overrides.

## Coding Style & Naming Conventions
- Use Flutter defaults: 2-space indentation, UpperCamelCase for classes, lowerCamelCase for members.
- Keep Rust functions exported over FFI in snake_case to align with generated Dart names.
- Format Dart with `dart format .` and Rust with `cargo fmt --all` before committing.
- Place new feature code in `lib/src/<feature>` and expose Rust APIs through `lib/src/rust/api`.

## Testing Guidelines
- Name Dart test files with the `_test.dart` suffix and mirror source paths.
- Integration scenarios belong in `integration_test/`; run via `flutter test integration_test`.
- Add Rust unit tests alongside implementations using `#[cfg(test)]` to exercise FFI-safe types.
- Aim to keep widget tests deterministic by mocking platform channels and network calls.

## Commit & Pull Request Guidelines
- Write commits in present tense (e.g., `Add wallet list view`) with concise bodies when needed.
- Confirm `flutter analyze`, `flutter test`, and `cargo test` all pass before requesting review.
- PR descriptions should link relevant issues, list tested platforms/devices, and attach UI screenshots when layouts change.
- Call out migrations, schema updates, or new configuration steps explicitly so reviewers can verify them.

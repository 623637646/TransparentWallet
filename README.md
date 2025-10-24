# Transparent Wallet

Transparent Wallet delivers a cross-platform Flutter experience backed by a Rust
FFI layer so users can inspect and manage on-chain balances with full
provenance.

## Project Overview

- Flutter UI lives under `lib/src/`, with feature modules in `lib/src/<feature>`
  and shared components in `lib/src/common`.
- Rust FFI exports reside in `rust/src/api`; regenerate bindings with
  `dart run flutter_rust_bridge:generate` whenever APIs change.
- Packaged Rust binaries are produced by the `rust_builder/` tooling for mobile
  targets.

## Development Quickstart

```bash
flutter pub get
flutter analyze
flutter test
cargo test --manifest-path rust/Cargo.toml
```

- Run features on devices or emulators with `flutter run --dart-define=...`.
- Keep Flutter code formatted via `dart format .`; format Rust via `cargo fmt --all`.
- Integration journeys belong in `integration_test/`; Rust unit tests sit next
  to their implementations.

## Governance

All work MUST comply with the project constitution in
`.specify/memory/constitution.md`. Plans, specs, and task lists are expected to
document ledger transparency, custody, parity, FFI, and observability
considerations before implementation begins.

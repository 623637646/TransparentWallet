# Transparent Wallet

Transparent Wallet delivers a cross-platform Flutter experience backed by a Rust
FFI layer so users can inspect and manage on-chain balances with full
provenance.

## Transparent Wallet — Split Cold/Hot Security Wallet

**Transparent Wallet** can run in either **cold wallet** or **hot wallet** mode. A single app instance stays in one mode at a time so responsibilities remain clearly separated.

### 🧊 Cold Wallet Mode

- Keeps mnemonics, private keys, and other secrets in the safest possible environment
- Operates completely offline with Wi-Fi, Bluetooth, and other radios disabled
- Produces deposit addresses or extended public keys (xpub) for the hot wallet and renders them as QR codes

### 🔥 Hot Wallet Mode

- Connects to the internet to sync balances, fetch history, and build transactions
- Creates, signs, and broadcasts transactions by talking to blockchain nodes or third-party APIs

### 🔄 Cold/Hot Handoff Flow

1. The cold wallet derives addresses or an xpub and displays a QR code
2. The hot wallet scans the QR code to load account metadata for balance tracking or transaction construction
3. The hot wallet builds an unsigned transaction and shows it as a QR code
4. The cold wallet scans, signs offline, and outputs the signed payload as another QR code
5. The hot wallet scans the signature, reconnects to the network, and broadcasts the transaction

This air-gapped exchange keeps every step observable, auditable, and safe—hence the name **Transparent Wallet**.

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

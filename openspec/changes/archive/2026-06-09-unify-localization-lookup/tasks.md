## 1. Rust Core & API

- [x] 1.1 Unify lookup APIs in `LocalizationManager` inside `rust_wallet/src/managers/localization/manager.rs`
- [x] 1.2 Unify lookup APIs in FFI `Context` inside `rust/src/api/localization.rs`

## 2. Code Generation & Dart Layer Integration

- [x] 2.1 Run `flutter_rust_bridge_codegen generate` to update Dart FFI layers
- [x] 2.2 Update `LocalizedText` in `lib/src/widgets/common/localized_text.dart` to use the unified Dart FFI `lookup` API
- [x] 2.3 Verify and compile the project (Dart & Rust) and run tests

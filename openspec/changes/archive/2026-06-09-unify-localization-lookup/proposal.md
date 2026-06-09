## Why

Currently, the localization manager and FFI bridge expose two separate lookup APIs: one for simple lookups with only a text ID (`lookup` / `lookup_local`) and another for lookups with formatting arguments (`lookup_with_args` / `lookup_local_with_args`). Unifying these APIs into a single `LookUp` / `lookup` API simplifies the interface and reduces duplicate code on both the Rust and Dart sides.

## What Changes

- **BREAKING**: Consolidate `lookup_local` and `lookup_local_with_args` into a single FFI function `look_up_text` (exposed as `lookUpText` on the Dart context) that takes a mandatory `textId` and an optional map/hashmap of arguments `args`.
- **BREAKING**: Consolidate Rust core `lookup` and `lookup_with_args` in `LocalizationManager` into a single `lookup` method that accepts the text ID and an optional `HashMap`.
- Update `LocalizedText` and other parts of the Dart/Flutter application to call the new consolidated API.

## Capabilities

### New Capabilities
- `localization`: A unified localization lookup API supporting formatting arguments dynamically.

### Modified Capabilities
- None

## Impact

- **Rust core library**: `LocalizationManager` implementation in `rust_wallet`.
- **Rust FFI API**: `Context` implementation in `rust/src/api/localization.rs`.
- **Dart FFI layer**: Re-generate FFI bridge using `flutter_rust_bridge_codegen`.
- **Flutter UI components**: `LocalizedText` and any other references to localization lookup APIs in the Dart/Flutter codebase.

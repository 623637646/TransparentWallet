## Context

Currently, the application supports translating text using the `LocalizedText` widget or direct FFI calls. These lookups are split into two separate functions in both the Rust FFI layer and the core `LocalizationManager` layer:
1. `lookup_local` (without formatting variables)
2. `lookup_local_with_args` (with formatting variables)

Having two distinct APIs creates redundant paths for calling the underlying translation library (Fluent), complicating both FFI bridge logic and Flutter widget usage.

## Goals / Non-Goals

**Goals:**
- Unify the localization lookups into a single API named `lookUpText` on the Dart/Flutter side and `look_up_text` on the Rust FFI side.
- Accept a mandatory text ID and an optional `HashMap` (in Rust) / `Map` (in Dart) for arguments.
- Clean up the UI calls to use the unified API.

**Non-Goals:**
- Changing how translations are stored or negotiated.
- Changing localized strings themselves.

## Decisions

### Unification of FFI lookup API
We will deprecate and remove `lookup_local` and `lookup_local_with_args` from `Context` in `rust/src/api/localization.rs` and introduce:
```rust
pub async fn look_up_text(
    &self,
    text_id: String,
    args: Option<HashMap<String, String>>,
    on_next: impl Fn(String) -> DartFnFuture<()> + Send + Sync + 'static,
    on_termination: impl FnOnce(Option<String>) -> DartFnFuture<()> + Send + Sync + 'static,
) -> BridgeSubscription
```
On the Dart side, the generated class will expose a single method `lookUpText` accepting `textId` and an optional `args` map.

*Alternatives considered:*
- Keep `lookup_local` and `lookup_local_with_args` but make one call the other. This was rejected because the goal is to simplify and consolidate the API surface.

### Unification of LocalizationManager API
We will update `LocalizationManager` in `rust_wallet/src/managers/localization/manager.rs`.
The `lookup` and `lookup_with_args` methods will be unified into a single method:
```rust
pub fn lookup(
    &self,
    text_id: String,
    args: Option<HashMap<String, String>>,
) -> impl Observable<'static, 'static, String, LocalizationError>
```

## Risks / Trade-offs

- **Risk:** Type mismatch or nullability issues when converting/mapping optional maps in Dart to `Option<HashMap<String, String>>` in Rust.
- **Mitigation:** Rely on `flutter_rust_bridge`'s built-in support for optional types (`Option<HashMap<String, String>>` in Rust maps to `Map<String, String>?` in Dart).

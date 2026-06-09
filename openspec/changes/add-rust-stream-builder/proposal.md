## Why

Currently, widgets in the Flutter application that consume Rust observable streams must manually call `convertSubscriptionToStream`, maintain local `Stream` variables, listen to subscription lifecycles, and handle boilerplate in `StreamBuilder` widgets. This leads to code duplication, boilerplate, and potential memory leaks if subscriptions are not properly disposed of. A common, reusable reactive builder widget is needed to simplify this pattern.

## What Changes

- Introduce a new common widget `RustStreamBuilder` under `lib/src/widgets/common/`.
- The widget will accept a Rust API Context-aware subscription builder callback and a widget builder callback to render UI dynamically based on the stream data.
- The widget will support optional `loadingBuilder`, `errorBuilder`, and `initialData` to customize placeholder states.
- The widget will support dependency tracking via a `keys` array (similar to React/Flutter hooks) to prevent redundant unsubscribe/resubscribe cycles when the parent widget rebuilds.

## Capabilities

### New Capabilities
- `rust-stream-builder`: Introduce a reusable, lifecycle-safe widget `RustStreamBuilder` to simplify consuming Rust FFI subscription streams and rendering UI reactively.

### Modified Capabilities

## Impact

- **Affected code**: A new common widget `lib/src/widgets/common/rust_stream_builder.dart` will be added.
- **Dependencies**: Uses `convertSubscriptionToStream` from `lib/src/utils/bridge_helper.dart`.

## Why

Replacing custom list and key equality comparison logic with standard `ListEquality` from the `collection` package ensures robust, well-tested, and standardized equality comparisons while reducing custom code duplication.

## What Changes

- Add `collection: ^1.19.1` to the dependencies list in `pubspec.yaml`.
- Replace custom `_areKeysEqual` helper method in `lib/src/widgets/common/rust_stream_builder.dart` with `const ListEquality().equals`.
- Replace custom `_listEquals` helper method in `lib/src/widgets/common/pin_bottom_sheet.dart` with `const ListEquality().equals`.

## Capabilities

### New Capabilities

- `collection-equality`: Use package:collection for list and key comparisons in Flutter components.

### Modified Capabilities

None.

## Impact

- **Dependencies**: Adds a direct dependency on `collection: ^1.19.1`.
- **Codebase**: Simplifies list and key equality checks in Flutter components, ensuring more consistent widget updates and PIN code comparisons.

## 1. Setup Dependency

- [x] 1.1 Add `collection: ^1.19.1` to the dependencies section in `pubspec.yaml`
- [x] 1.2 Run `flutter pub get` to fetch the new package

## 2. Refactor Code

- [x] 2.1 Update `lib/src/widgets/common/rust_stream_builder.dart` to import `package:collection/collection.dart` and use `const ListEquality().equals` in place of `_areKeysEqual`
- [x] 2.2 Update `lib/src/widgets/common/pin_bottom_sheet.dart` to import `package:collection/collection.dart` and use `const ListEquality().equals` in place of `_listEquals`

## 3. Verification

- [x] 3.1 Run `flutter analyze` to ensure there are no compilation or warning errors
- [x] 3.2 Run test suite to verify no regressions

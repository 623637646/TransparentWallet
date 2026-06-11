## Context

The application currently overrides or writes custom list equality checks in two places:
1. `_areKeysEqual` in `lib/src/widgets/common/rust_stream_builder.dart` (comparing `List<Object?>`)
2. `_listEquals` in `lib/src/widgets/common/pin_bottom_sheet.dart` (comparing `List<int>`)

Writing custom list equality functions is redundant and error-prone. Standard Dart collections library (`package:collection`) provides verified list/collection equality classes.

## Goals / Non-Goals

**Goals:**
- Add `collection: ^1.19.1` to `pubspec.yaml`.
- Replace the custom equality methods with `const ListEquality().equals`.

**Non-Goals:**
- We do not intend to refactor any other logic in `rust_stream_builder.dart` or `pin_bottom_sheet.dart`.
- We do not intend to change the structure of the keys or lists being compared.

## Decisions

- **Decision**: Use `const ListEquality().equals` instead of custom looping logic.
  - *Rationale*: It is standard, clean, well-tested, and handles null and length checks correctly.
  - *Alternatives considered*: `ListEquality().equals` (non-const) or `const DeepCollectionEquality().equals`. Since both collections are simple lists (shallow comparisons of `int` and `Object?` references), `ListEquality` is sufficient and more efficient than deep collection equality.

## Risks / Trade-offs

- **Risk**: Adding a new package dependency might lead to version conflicts.
  - *Mitigation*: `collection` is a fundamental package published by the Dart team and already transitively included in most Flutter configurations. Specifying `^1.19.1` is standard and safe for the environment.

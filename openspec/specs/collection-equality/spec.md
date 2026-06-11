# Collection Equality Spec

## Purpose
Define requirements for element equality comparison in lists, ensuring standardization using `package:collection`.

## Requirements

### Requirement: List Equality Comparison
The system SHALL use the standard `package:collection` library for comparing element equality in key lists and user input PIN lists, rather than writing custom loop-based comparisons.

#### Scenario: Key list comparison in RustStreamBuilder
- **WHEN** `didUpdateWidget` is called in `RustStreamBuilder`
- **THEN** the system compares the old and new keys lists using `const ListEquality().equals` to determine if a stream subscription should be re-initialized

#### Scenario: PIN verification input comparison
- **WHEN** confirming a newly created PIN
- **THEN** the system compares the first PIN entry and the second PIN entry using `const ListEquality().equals`

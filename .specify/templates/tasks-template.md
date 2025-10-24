---

description: "Task list template for feature implementation"
---

# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/[###-feature-name]/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: `flutter analyze`, `flutter test`, and `cargo test --manifest-path rust/Cargo.toml` are constitutionally required for every story. Add extra suites (integration, golden, Rust unit) as the spec demands.

**Organization**: Tasks are grouped by user story so each increment is independently releasable across iOS, Android, and web.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- Flutter UI: `lib/src/[feature]/...`
- Shared UI/utilities: `lib/src/common/...`
- Rust FFI API: `rust/src/api/...`
- Generated bindings: `lib/src/rust/...` (do **not** edit; regenerate instead)
- Dart unit/widget tests: `test/`
- Flutter integration tests: `integration_test/`
- Rust tests: alongside implementations in `rust/src/**`

<!-- 
  ============================================================================
  IMPORTANT: The tasks below are SAMPLE TASKS for illustration purposes only.
  
  The /speckit.tasks command MUST replace these with actual tasks based on:
  - User stories from spec.md (with their priorities P1, P2, P3...)
  - Feature requirements from plan.md
  - Entities from data-model.md
  - Endpoints from contracts/
  
  Tasks MUST be organized by user story so each story can be:
  - Implemented independently
  - Tested independently
  - Delivered as an MVP increment
  
  DO NOT keep these sample tasks in the generated tasks.md file.
  ============================================================================
-->

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Ensure `flutter pub get` has run and dependencies are pinned
- [ ] T002 [P] Confirm Rust crate builds via `cargo build --manifest-path rust/Cargo.toml`
- [ ] T003 [P] Configure feature flag or routing entry point in `lib/src/app.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

Examples of foundational tasks (tailor per plan):

- [ ] T004 Define Rust DTOs in `rust/src/api/[feature].rs` (no platform branches)
- [ ] T005 Regenerate bindings via `dart run flutter_rust_bridge:generate`
- [ ] T006 [P] Create shared widgets/utilities in `lib/src/common/` (used by all stories)
- [ ] T007 Wire secure storage access helper in `lib/src/common/secure_storage.dart`
- [ ] T008 Set up telemetry/logging scaffolding respecting privacy constraints
- [ ] T009 Document parity commitments + exceptions in plan.md

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - [Title] (Priority: P1) 🎯 MVP

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 1 (OPTIONAL - only if tests requested) ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T010 [P] [US1] Flutter widget test in `test/[feature]/[widget]_test.dart`
- [ ] T011 [P] [US1] Rust unit test in `rust/src/api/[feature].rs`
- [ ] T012 [P] [US1] Integration test in `integration_test/[feature]_flow_test.dart`

### Implementation for User Story 1

- [ ] T013 [P] [US1] Implement Rust logic in `rust/src/api/[feature].rs`
- [ ] T014 [US1] Regenerate bindings (`dart run flutter_rust_bridge:generate`)
- [ ] T015 [US1] Implement Flutter view model in `lib/src/[feature]/state.dart`
- [ ] T016 [US1] Build UI flow in `lib/src/[feature]/view.dart`
- [ ] T017 [US1] Add parity validations + copy review across platforms
- [ ] T018 [US1] Add structured logging + metrics hooks

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - [Title] (Priority: P2)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 2 (OPTIONAL - only if tests requested) ⚠️

- [ ] T019 [P] [US2] Flutter widget test in `test/[feature]/[widget]_test.dart`
- [ ] T020 [P] [US2] Rust unit test in `rust/src/api/[feature].rs`
- [ ] T021 [P] [US2] Integration test in `integration_test/[feature]_flow_test.dart`

### Implementation for User Story 2

- [ ] T022 [P] [US2] Extend Rust APIs in `rust/src/api/[feature].rs`
- [ ] T023 [US2] Update Flutter state + synchronizers in `lib/src/[feature]/state.dart`
- [ ] T024 [US2] Update UI components in `lib/src/[feature]/view.dart`
- [ ] T025 [US2] Document parity impacts + exceptions

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - [Title] (Priority: P3)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 3 (OPTIONAL - only if tests requested) ⚠️

- [ ] T026 [P] [US3] Flutter widget test in `test/[feature]/[widget]_test.dart`
- [ ] T027 [P] [US3] Rust unit test in `rust/src/api/[feature].rs`
- [ ] T028 [P] [US3] Integration test in `integration_test/[feature]_flow_test.dart`

### Implementation for User Story 3

- [ ] T029 [P] [US3] Expand Rust logic in `rust/src/api/[feature].rs`
- [ ] T030 [US3] Update Flutter view model in `lib/src/[feature]/state.dart`
- [ ] T031 [US3] Update UI components in `lib/src/[feature]/view.dart`
- [ ] T032 [US3] Validate telemetry + alerts for new flow

**Checkpoint**: All user stories should now be independently functional

---

[Add more user story phases as needed, following the same pattern]

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] TXXX [P] Update `/specs/[###-feature]/quickstart.md` with parity + custody notes
- [ ] TXXX Code cleanup and FFI contract review
- [ ] TXXX Performance profiling on reference devices
- [ ] TXXX [P] Additional integration coverage in `integration_test/`
- [ ] TXXX Security hardening + privacy validation
- [ ] TXXX Manual verification log for release gate

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - May integrate with US1 but should be independently testable
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - May integrate with US1/US2 but should be independently testable

### Within Each User Story

- Tests MUST be written and observed failing before implementation
- Rust DTOs before Flutter state management
- Flutter state before UI components
- Core implementation before integration scenarios
- Story complete (including parity + observability) before next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Rust and Flutter workstreams within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together (if tests requested):
Task: "Flutter widget test in test/[feature]/[widget]_test.dart"
Task: "Integration test for [user journey] in integration_test/[feature]_flow_test.dart"

# Launch all models for User Story 1 together:
Task: "Implement Rust API in rust/src/api/[feature].rs"
Task: "Build Flutter view in lib/src/[feature]/view.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Run required test suites + parity review for User Story 1
5. Deploy/demo if ready once ledger data + custody checks pass

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 3 → Test independently → Deploy/Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3
3. Stories complete and integrate independently with regenerated bindings as needed

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Regenerate FFI bindings whenever Rust API signatures change
- Avoid: parity regressions, untracked telemetry, editing generated code

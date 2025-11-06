---

description: "Task list for Welcome Mode Choice Onboarding"
---

# Tasks: Welcome Mode Choice Onboarding

**Input**: Design documents from `/specs/001-welcome-mode-choice/`  
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: `flutter analyze`, `flutter test`, `cargo test --manifest-path rust/Cargo.toml` are required for every story. Add integration, widget, and Rust unit coverage as outlined below.

**Organization**: Tasks are grouped by user story so each increment is independently releasable across iOS, Android, web, and respects mode isolation.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Repository prep and baseline assets

- [ ] T001 Ensure dependencies install cleanly with `flutter pub get`
- [ ] T002 [P] Add `flutter_secure_storage` and `shared_preferences` dependencies to `pubspec.yaml`
- [ ] T003 [P] Scaffold onboarding module directories (`lib/src/onboarding/views/`, `lib/src/onboarding/state/`, `lib/src/onboarding/assets/`)
- [ ] T004 [P] Add placeholder localization entries for onboarding keys in `lib/l10n/intl_en.arb` and `lib/l10n/intl_zh.arb`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared services and cross-story infrastructure

- [ ] T005 Implement `WalletModeStorage` secure storage wrapper in `lib/src/common/storage/wallet_mode_storage.dart`
- [ ] T006 [P] Implement `FirstRunRepository` using shared preferences in `lib/src/common/storage/first_run_repository.dart`
- [ ] T007 [P] Scaffold Rust onboarding module with slide DTO stubs in `rust/src/onboarding/mod.rs`
- [ ] T008 Expose onboarding FFI placeholders in `rust/src/api/onboarding.rs`
- [ ] T009 Regenerate flutter_rust_bridge bindings for onboarding (`dart run flutter_rust_bridge:generate`)
- [ ] T010 Define onboarding analytics event constants in `lib/src/common/analytics/onboarding_events.dart`

**Checkpoint**: Foundation ready – onboarding stories can now begin in parallel

---

## Phase 3: User Story 1 - Learn About Transparent Wallet (Priority: P1) 🎯 MVP

**Goal**: Deliver the educational onboarding carousel shown on first launch

**Independent Test**: Launch app with cleared first-run state; swipe through panels and verify localized content renders in EN/zh while analytics stubs remain idle

### Tests for User Story 1

- [ ] T011 [P] [US1] Create widget test validating slide order and copy keys in `test/onboarding/welcome_carousel_test.dart`

### Implementation for User Story 1

- [ ] T012 [P] [US1] Implement `OnboardingSlideContent` DTO and sample data in `rust/src/onboarding/slide.rs`
- [ ] T013 [US1] Publish slide list via `OnboardingViewModel` stream in `rust/src/onboarding/view_model.rs`
- [ ] T014 [US1] Wire slide retrieval through FFI in `rust/src/api/onboarding.rs`
- [ ] T015 [US1] Bridge Rust slide stream to Flutter state in `lib/src/onboarding/state/onboarding_state.dart`
- [ ] T016 [US1] Build swipeable carousel UI with progress indicator in `lib/src/onboarding/views/onboarding_carousel_page.dart`
- [ ] T017 [US1] Populate finalized onboarding copy and assets in `lib/l10n/intl_en.arb`, `lib/l10n/intl_zh.arb`, and `lib/src/onboarding/assets/`
- [ ] T018 [US1] Update app entry gating to show onboarding when `FirstRunState` is incomplete in `lib/src/app.dart`

**Checkpoint**: User Story 1 delivers a localized, swipeable onboarding carousel gating the app

---

## Phase 4: User Story 2 - Choose Wallet Mode (Priority: P1)

**Goal**: Require cold or hot mode selection and persist the preference securely

**Independent Test**: Reach final panel, select a mode, and confirm selection persists via secure storage and analytics events fire without PII

### Tests for User Story 2

- [ ] T019 [P] [US2] Add Rust unit test covering mode persistence logic in `rust/src/onboarding/view_model.rs`
- [ ] T020 [P] [US2] Add Flutter unit test validating storage writes in `test/onboarding/mode_selection_test.dart`
- [ ] T028 [P] [US2] Add cold mode isolation test ensuring hot services stay disabled in `test/onboarding/cold_mode_isolation_test.dart`
- [ ] T030 [P] [US2] Add unit test verifying first-run completion flag in `test/onboarding/first_run_completion_test.dart`
- [ ] T032 [P] [US2] Add telemetry unit test for onboarding completion event in `test/onboarding/onboarding_completed_event_test.dart`

### Implementation for User Story 2

- [ ] T021 [US2] Implement mode selection handler in `rust/src/onboarding/view_model.rs`
- [ ] T022 [US2] Extend FFI to accept `ModeSelectionRequest` in `rust/src/api/onboarding.rs`
- [ ] T023 [US2] Persist mode selection through `WalletModeStorage` in `lib/src/common/storage/wallet_mode_storage.dart`
- [ ] T024 [US2] Build final mode choice panel with reduced-motion handling in `lib/src/onboarding/views/mode_choice_panel.dart`
- [ ] T025 [US2] Emit `mode_selected` analytics event in `lib/src/common/analytics/onboarding_events.dart`
- [ ] T026 [US2] Surface confirmation messaging for cold and hot modes in `lib/src/onboarding/views/onboarding_carousel_page.dart`
- [ ] T027 [US2] Gate hot-only services when mode is cold in `lib/src/common/app_bootstrap.dart`
- [ ] T029 [US2] Persist `FirstRunState` completion when onboarding finishes in `lib/src/onboarding/state/onboarding_state.dart`
- [ ] T031 [US2] Emit `onboarding_completed` analytics event upon first completion in `lib/src/common/analytics/onboarding_events.dart`

**Checkpoint**: User Story 2 stores mode choice securely and informs users of connectivity implications

---

## Phase 5: User Story 3 - Return to Home with Mode Context (Priority: P2)

**Goal**: Skip onboarding on relaunch, update home messaging, and provide revisit entry point

**Independent Test**: Relaunch app after completing onboarding; confirm home reflects mode messaging, onboarding skip works, and help entry reopens read-only carousel

### Tests for User Story 3

- [ ] T033 [P] [US3] Add integration test for onboarding skip + home messaging in `integration_test/onboarding_flow_test.dart`

### Implementation for User Story 3

- [ ] T034 [US3] Guard app bootstrap to skip onboarding when `FirstRunState.has_completed` is true in `lib/src/app.dart`
- [ ] T035 [US3] Update home screen headline and actions per mode in `lib/src/home/home_page.dart`
- [ ] T036 [US3] Add “Learn about Transparent Wallet” entry to reopen onboarding in `lib/src/home/home_page.dart`
- [ ] T037 [US3] Expose mode state stream for home widgets in `lib/src/onboarding/state/onboarding_state.dart`
- [ ] T038 [US3] Log `onboarding_completed` analytics event post-skip in `lib/src/common/analytics/onboarding_events.dart`

**Checkpoint**: Returning users see mode-specific home content without rerunning onboarding, but can review material on demand

---

## Phase N: Polish & Cross-Cutting Concerns

- [ ] T039 Run `flutter gen-l10n` and review translations for truncation in `lib/l10n/`
- [ ] T040 Audit screen reader labels and reduced-motion transitions across onboarding views in `lib/src/onboarding/views/`
- [ ] T041 Update analytics dashboard documentation for onboarding metrics in `docs/analytics/onboarding_dashboard.md`
- [ ] T042 Refresh quickstart instructions with latest debug flags in `specs/001-welcome-mode_choice/quickstart.md`
- [ ] T043 Perform parity smoke test across iOS, Android, and web documenting results in `docs/testing/onboarding_parity.md`

---

## Dependencies & Execution Order

- **User Story Order**: US1 → US2 → US3 (US1 and US2 share P1 priority but US2 depends on mode storage from US1 foundations)
- **Foundational Dependencies**: Phase 2 tasks block all user stories
- **Within Stories**:
  - Tests should be authored before implementation to enable TDD where feasible
  - Rust ViewModel and FFI updates precede Flutter state bindings
  - Analytics emissions follow functional logic to avoid emitting incorrect data

### Phase Dependencies

- Setup (Phase 1) → Foundational (Phase 2) → User Stories (Phase 3+) → Polish

### User Story Dependencies

- **US1**: Depends on Phase 1 & 2 completion
- **US2**: Depends on US1’s slide delivery (shared structures) and Foundations
- **US3**: Depends on US1 & US2 outputs to reflect chosen mode

### Parallel Opportunities

- Phase 1 tasks marked [P] can run together (dependency file boundaries differ)
- In Phase 2, storage (T005-T006) and Rust scaffolding (T007-T008) can progress in parallel before regeneration step
- Within US1, DTO creation (T012) and widget test (T011) can proceed while UI work (T016) readies
- US2 tests (T019-T020) and FFI work (T021-T022) can run in parallel with Flutter UI (T024) after foundations merge
- US3 integration test (T033) can start once US2 tasks stabilize while home messaging (T035) develops

### Parallel Example: User Story 2

```bash
# In parallel streams
Task: "Add Rust unit test covering mode persistence in rust/src/onboarding/view_model.rs"
Task: "Extend FFI to accept ModeSelectionRequest in rust/src/api/onboarding.rs"
Task: "Build final mode choice panel with reduced-motion handling in lib/src/onboarding/views/mode_choice_panel.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1)

1. Complete Setup + Foundational phases
2. Deliver US1 carousel experience and gating
3. Ship localized copy and ensure first-run onboarding blocks home view

### Incremental Delivery

1. US1 (education) → release candidate demonstrating onboarding messaging
2. US2 (mode selection) → adds persistence and analytics, unlocking cold/hot flows
3. US3 (home context) → finalizes user experience and skip behaviour

### Parallel Team Strategy

- Developer A: Rust ViewModel + analytics instrumentation
- Developer B: Flutter UI and localization for onboarding
- Developer C: Integration tests + home updates for returning users

---

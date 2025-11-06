# Implementation Plan: Welcome Mode Choice Onboarding

**Branch**: `001-welcome-mode-choice` | **Date**: 2025-11-06 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `/specs/001-welcome-mode-choice/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

- Deliver a forced first-run onboarding carousel that educates users on Transparent Wallet’s purpose, security posture, and QR transparency before they reach the home screen.
- Require users to select cold or hot wallet mode at the end of onboarding, persisting the choice to secure local storage and reflecting it on the restored home view.
- Ensure the experience is localized (EN/zh), parity-complete across iOS/Android/web, and instrumented so mode selection and completion analytics remain privacy-preserving.

## Technical Context

**Language/Version**: Dart 3.9 (Flutter stable) + Rust 1.77+ (edition 2021)  
**Primary Dependencies**: `flutter`, `flutter_rust_bridge`, `rust_lib_transparent_wallet`, `flutter_secure_storage`, `shared_preferences` (for non-secret hints)  
**Storage**: Local secure storage (keystore/Keychain) for mode flag + in-memory caches; no remote persistence  
**Testing**: `flutter analyze`, `flutter test`, `cargo test --manifest-path rust/Cargo.toml`, Flutter integration test covering onboarding flow  
**Target Platform**: iOS, Android, and Flutter web (parity required)  
**Project Type**: Flutter client with embedded Rust FFI crate (cold + hot modes)  
**Performance Goals**: 60 fps UI; onboarding completion < 90s for reference users; carousel transitions < 16ms frame budget  
**Constraints**: Canonical ledger data, cold-mode offline guarantees, no PII telemetry, semver-stable MVVM bridges, accessibility-compliant carousel controls  
**Scale/Scope**: Multi-account consumer wallet; incremental, independently releasable flows

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Ledger transparency**: No ledger mutations; onboarding references canonical transparency messaging. Any metrics will tag mode selection without touching balances. Deterministic fixtures remain unchanged.
- **Custody & privacy**: Mode preference stored via secure storage; telemetry excludes wallet identifiers and records only mode type + anonymized completion timestamp buckets.
- **Cold & hot wallet isolation**: Cold mode toggle immediately disables network initialization hooks in Flutter; Rust ViewModel exposes read-only cold/hot state consumed by UI to gate features.
- **Platform & localization parity**: Carousel assets and copy shipped simultaneously in EN/zh. Same swipe UX on iOS/Android/web with responsive layout and accessibility labels; parity tracked in tasks.
- **MVVM bridge discipline**: Introduce `OnboardingViewModel` in Rust exposing slide data and mode state via `rx-rust`. Any DTO changes go through `rust/src/api/onboarding.rs` with regenerated bindings.
- **Test & observability**: Unit + integration tests ensure onboarding gating, plus analytics smoke test verifying events emitted. Dashboards updated to include onboarding completion counts per mode.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan output)
├── research.md          # Phase 0 (/speckit.plan output)
├── data-model.md        # Phase 1 (/speckit.plan output)
├── quickstart.md        # Phase 1 (/speckit.plan output)
├── contracts/           # Surface + FFI signatures (Phase 1)
└── tasks.md             # Phase 2 (/speckit.tasks output)
```

### Source Code (repository root)
```text
lib/
└── src/
    ├── rust/                 # generated bindings (do not edit)
    ├── common/               # shared UI + utilities
    └── [feature]/            # feature-specific code

rust/
└── src/
    ├── api/                  # exported FFI functions
    └── lib.rs                # crate entry point

test/                         # Dart unit + widget suites
integration_test/             # Flutter integration suites
rust_builder/                 # packaged Rust artifacts
```

**Structure Decision**: Create `lib/src/onboarding/` for Flutter views/state, keep shared copy or assets under `lib/src/common/`. Rust onboarding APIs live in `rust/src/api/onboarding.rs` with supporting logic in `rust/src/onboarding/`.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|

## Phase Plan Overview

1. **Phase 0 – Research & Decisions**
   - Confirm secure storage vs preferences split and reduced-motion experience handling.
   - Align telemetry event schema with privacy requirements and analytics consumers.
2. **Phase 1 – Design & Contracts**
   - Author Rust ViewModel interfaces and DTO schema for slides + mode preference.
   - Define Flutter state flow, navigation gating, and localization bundle updates.
   - Produce quickstart for QA to trigger onboarding and verify mode reflection.
3. **Phase 2 – Build & Tests (detailed in `/speckit.tasks`)**
   - Implement Rust + Flutter layers, generate bindings, add tests & analytics hooks.
   - Polish localization, accessibility, and ensure cold-mode isolation gates remain enforced.

## Post-Design Constitution Confirmation

- Research validates storage and telemetry comply with custody/privacy safeguards and cold-mode isolation.
- Data model + contracts preserve canonical ledger transparency by keeping onboarding content static/offline.
- Accessibility, localization, and analytics test plans ensure parity and observability gates remain satisfied.

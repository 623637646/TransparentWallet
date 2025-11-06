# Research: Welcome Mode Choice Onboarding

## Decision 1: Persisting First-Run and Mode Preferences
- **Decision**: Store the wallet mode in platform secure storage (`flutter_secure_storage`) and keep a lightweight non-secret “onboarding complete” flag in `shared_preferences`, with Rust ViewModel mirroring the secure value.
- **Rationale**: Secure storage defends against tampering with the mode selection (critical for cold-wallet isolation), while `shared_preferences` offers fast access for UI gating without rehydrating secrets. Mirroring into Rust keeps a single source of truth for mode-dependent logic.
- **Alternatives Considered**:
  - Store both flags in plain preferences—rejected due to ease of manipulation and potential cold-mode compromise.
  - Keep both in secure storage only—rejected because secure storage read latency could introduce startup lag on older devices.

## Decision 2: Onboarding Slide Content Delivery
- **Decision**: Bundle onboarding slide definitions statically inside the app with localization keys resolved through Flutter `l10n`, surfaced by Rust as DTOs.
- **Rationale**: Slides focus on core product values that rarely change and must be available offline during cold-mode use. Static bundling ensures deterministic content across platforms and simplifies localization workflows.
- **Alternatives Considered**:
  - Fetch slides remotely via config service—rejected; hot mode could fetch but cold mode must remain offline, so parity would break.
  - Hard-code copy in Flutter widgets—rejected; RUST ViewModel needs to supply consistent data for tests and to keep translations centralized.

## Decision 3: Telemetry Event Schema
- **Decision**: Emit `onboarding_completed` and `mode_selected` events with fields `{mode, locale, reduced_motion}` and anonymized session identifier, redacting wallet/account identifiers entirely.
- **Rationale**: KPI tracking needs to differentiate cold vs hot adoption and accessibility usage without exposing user identities or keys. Fields support parity audits and localization QA.
- **Alternatives Considered**:
  - Single combined event with raw device identifiers—rejected due to privacy and constitution requirements.
  - No telemetry—rejected; compliance needs verification that onboarding remains effective after releases.

<!--
Sync Impact Report
- Version: 1.0.0 → 1.1.0
- Modified Principles:
  - Transparent Ledger Integrity (Non-Negotiable) (scope refined for QR provenance)
  - Custody & Privacy Safeguards (expanded with cold-mode network bans)
  - Cross-Platform Parity → Cross-Platform & Localization Parity
  - FFI Contract Discipline → MVVM Bridge Discipline
  - Testable Observability & Release Gates (reinforced dual-mode gates)
- Added Principles:
  - Cold & Hot Wallet Isolation (Non-Negotiable)
- Added Sections:
  - None
- Removed Sections:
  - None
- Templates Requiring Updates:
  - .specify/templates/plan-template.md ✅ updated
  - .specify/templates/spec-template.md ✅ updated
  - .specify/templates/tasks-template.md ✅ updated
  - .specify/templates/commands/* N/A (directory not present)
- Follow-up TODOs:
  - None
-->

# Transparent Wallet Constitution

## Core Principles

### Transparent Ledger Integrity (Non-Negotiable)
- Rust FFI APIs MUST source balances, transactions, and state directly from
  canonical ledgers and expose provenance metadata for every response.
- Flutter surfaces MUST render the same canonical data without mutating or
  caching values in ways that hide on-chain divergence; any derived state MUST
  be reproducible from the Rust source.
- QR-encoded payloads exchanged between modes MUST include explicit schema
  versions and payload hashes so both sides can verify ledger alignment before
  acting.
**Rationale**: Transparency is the product promise; verifiable data prevents
silent regressions or mismatched balances.

### Custody & Privacy Safeguards
- Private keys, mnemonics, and signing material MUST never leave the device;
  persistence requires secure enclaves or platform keystores, with encrypted
  storage on disk.
- Cold-mode builds MUST keep all radios disabled (Wi-Fi, Bluetooth, cellular) and
  block initialization of networking plugins or background sync workers.
- Telemetry MUST exclude user-identifiable wallet data and MUST be opt-in with
  revocation handled in-app; debugging builds MUST redact sensitive payloads.
- Recovery flows MUST complete entirely client-side, and any cloud backups MUST
  be encrypted end-to-end before transport.
**Rationale**: Holding funds safely depends on strict custody hygiene and
protecting user identity.

### Cross-Platform & Localization Parity
- Features shipped on one mobile platform MUST launch on the other within the
  same release cycle unless a parity exception is documented in the plan and
  tracked to closure.
- UI flows, copy, and error messaging MUST be localized for English and Chinese
  simultaneously; localization requests MUST land before feature freeze.
- Rust APIs MUST provide identical behavior across architectures, and any
  platform-specific branching MUST live in Flutter presentation code with
  explicit fallbacks.
**Rationale**: Users expect the transparent wallet experience regardless of
device or language, so parity prevents fractured behavior.

### Cold & Hot Wallet Isolation (Non-Negotiable)
- Each app instance MUST commit to cold or hot mode at bootstrap; switching
  requires full reinitialization and scrubbing in-memory secrets.
- Cold-mode deployments MUST operate entirely offline, forbidding socket access,
  background networking, and clipboard or file-based exports of sensitive data.
- Information exchange between modes MUST occur solely through the approved
  QR-code schema (or an equivalently air-gapped channel recorded in specs); no
  network relays are permitted.
- Hot-mode transaction assemblies MUST produce deterministic payloads the cold
  wallet can validate before signing, and signatures MUST return via the same
  schema for broadcast.
**Rationale**: Strong isolation keeps signing keys offline while maintaining a
transparent, auditable transfer channel.

### MVVM Bridge Discipline
- Flutter layers MUST own only view and presentation logic; Rust code supplies
  ViewModels and Models per MVVM boundaries.
- Rust ViewModels MUST expose reactive streams using `rx-rust`, and Flutter
  consumers MUST subscribe through `flutter_rust_bridge` without duplicating
  business logic.
- Exposed functions in `rust/src/api` MUST declare stable, strongly typed DTOs;
  breaking changes require semver coordination and regenerated bindings via
  `dart run flutter_rust_bridge:generate`.
- Each bridge addition or mutation MUST include Rust unit tests and Dart
  integration tests that exercise the boundary.
- Generated files under `lib/src/rust` MUST remain untouched; modifications MUST
  happen in source code followed by regeneration.
**Rationale**: Consistent MVVM contracts keep the Flutter–Rust boundary reactive
and predictable.

### Testable Observability & Release Gates
- Pull requests MUST run and pass `flutter analyze`, `flutter test`, and
  `cargo test --manifest-path rust/Cargo.toml`; any failing gate blocks merge.
- Feature work MUST add logging and metrics that make ledger interactions,
  bridge calls, and user-facing errors observable without exposing secrets.
- Release candidates MUST document verification across cold/hot flows, supported
  devices, and telemetry dashboards before approval.
**Rationale**: High-confidence releases need enforced gates and actionable
signals when issues appear.

## Operational Guardrails
- House Flutter feature code under `lib/src/<feature>` and keep shared widgets
  in `lib/src` to avoid inconsistent structures.
- Gate all network dependencies and asynchronous sync jobs behind explicit mode
  checks so cold-mode binaries compile without network reachability.
- Limit Rust exports to `rust/src/api` and keep shared logic in well-scoped
  modules; regenerate bindings after API updates.
- Maintain localization resources through the project's Flutter `l10n`
  configuration so English and Chinese copy stay synchronized.
- Never edit generated artifacts in `lib/src/rust`; drive changes through source
  files and regeneration commands.
- Format Dart code with `dart format .` and Rust code with `cargo fmt --all`
  before submitting reviews.

## Delivery Workflow
- New workstreams MUST begin with a feature spec in `/specs` that captures cold
  and hot wallet journeys, QR payload schemas, and parity expectations derived
  from this constitution.
- Implementation plans and task lists MUST reference the governing principles,
  explicitly documenting any requested deviations and mitigation steps.
- Integration tests MUST cover end-to-end hot-to-cold-to-hot flows (creation,
  sync, transfer, reconciliation) before marking a milestone complete.
- Each release cycle MUST include localization review for English and Chinese
  copy and explicit sign-off that cold-mode remains offline.

## Governance
- This constitution supersedes conflicting guidelines; contributors MUST attest
  to compliance during reviews and flag any intentional deviations.
- Amendments require: (1) a written RFC referencing impacted principles,
  (2) approval from the Flutter and Rust maintainers, and (3) updates to
  affected templates and guidance documents in the same change.
- Version numbers follow semantic versioning relative to governance scope; a
  release note summarizing changes MUST accompany each bump.
- Compliance reviews occur at minimum once per release cycle, verifying dual
  wallet isolation, localization currency, and MVVM bridge health; findings MUST
  be tracked as backlog items with owners and due dates.

**Version**: 1.1.0 | **Ratified**: 2025-10-24 | **Last Amended**: 2025-11-06

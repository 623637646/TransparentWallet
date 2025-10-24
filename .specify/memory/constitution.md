<!--
Sync Impact Report
- Version: N/A → 1.0.0
- Modified Principles:
  - Template principle #1 → Transparent Ledger Integrity (Non-Negotiable)
  - Template principle #2 → Custody & Privacy Safeguards
  - Template principle #3 → Cross-Platform Parity
  - Template principle #4 → FFI Contract Discipline
  - Template principle #5 → Testable Observability & Release Gates
- Added Sections:
  - Operational Guardrails
  - Delivery Workflow
- Removed Sections:
  - None
- Templates Requiring Updates:
  - .specify/templates/plan-template.md ✅ updated
  - .specify/templates/spec-template.md ✅ updated
  - .specify/templates/tasks-template.md ✅ updated
- Additional Guidance Updates:
  - README.md ✅ updated
- Follow-up TODOs:
  - None
-->

# Transparent Wallet Constitution

## Core Principles

### Transparent Ledger Integrity (Non-Negotiable)
- Rust FFI APIs MUST source balances, transactions, and state directly from
  canonical ledgers and expose the provenance for every response.
- Flutter surfaces MUST present the same canonical data without mutating or
  caching values in ways that hide on-chain divergence; any derived state MUST
  be re-computable from the Rust source.
- Every change touching ledger data MUST include deterministic replay fixtures
  to validate behavior across supported networks.
**Rationale**: Transparency is the product promise; verifiable data prevents
silent regressions or mismatched balances.

### Custody & Privacy Safeguards
- Private keys, mnemonics, and signing material MUST never leave the device;
  persistence requires secure enclaves or platform keystores, with encrypted
  storage on disk.
- Telemetry MUST exclude user-identifiable wallet data and MUST be opt-in with
  revocation handled in-app; debugging builds MUST redact sensitive payloads.
- Recovery flows MUST complete entirely client-side, and any cloud backups MUST
  be encrypted end-to-end before transport.
**Rationale**: Holding funds safely depends on strict custody hygiene and
protecting user identity.

### Cross-Platform Parity
- Features shipped on one mobile platform MUST launch on the other within the
  same release cycle unless a parity exception is documented in the plan and
  tracked to closure.
- UI flows and error messaging MUST be consistent across iOS, Android, and web;
  platform-specific variations MUST retain equivalent capabilities.
- Rust APIs MUST provide identical behavior across architectures, and any
  platform-specific branching MUST live in Flutter presentation code with
  explicit fallbacks.
**Rationale**: Users expect the transparent wallet experience regardless of
device, so parity prevents fractured behavior.

### FFI Contract Discipline
- Exposed functions in `rust/src/api` MUST declare stable, strongly typed DTOs;
  breaking changes require semver coordination and regenerated bindings via
  `dart run flutter_rust_bridge:generate`.
- Each FFI addition or mutation MUST include Rust unit tests and corresponding
  Dart integration tests that exercise the bridge boundary.
- Generated files under `lib/src/rust` MUST remain untouched; modifications MUST
  happen in source code followed by regeneration.
**Rationale**: Consistent FFI contracts keep the Flutter–Rust boundary safe and
predictable.

### Testable Observability & Release Gates
- Pull requests MUST run and pass `flutter analyze`, `flutter test`, and
  `cargo test --manifest-path rust/Cargo.toml`; any failing gate blocks merge.
- Feature work MUST add logging and metrics that make ledger interactions,
  bridge calls, and user-facing errors observable without exposing secrets.
- Release candidates MUST document manual verification steps, device coverage,
  and telemetry dashboards before approval.
**Rationale**: High-confidence releases need enforced gates and actionable
signals when issues appear.

## Operational Guardrails
- House Flutter feature code under `lib/src/<feature>` and keep shared widgets
  in `lib/src` to avoid inconsistent structures.
- Limit Rust exports to `rust/src/api` and keep shared logic in well-scoped
  modules; regenerate bindings after API updates.
- Never edit generated artifacts in `lib/src/rust`; instead drive changes
  through source files and regeneration commands.
- Format Dart code with `dart format .` and Rust code with `cargo fmt --all`
  before submitting reviews.
- Configure environment secrets via `flutter run --dart-define` values rather
  than hard-coding sensitive material.

## Delivery Workflow
- New workstreams MUST begin with a feature spec in `/specs` that captures user
  journeys, measurable outcomes, and parity expectations derived from this
  constitution.
- Implementation plans and task lists MUST reference the governing principles,
  explicitly documenting any requested deviations and mitigation steps.
- Integration tests MUST cover end-to-end wallet flows (creation, sync,
  transfer, reconciliation) before marking a milestone complete.
- Maintenance updates (bug fixes, refactors) MUST document expected ledger and
  custody impact in their plan or PR description.

## Governance
- This constitution supersedes conflicting guidelines; contributors MUST attest
  to compliance during reviews and flag any intentional deviations.
- Amendments require: (1) a written RFC referencing impacted principles,
  (2) approval from the Flutter and Rust maintainers, and (3) updates to
  affected templates and guidance documents in the same change.
- Version numbers follow semantic versioning relative to governance scope; a
  release note summarizing changes MUST accompany each bump.
- Compliance reviews occur at minimum once per release cycle; findings MUST be
  tracked as backlog items with owners and due dates.

**Version**: 1.0.0 | **Ratified**: 2025-10-24 | **Last Amended**: 2025-10-24

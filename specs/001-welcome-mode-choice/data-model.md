# Data Model: Welcome Mode Choice Onboarding

## OnboardingSlideContent
- **Purpose**: Describes each panel in the onboarding carousel.
- **Fields**:
  - `id` (string): Stable identifier used for analytics ordering.
  - `title_key` (string): Localization key for slide headline.
  - `body_key` (string): Localization key for descriptive copy.
  - `illustration_asset` (string): Asset path or Lottie identifier bundled with the app.
  - `cta_key` (string, optional): Localization key for per-slide call-to-action label.
  - `order` (int): Display order; Rust publishes sorted sequence.
- **Relationships**: Delivered as an ordered list by the Rust ViewModel; Flutter renders sequentially.
- **Validation Rules**:
  - `order` values MUST be contiguous starting from 0.
  - Localization keys MUST exist for English and Simplified Chinese.
  - Illustrations MUST have light/dark variants or be theme-agnostic.

## WalletModePreference
- **Purpose**: Persists the selected wallet mode and associated metadata.
- **Fields**:
  - `mode` (enum): `cold` | `hot`.
  - `selected_at` (datetime): ISO 8601 timestamp of selection.
  - `device_locale` (string): Locale active when selection occurred (for analytics).
  - `reduced_motion_enabled` (bool): Accessibility flag captured at selection time.
  - `onboarding_version` (string): Version identifier of onboarding content shown.
- **Relationships**: One-to-one with `FirstRunState`; consumed by both Flutter and Rust for gating.
- **Validation Rules**:
  - `mode` MUST be present before onboarding considered complete.
  - `selected_at` MUST be monotonic (ignore older timestamps during restores).
  - Switching modes requires explicit settings flow (out of scope for this feature) to update the record.

## FirstRunState
- **Purpose**: Determines whether onboarding should render on launch.
- **Fields**:
  - `has_completed` (bool): Indicates onboarding completion.
  - `completed_at` (datetime, optional): Timestamp when onboarding finished.
  - `needs_replay` (bool): Flag to reopen onboarding for help screens without resetting mode.
- **Relationships**: References `WalletModePreference`; `has_completed` cannot be true unless preference exists.
- **Validation Rules**:
  - `has_completed` defaults to false.
  - When `needs_replay` is true, onboarding surfaces as read-only preview and MUST NOT alter stored mode.
  - Clearing app data resets both `FirstRunState` and `WalletModePreference`.

## AnalyticsEventPayload (virtual DTO)
- **Purpose**: Captures outbound telemetry emitted for onboarding.
- **Fields**:
  - `event_name` (string): `onboarding_completed` or `mode_selected`.
  - `mode` (enum, optional): Included when relevant.
  - `locale` (string): `en` or `zh`.
  - `reduced_motion` (bool): Accessibility state.
  - `session_token` (string): Ephemeral identifier scoped to install; not user PII.
  - `timestamp` (datetime): Event emission time.
- **Validation Rules**:
  - Payload MUST omit wallet addresses, mnemonics, or device identifiers.
  - `session_token` rotates on reinstall or secure reset.
  - Events MUST enqueue even offline; cold mode stores locally until manual export (future work).

# Feature Specification: Welcome Mode Choice Onboarding

**Feature Branch**: `001-welcome-mode-choice`  
**Created**: 2025-11-06  
**Status**: Draft  
**Input**: User description: "当前的主页是临时的测试页面。写一个欢迎页面。 要求程序第一次运行才显示。欢迎页里告诉用户这个钱包时做什么的，特点是什么。帮助用户了解App。欢迎页面的交互用目前最流行的手机App欢迎页交互形式。欢迎页最后让用户选择当前App的模式，是冷钱包还是热钱包。选好后，展示冷钱包或者热钱包文案到主页里。"

## Summary

- Replace the temporary test home with a first-run welcome flow that explains Transparent Wallet’s purpose and differentiators.
- Deliver a modern, swipeable onboarding experience that culminates in selecting cold or hot wallet mode.
- Persist the chosen mode and surface aligned messaging on the home screen for future sessions, respecting cold-wallet isolation promises.

## Clarifications

### Session 2025-11-06
- Q: Should users be able to “skip” the onboarding prior to choosing a mode? → A: Require swiping through each panel before mode selection

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Learn About Transparent Wallet (Priority: P1)

New users want to understand what Transparent Wallet does, why it is secure, and how cold and hot wallets collaborate before trusting it with their assets.

**Why this priority**: Sets the tone for trust, explains transparency and custody principles, and distinguishes the product from generic wallets on first impression.

**Independent Test**: Launch the app with first-run flag unset, swipe through the onboarding, and confirm that each panel communicates the stated benefits in English and Chinese.

**Acceptance Scenarios**:

1. **Given** it is the first time the app launches on a device, **When** the user opens the app, **Then** a modern swipeable welcome flow replaces the temporary home screen.
2. **Given** the onboarding flow is active, **When** the user swipes through each panel, **Then** they see localized copy highlighting transparent ledger verification, offline cold storage, and QR-based signing.

---

### User Story 2 - Choose Wallet Mode (Priority: P1)

Users need to commit the app instance to cold or hot mode during onboarding so that subsequent experiences, security posture, and connectivity behave correctly.

**Why this priority**: Wallet mode determines whether the device stays offline and what tasks it can perform; enforcing the choice up front protects custody guarantees.

**Independent Test**: Complete the onboarding until the mode selection panel and confirm that choosing cold or hot sets the appropriate preference without leaving onboarding.

**Acceptance Scenarios**:

1. **Given** the user reaches the final onboarding panel, **When** they review the cold and hot wallet descriptions, **Then** clear differentiation, trust signals, and recommended use cases are presented for both options.
2. **Given** the user selects cold wallet mode, **When** onboarding finishes, **Then** the application stores the cold mode preference and confirms the device will remain offline.
3. **Given** the user selects hot wallet mode, **When** onboarding finishes, **Then** the application stores the hot mode preference and confirms network connectivity requirements.

---

### User Story 3 - Return to Home with Mode Context (Priority: P2)

Returning users expect the chosen mode to shape their home experience without repeating onboarding, while still accessing the explanatory copy.

**Why this priority**: Reinforces the selected workflow, prevents onboarding fatigue, and ensures teams can instrument success without regressions.

**Independent Test**: Relaunch the app after completing onboarding and verify that the home screen persists the selected mode messaging and does not show onboarding again.

**Acceptance Scenarios**:

1. **Given** the user completed onboarding and selected a mode, **When** the app is relaunched, **Then** the onboarding flow is skipped and the home screen greets them with cold- or hot-specific copy.
2. **Given** a user wants to revisit onboarding content later, **When** they access the help entry point defined in the design, **Then** they can review the informational panels without altering the stored mode.

### Edge Cases

- How does first-run detection behave if the user reinstalls or clears secure storage, and how is double onboarding avoided?
- What happens if the device lacks network access during onboarding but the user chooses hot mode (messaging, retry prompts)?
- How are parity and localization handled when English or Chinese strings are missing or exceed layout bounds?
- What safeguards prevent cold-mode binaries from enabling network features if onboarding is bypassed or tampered with?
- How will accessibility users (screen readers, reduced motion) experience the swipeable flow without losing context?
- How is the onboarding completion metric captured if the app crashes or is backgrounded during the flow?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-002a**: The onboarding flow MUST disable “Skip” shortcuts; users advance sequentially via Back/Next swipes or buttons until the mode-selection panel is reached.
- **FR-001**: On the first launch of a fresh install, the temporary home screen MUST be replaced by a multi-panel welcome experience that introduces Transparent Wallet’s transparent ledger audits, QR signing, and cold/hot collaboration.
- **FR-002**: The onboarding flow MUST adopt a modern mobile pattern (e.g., horizontal swipe with progress indicator and prominent CTA) that works with touch, keyboard focus, and screen readers across iOS, Android, and Flutter web.
- **FR-003**: All onboarding content, CTAs, and confirmations MUST ship in English and Simplified Chinese simultaneously, with layout accommodating both languages without truncation.
- **FR-004**: Completing onboarding MUST persist a “first-run complete” marker in secure local storage so reopening the app skips onboarding unless the marker is manually reset through a settings entry point.
- **FR-005**: The final onboarding step MUST present cold and hot wallet options with clear descriptions of offline guarantees, connectivity needs, and QR workflows, requiring the user to choose one before continuing.
- **FR-006**: Selecting cold wallet mode MUST immediately disable or hide network-dependent hot features, confirm offline expectations, and store the mode preference in a way cold builds can access without enabling connectivity.
- **FR-007**: Selecting hot wallet mode MUST confirm that network access will be required, ensure the preference is stored, and surface guidance on scanning cold-wallet signatures.
- **FR-008**: After onboarding completes, the restored home screen MUST display the chosen mode’s headline messaging, key actions, and a link to re-read onboarding content without altering the stored preference.
- **FR-009**: Onboarding completion and mode selection events MUST be logged to the existing analytics sinks without including wallet identifiers, enabling compliance review of cold/hot adoption.
- **FR-010**: Attempting to bypass onboarding (e.g., force-quitting mid-flow) MUST resume the welcome experience until the user finishes and confirms a mode.

### Key Entities *(include if feature involves data)*

- **OnboardingSlideContent**: Immutable configuration for each welcome panel (headline, body copy, illustration asset reference, localization keys) that ViewModels expose to Flutter for swipe rendering.
- **WalletModePreference**: Persistent value capturing selected mode (`cold`, `hot`) plus metadata such as selection timestamp and whether onboarding replay is allowed, ensuring cold-mode builds never trigger network initialization.
- **FirstRunState**: Flag and associated audit data (first launch timestamp, completion status) stored locally to determine whether onboarding should render or be skipped on subsequent launches.

## Assumptions

- “Most popular welcome interaction” is interpreted as a swipeable carousel with indicator dots, optional skip, and animated transitions; reduced motion settings will switch to fade transitions.
- Users can revisit onboarding content from a new “Learn about Transparent Wallet” entry point on the home or settings screen without resetting the stored mode.
- Mode selection remains editable later via settings, but this feature will be planned separately; this specification focuses on first-run mode commitment and presentation on the home screen.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 95% of first-time users complete the onboarding flow and select a wallet mode within 90 seconds on reference iOS, Android, and web devices.
- **SC-002**: Localization QA confirms zero critical copy defects across English and Simplified Chinese in onboarding panels and home-mode messaging prior to release.
- **SC-003**: Telemetry dashboards show 100% of onboarding completions accompanied by a mode selection event with no personally identifiable wallet data captured.
- **SC-004**: Post-onboarding surveys/interviews report ≥80% of participants accurately describe cold/hot responsibilities after viewing the welcome experience.

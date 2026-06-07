# Design Tokens

Purpose: Centralized design token accessibility, dynamic mode adaptation, typography, and component styling.

## Requirements

### Requirement: Centralized design token accessibility
The system SHALL expose a centralized Dart class `DesignTokens` containing all design system specifications defined in `DESIGN.md`, including spacing, border radius, colors, typography, and component styling.

#### Scenario: Retrieve constant design tokens
- **WHEN** the application requests spacing or border radius tokens
- **THEN** the system returns the corresponding constant values (e.g., spacing.md = 17.0, rounded.lg = 18.0)

### Requirement: Dynamic mode adaptation
The system SHALL dynamically resolve the active theme/token instance based on the active `AppMode`. `AppMode.hotWallet` SHALL map to the Hot Wallet Theme, while `AppMode.coldWallet` and `AppMode.init` SHALL map to the Cold/Unselected Wallet Theme.

#### Scenario: Active mode is Hot Wallet
- **WHEN** the active `AppMode` is `AppMode.hotWallet`
- **THEN** the resolved color tokens correspond to the Airbnb Rausch Palette (e.g., primary = #ff385c)

#### Scenario: Active mode is Cold Wallet or Init
- **WHEN** the active `AppMode` is `AppMode.coldWallet` or `AppMode.init`
- **THEN** the resolved color tokens correspond to the xAI Cosmic Monochrome Palette (e.g., primary = #ffffff)

### Requirement: Typographic token definition
The system SHALL expose Flutter-compatible typography tokens (`TextStyle`) that model the Apple display/text specifications, configuring the appropriate font size, line height, letter spacing, font weight, and font family fallback stack.

#### Scenario: Requesting display-lg typography
- **WHEN** the application requests the `display-lg` typography token
- **THEN** the system returns a `TextStyle` with fontSize 40.0, fontWeight W600, letterSpacing 0.0, lineHeight 1.10, and a font family stack containing SF Pro Display, system-ui, and sans-serif.

### Requirement: Component styling tokens
The system SHALL expose specific component styling tokens matching `DESIGN.md`, including padding, button height, custom border radius, and component-specific background and text color mappings.

#### Scenario: Requesting primary button style
- **WHEN** the application requests style tokens for `button-primary` in Hot Wallet mode
- **THEN** the system returns styling properties mapping to primary background (#ff385c), on-primary text (#ffffff), and pill border radius (9999.0).

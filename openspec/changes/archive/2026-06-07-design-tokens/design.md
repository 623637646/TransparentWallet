## Context

The application is structured into a Flutter frontend and a Rust backend. To implement the design specified in `DESIGN.md`, we need a robust, compile-time type-safe way to access design tokens (colors, typography, spacing, border radius, component-specific attributes) in Flutter. The tokens must reactively adapt to the current `AppMode` (hotWallet vs coldWallet/init).

## Goals / Non-Goals

**Goals:**
- Centralize all design tokens (colors, spacing, typography, border radius, components) in a single Dart file: `lib/src/utils/design_tokens.dart`.
- Support dual-mode colors: Airbnb Rausch for `AppMode.hotWallet`, and xAI Cosmic Monochrome for `AppMode.coldWallet` and `AppMode.init`.
- Support consistent Apple-styled typography (SF Pro Display / Text or fallback Inter with custom letter spacing and line heights).
- Provide unified spacing, border radius, and component-specific style properties (e.g. padding, button size, elevations).
- Clean up any hardcoded layout properties by migrating them to design token references.

**Non-Goals:**
- Implementing actual widget refactoring (which is out of scope for the token definitions themselves, though the tokens should be designed to support the refactoring).
- Modifying Rust core logic or FFI models (only consume the existing `AppMode` enum).

## Decisions

### 1. Structure of DesignTokens
We will define a `DesignTokens` class containing static constants for spacing and border radius (since they are constant across both modes), and instance/getter-based access for mode-dependent tokens like colors and components.

**Alternatives considered:**
- *Alternative A: Global functions or separate classes for Hot/Cold.* This makes consumption verbose and error-prone as the developer has to manually select the class.
- *Alternative B: Flutter's standard `ThemeData`.* While standard, the custom design tokens (like specific component styles, custom spacing names like `xxs`, `section`, custom typography roles like `lead-airy`) don't map cleanly to standard Material `ThemeData` fields. A custom `DesignTokens` helper class provides a much cleaner, direct mapping to `DESIGN.md`.

### 2. Resolving Font Families
For typography, since SF Pro is not bundled but resolves to system-ui on iOS/macOS, we will specify font families with fallbacks:
`SF Pro Display, system-ui, -apple-system, sans-serif` for Display.
`SF Pro Text, system-ui, -apple-system, sans-serif` for Text.
In Flutter, we can represent these using `TextStyle` with appropriate `fontFamily`, `fontSize`, `fontWeight`, `height` (lineHeight / fontSize), and `letterSpacing`.

### 3. Binding to AppMode
We will provide a `DesignTokens.of(AppMode mode)` factory/constructor or a getter that returns a mode-specific token instance:
`DesignTokens.hot()` for Hot Wallet and `DesignTokens.cold()` for Cold Wallet / unselected state.
This allows widgets to dynamically look up the active theme using the current `AppMode` emitted from the stream.

## Risks / Trade-offs

- **[Risk]** Font rendering variance on Android/Windows/Linux where SF Pro is not present.
  - **Mitigation**: Fall back to `system-ui` and standard sans-serif, and apply custom letter spacing and height settings to approximate the "Apple tight" look on Inter or system defaults.
- **[Risk]** Redundant boilerplate for component structures.
  - **Mitigation**: Group component-specific styles inside a `ComponentTokens` class nested within or referenced by `DesignTokens`.

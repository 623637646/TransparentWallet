## Context

The Janus Wallet user interface contains hardcoded design parameters (colors, font family stacks, spacing, and sizing) instead of utilizing the centralized `DesignTokens` implementation. This prevents proper aesthetic transition when switching between the warm Airbnb Rausch theme (Hot Wallet mode) and the minimalist engineering-cosmic xAI theme (Cold/Unselected modes).

To resolve this, we will introduce a theme provider architecture using an `InheritedWidget` to propagate design tokens down the widget tree, and refactor all existing UI widgets to consume spacing, typography, border radius, and component-specific style tokens from this central store.

## Goals / Non-Goals

**Goals:**
- Eliminate all hardcoded color, typography, spacing, border radius, and component style specifications in the UI layer.
- Propagate `DesignTokens` reactively from the root using a custom `DesignTheme` `InheritedWidget`.
- Configure `MaterialApp` theme parameters to dynamically match active mode tokens.
- Apply tokens systematically to `my_app.dart`, `onboarding_screen.dart`, `cold_wallet_home.dart`, and `hot_wallet_home.dart`.

**Non-Goals:**
- Changing the layout, text, localized keys, or core business logic of the UI screens.
- Modifying the core design token values or the FFI api boundaries.

## Decisions

### 1. Centralized Theme Propagation via `DesignTheme`
To avoid prop-drilling `DesignTokens` through widgets, we will define a custom `InheritedWidget` named `DesignTheme` inside `design_tokens.dart`.
- **Alternatives Considered:**
  1. *Prop-drilling*: Explicitly passing `DesignTokens` to every widget constructor. Rejected due to high maintenance overhead and poor readability.
  2. *Global Static Reference*: Querying `appContext` synchronously within each widget and resolving tokens. Rejected because FFI calls to `appContext` are asynchronous and we cannot fetch the current mode synchronously without subscribing to the stream.
- **Rationale:** `InheritedWidget` is the standard, highly efficient, and idiomatic Flutter pattern for propagating styling contexts.

### 2. StreamBuilder Placement in `MyApp`
We will hoist the `StreamBuilder<AppMode>` to wrap the `MaterialApp` widget.
- **Alternatives Considered:**
  1. *Keeping StreamBuilder in MaterialApp home*: Only child routes would be inside the builder, keeping the main `MaterialApp` theme static.
- **Rationale:** Wrapping `MaterialApp` in `StreamBuilder` allows us to customize the root `ThemeData` parameters (like primary color, seed color, canvas color, and font fallback family) dynamically according to the active `AppMode` token set, providing a seamless visual transition at the system level.

## Risks / Trade-offs

### [Risk] Font Family Resolution on Diverse Platforms
- **Context:** The design system uses `SF Pro Display` and `SF Pro Text` with fallback to `Inter` on non-Apple devices.
- **Risk:** If fonts are not bundled or system fallbacks fail, text rendering could look basic or default.
- **Mitigation:** Ensure fallback stacks (e.g. `'SF Pro Text', 'system-ui', '-apple-system', 'sans-serif'`) are correctly configured in `TypographyTokens` and respect browser/system defaults.

### [Risk] Frequent Widget Rebuilds
- **Context:** Placing `StreamBuilder` above `MaterialApp` means the entire tree rebuilds when the stream updates.
- **Risk:** Potential performance lag on lower-end devices.
- **Mitigation:** The `appModeStream` only emits on startup or when the user manually changes the wallet mode (e.g., during onboarding or reset), which are extremely low-frequency events. The performance impact is completely negligible.

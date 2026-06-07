## Why

Currently, the application lacks a centralized design tokens system, resulting in either hardcoded colors/spacing or a lack of unified style tokens that implement the Apple-styled dual-mode wallet design specified in `DESIGN.md`. Centralizing these tokens in Dart is necessary to enable unified theme styling, eliminate hardcoded UI parameters, and support clean transitioning between Hot Wallet mode (Airbnb Rausch styling) and Cold Wallet/Unselected mode (xAI cosmic monochrome styling).

## What Changes

- Introduce a new centralized design tokens file (`lib/src/utils/design_tokens.dart`) that exposes colors, typography, border radius, spacing, elevation, and component configurations for both Hot and Cold wallet modes.
- Define a capability spec (`design-tokens`) to detail the requirements for the design token system, including token structures and how they dynamically swap based on the current app mode.

## Capabilities

### New Capabilities
- `design-tokens`: Defines the requirements, schemas, and structure of the design tokens system that governs colors, typography, spacing, border radii, and component styles for the dual-mode application.

### Modified Capabilities

## Impact

- Affects UI widgets (`lib/src/widgets/`) by providing the styling foundations they must consume instead of using hardcoded design properties.
- Integrates with the application state/context (`lib/src/utils/app_context.dart`) to reactively update the theme when the app mode changes.

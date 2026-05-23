## Why

Currently, the user interface code (including `my_app.dart`, `onboarding_screen.dart`, `cold_wallet_home.dart`, and `hot_wallet_home.dart`) contains hardcoded colors, typography, margins, border radii, and styles. This violates the specification of centralized design token accessibility and dynamic mode adaptation, making theme switches inconsistent and updates difficult to maintain. Fulfilling the integration of `design_tokens.dart` into all UI code ensures strict adherence to `DESIGN.md` across both Hot Wallet (Airbnb Rausch) and Cold/Unselected (xAI Cosmic Monochrome) modes.

## What Changes

- Refactor `my_app.dart` to resolve `DesignTokens` dynamically based on the active `AppMode` stream and supply it/theme data properly.
- Refactor `onboarding_screen.dart` to use centralized spacing, rounded corner radius, typography styles, and button component style tokens from `DesignTokens`.
- Refactor `cold_wallet_home.dart` to consume dynamic and static tokens from `DesignTokens` for background colors, text styles, icons, and buttons.
- Refactor `hot_wallet_home.dart` to consume dynamic and static tokens from `DesignTokens` for background colors, text styles, icons, and buttons.
- Ensure all hardcoded UI styling configurations are completely replaced with clean, semantic calls to `DesignTokens`.

## Capabilities

### New Capabilities
<!-- Capabilities being introduced. Replace <name> with kebab-case identifier (e.g., user-auth, data-export, api-rate-limiting). Each creates specs/<name>/spec.md -->

### Modified Capabilities
<!-- Existing capabilities whose REQUIREMENTS are changing (not just implementation).
     Only list here if spec-level behavior changes. Each needs a delta spec file.
     Use existing spec names from openspec/specs/. Leave empty if no requirement changes. -->
- `user-onboarding`: Align typography requirements with SF Pro / Inter font families defined in DesignTokens.

## Impact

- `lib/src/widgets/my_app.dart`: The theme configuration and loading/error states will be styled using `DesignTokens`.
- `lib/src/widgets/onboarding_screen.dart`: Carousel cards, buttons, indicators, and animation details will be styled using `DesignTokens`.
- `lib/src/widgets/cold_wallet_home.dart`: Title text, description text, and reset button will be styled using `DesignTokens`.
- `lib/src/widgets/hot_wallet_home.dart`: Title text, description text, and reset button will be styled using `DesignTokens`.

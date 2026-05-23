## Context

The entry point of the Flutter application `lib/main.dart` initializes the Rust FFI context (`appContext`) and runs `MyApp` (`lib/src/widgets/my_app.dart`).
Currently, `MyApp` is empty and throws `UnimplementedError`. We need to design a reactive UI that dynamically listens to the application execution mode (`AppMode`) and directs the user to the onboarding flow when the mode is `AppMode.init`.

## Goals / Non-Goals

**Goals:**
- Implement reactive routing in `MyApp` based on `appContext.appModeStream()`.
- Create a multi-slide horizontal onboarding carousel with smooth animations and page indicators.
- Style the onboarding interface according to `DESIGN.md` (clean typography, flat white/black color palette, and pill-shaped controls).
- Provide options to set the wallet execution mode (Cold vs. Hot Wallet) which transitions the user out of the onboarding experience.
- Define localized content strings for English and Chinese locales reactive to language change.

**Non-Goals:**
- Implementing the detailed functional interfaces of the Cold Wallet and Hot Wallet homes. The home screens will display simple placeholder layouts for now.

## Decisions

### 1. Reactive Routing in `MyApp`
We will use a `StreamBuilder` combined with `convertSubscriptionToStream` from `bridge_helper.dart` to consume `appContext.appModeStream`.
- While waiting for the stream to emit, we render a blank white screen (Level 0 canvas).
- If `AppMode.init`, we navigate to/render `OnboardingScreen`.
- If `AppMode.coldWallet`, we render `ColdWalletHomeScreen`.
- If `AppMode.hotWallet`, we render `HotWalletHomeScreen`.

### 2. Onboarding Page Layout & Carousel
We will create `OnboardingScreen` using a Flutter `PageView` combined with a bottom navigation row containing:
- Page indicators (dots/pills indicating the active page).
- Swipe/Next navigation buttons.
- On the final page of the carousel, we present the two primary action buttons: **Cold Wallet** and **Hot Wallet**.
- All text on the onboarding pages will be localized using `LocalizedText`.

### 3. Design System Alignment (`DESIGN.md`)
- **Background**: Soft clean background `#ffffff`.
- **Text Style**: Display headers in bold Inter (acting as `UberMove`) with size `32px` or `24px` (`display-lg` / `display-md`). Paragraphs in Inter (`UberMoveText`) at `16px` (`body-md`).
- **Button Styling**: Primary buttons will be Ink Black `#000000` with white text, and a border radius of `{rounded.pill}` (999px) to conform with `button-primary` in the design specifications.
- **Indicators**: Page indicators will use standard dots/pills using `#000000` for the active page, and `#efefef` (`colors.canvas-soft`) for inactive pages.

### 4. Localization Keys Schema
New keys will be added to `rust_wallet/locales/en/main.ftl` and `rust_wallet/locales/zh/main.ftl`:
- `onboarding-title-1`: Slide 1 Header (e.g., "Welcome to Janus")
- `onboarding-body-1`: Slide 1 Description (e.g., "Your decentralized gateway to secure key management.")
- `onboarding-title-2`: Slide 2 Header (e.g., "Two Operating Modes")
- `onboarding-body-2`: Slide 2 Description (e.g., "Run as a secure offline Cold Wallet or a convenient Hot Wallet.")
- `onboarding-title-3`: Slide 3 Header (e.g., "Choose Your Mode")
- `onboarding-body-3`: Slide 3 Description (e.g., "Select an operating mode to initialize your wallet and get started.")
- `onboarding-btn-cold`: "Cold Wallet"
- `onboarding-btn-hot`: "Hot Wallet"
- `cold-wallet-title`: "Cold Wallet Mode"
- `hot-wallet-title`: "Hot Wallet Mode"

## Risks / Trade-offs

- **[Risk] State Transition Glitch**: There might be a momentary flicker during the transition from `AppMode.init` to `AppMode.coldWallet`/`AppMode.hotWallet` when updating the database.
  - *Mitigation*: Ensure the stream rebuild is smooth, and show a clean transition overlay or loading indicator if database write is not instantaneous.
- **[Risk] Screen Overflow**: Long localized text might overflow small device screens.
  - *Mitigation*: Wrap slide content with `SingleChildScrollView` to prevent layout issues.

## Context

The application currently has localization support built into the Rust core using Fluent templates, and exposes translation lookups and selected language preference stream to the Flutter UI layer. We want to add a language selection button and bottom sheet on the onboarding screen without modifying the Rust backend or exposing new FFI APIs, utilizing only the existing `appContext.setLanguage` and `appContext.languageStream` APIs.

## Goals / Non-Goals

**Goals:**
- Provide a clean and beautiful language selection button on the onboarding screen.
- The button displays the currently active language resolved by the app (e.g., "English" or "简体中文").
- Tapping the button opens a premium modal bottom sheet from the bottom of the screen.
- The bottom sheet offers all supported languages (English, Chinese) and a "System Language" option.
- Choosing "System Language" sets the selected language to `null` by calling `appContext.setLanguage(language: null)`.
- The selection is fully reactive, updating the onboarding button and all other localized texts immediately.

**Non-Goals:**
- Modifying the Rust core or exposing new FFI APIs.
- Designing language selection for other screens in this task.

## Decisions

### 1. Pure-Dart Active Language Resolution
Since we will not add any new Rust FFI endpoints, the Flutter layer will listen to `appContext.languageStream()` to get the selected language setting (which is of type `Language?` where `null` means "System Language").
- When the stream emits a specific language (e.g., `Language.english` or `Language.chinese`), the UI will display that language name.
- When the stream emits `null` (representing "System Language"), the Dart UI code will inspect the system locale using `PlatformDispatcher.instance.locale` or `PlatformDispatcher.instance.locales`. If the primary system locale's language code starts with "zh", the UI will display "简体中文"; otherwise, it will display "English".
- This ensures the UI displays the correct resolved language name when "System Language" is selected.

### 2. Localization Keys
Add translation keys in `rust_wallet/locales/en/main.ftl` and `rust_wallet/locales/zh/main.ftl`:
- `language-selection-title`
- `language-option-system`
- `language-option-en`
- `language-option-zh`

### 3. UI Component and Layout
- The language selection button will be placed at the top-right of the onboarding screen, in a clean, elegant chip style following `DESIGN.md`.
- The bottom sheet will follow the design system with:
  - Canvas background.
  - Smooth rounded corners (border radius).
  - Harmony colors and typography tokens.
  - A checkmark icon next to the active selection.

## Risks / Trade-offs

- *Risk*: Discrepancy between system language negotiation in Dart vs Rust.
  - *Mitigation*: Our app only supports English and Chinese. We check if the primary system language starts with "zh", which matches Rust's simple fallback logic. Therefore, the Dart-side resolution is robust and will match Rust's behavior.

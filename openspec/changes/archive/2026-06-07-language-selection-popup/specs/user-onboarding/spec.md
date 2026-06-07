## ADDED Requirements

### Requirement: Language selection and configuration during onboarding
The onboarding screen SHALL feature a language selection button displaying the currently active language (e.g. "English" or "简体中文"). When the user taps the language selection button, the application SHALL display a modal bottom sheet popup showing all available language options (English, Chinese) and a "System Language" option. Selecting an option SHALL trigger `appContext.setLanguage`. Specifically:
- If the user selects "System Language", the application SHALL call `appContext.setLanguage(language: null)`.
- If the user selects a specific language, the application SHALL call `appContext.setLanguage(language: Language.<selected>)`.
The language selection button SHALL dynamically display the actual resolved/effective language (e.g., "English" or "简体中文") in the current UI language, regardless of whether the selected language setting is a specific language or set to "System Language".

#### Scenario: Displaying current resolved language on onboarding screen
- **WHEN** the application is on the onboarding screen and the active language resolved by the system is Chinese
- **THEN** the language selection button displays "简体中文"

#### Scenario: Selecting a specific language from bottom sheet
- **WHEN** the user taps the language selection button, selects "English" from the bottom sheet
- **THEN** the application calls `appContext.setLanguage(language: Language.english)` and the UI updates to English

#### Scenario: Selecting System Language from bottom sheet
- **WHEN** the user taps the language selection button, selects "System Language" from the bottom sheet
- **THEN** the application calls `appContext.setLanguage(language: null)` and the UI language updates to match the system language

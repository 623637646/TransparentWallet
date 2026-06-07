## Why

Users currently do not have a way to change the application language during the onboarding process. Providing a language selection bottom sheet on the onboarding screen improves the first-run experience, especially for users who prefer a language other than the system default.

## What Changes

- Add a language selection button to the onboarding screen that displays the name of the currently active language.
- Tapping this button will display a bottom sheet modal popup.
- The bottom sheet popup will offer the supported languages (English, Chinese) and a "System Language" option.
- If the user selects "System Language", the app language is set to follow the system settings (calling `appContext.setLanguage(language: null)`).
- The onboarding button will resolve the system language to display the correct locale name (e.g., "English" or "简体中文") instead of the literal text "System Language" when that option is selected.

## Capabilities

### New Capabilities

### Modified Capabilities
- `user-onboarding`: Add language selection button on the onboarding screen, a bottom sheet language selection dialog, and support for setting language preference (including system language option).

## Impact

- Flutter onboarding screen UI components and layout.
- Translation file keys for language names (e.g. English, Chinese, System Language).

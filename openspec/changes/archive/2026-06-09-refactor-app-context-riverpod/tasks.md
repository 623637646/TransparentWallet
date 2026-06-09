## 1. Setup

- [x] 1.1 Add `flutter_riverpod` to dependencies in `pubspec.yaml`
- [x] 1.2 Run `flutter pub get` to download dependencies

## 2. Refactor AppContext Provider

- [x] 2.1 Refactor `lib/src/utils/app_context.dart` to define the `appContextProvider` provider
- [x] 2.2 Update `lib/src/utils/app_context.dart` to return the initialized `Context` from `initAppContext()` instead of storing it in a global mutable variable
- [x] 2.3 Update `lib/main.dart` to wrap the app root with `ProviderScope` and override `appContextProvider` with the initialized `Context`

## 3. Refactor Widgets to use Riverpod

- [x] 3.1 Refactor `RustStreamBuilder` in `lib/src/widgets/common/rust_stream_builder.dart` to extend `ConsumerStatefulWidget` and read context from `appContextProvider`
- [x] 3.2 Refactor `LocalizedText` in `lib/src/widgets/common/localized_text.dart` to remove `appContext` from its constructor parameters
- [x] 3.3 Update all widgets consuming `LocalizedText` (e.g. homes, onboarding, bottom sheets, settings) to remove the `appContext` parameter from the constructor calls
- [x] 3.4 Refactor other widgets accessing `appContext` directly (like `SettingsScreen`, `OnboardingScreen`, `PinBottomSheet`) to use Riverpod (`ConsumerWidget` or `ConsumerStatefulWidget`) and resolve context from the provider

## 4. Verification and Cleanup

- [x] 4.1 Run Dart analyzer to ensure no warnings or errors exist
- [x] 4.2 Run app tests (if any) or verify that the app compiles and launches successfully
- [x] 4.3 Update directory structure in `AGENTS.md` using the automated skill

## 1. Setup & Custom Handler Implementation

- [x] 1.1 Create `lib/src/utils/ffi_logging_handler.dart` containing `CustomLoggingHandler` which extends `BaseHandler`
- [x] 1.2 Implement dynamic parameter masking in `CustomLoggingHandler` for keywords such as "pin", "password", "secret", "key", "seed"
- [x] 1.3 Implement execution timing and log wrappers for `executeNormal` in `CustomLoggingHandler`
- [x] 1.4 Implement execution timing and log wrappers for `executeSync` in `CustomLoggingHandler`
- [x] 1.5 Implement interceptor and log wrapper for `dartFnInvoke` in `CustomLoggingHandler`

## 2. Integration & Initialization

- [x] 2.1 Update `lib/main.dart` to import `package:janus_wallet/src/utils/ffi_logging_handler.dart`
- [x] 2.2 Modify `RustLib.init()` invocation in `main.dart` to use `CustomLoggingHandler` as the custom handler parameter

## 3. Code Quality & Formatting

- [x] 3.1 Format all modified files using `dart format`
- [x] 3.2 Verify that the project compiles and builds successfully

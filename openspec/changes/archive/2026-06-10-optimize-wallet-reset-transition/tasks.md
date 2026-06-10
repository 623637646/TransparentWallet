## 1. Transition Switcher & Clipper

- [x] 1.1 Create `RadialRevealClipper` extending `CustomClipper<Path>` to clip layouts to a circle centered on the screen.
- [x] 1.2 Implement the stateful `AppModeRevealSwitcher` to manage a `Stack` of old and new `MaterialApp` instances during app mode transitions, running a 650ms circular reveal and ignoring pointer events on the bottom widget.

## 2. Root App Integration

- [x] 2.1 Refactor `lib/src/widgets/my_app.dart` to use `AppModeRevealSwitcher` for reactive transitions between modes.
- [x] 2.2 Configure isolated `DesignTheme` providers inside each MaterialApp instance to support theme preservation during animations.

## 3. Settings Screen Cleanup

- [x] 3.1 Modify the reset callback in `lib/src/widgets/settings_screen.dart` to rely purely on state-driven mode transitions, removing manual navigation pop commands.

## 4. Verification & Formatting

- [x] 4.1 Verify transitions between onboarding, hot wallet, and cold wallet interfaces in both directions (forward and reset).
- [x] 4.2 Formats all modified Dart files using `dart format` to comply with the project formatting rules.

## ADDED Requirements

### Requirement: Symmetrical Radial Reveal App Mode Transition
The root of the application SHALL wrap the active `MaterialApp` in a transition-aware switcher. When transitioning between `AppMode` states (both entering cold/hot wallet modes from onboarding, and returning to onboarding upon a wallet reset), the application SHALL run a symmetrical radial reveal (circular clip) animation.
1. The new `MaterialApp` instance corresponding to the destination mode SHALL be positioned on top of the old `MaterialApp` instance inside a `Stack`.
2. The top `MaterialApp` SHALL clip its layout to an expanding circle centered on the screen, growing from a fraction of 0.0 to 1.0 (covering the entire screen diagonal).
3. The bottom `MaterialApp` SHALL be wrapped in an `IgnorePointer` during the animation to disable all touch interactions and prevent gesture bleed.
4. Upon animation completion, the bottom `MaterialApp` and its entire navigator stack SHALL be removed from the widget tree and destroyed.

#### Scenario: App mode transition runs radial reveal animation
- **WHEN** the `AppMode` changes (either from init to hot/cold wallet, or from hot/cold wallet back to init)
- **THEN** the application launches the target MaterialApp in a Stack, runs the expanding circular reveal animation from the center, blocks gestures on the bottom MaterialApp, and disposes the old MaterialApp on completion

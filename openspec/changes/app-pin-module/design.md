## Context

To secure sensitive wallet operations, we are introducing a 6-digit PIN authentication module. It will support PIN creation, modification, and verification flows. We will integrate it with the Settings Screen and reset-wallet-mode confirmation sequence.

## Goals / Non-Goals

**Goals:**
- Implement a modal bottom sheet displaying a custom numeric keypad (0-9, backspace) for 6-digit PIN entry.
- Integrate the PIN creation, verification, and modification flows.
- Update Settings Screen to display "Create PIN" or "Modify PIN" dynamically.
- Require PIN verification before performing the "Reset Wallet Mode" operation if a PIN is set.
- Adhere to `design_tokens.dart` and use `LocalizedText` for internationalization.

**Non-Goals:**
- Adding biometric (FaceID/TouchID) validation.
- Allowing PIN lengths other than 6 digits.

## Decisions

### Decision 1: Custom numeric keypad vs. system keyboard
- **Rationale**: A custom numeric grid rendered inside the bottom sheet guarantees consistent layout, eliminates standard keyboard height/dismissal headaches, and provides a secure input interface for a crypto wallet.
- **Alternatives considered**: standard system numeric keyboard (discarded due to unpredictable overlay behaviors on bottom sheets and platform visual mismatches).

### Decision 2: State management and confirmation flow inside a single bottom sheet
- **Rationale**: While creating or modifying a PIN, the user has to input and confirm the new PIN. Keeping the state inside a single `StatefulWidget` bottom sheet allows transition animations and messages to show smoothly without opening and closing multiple screens.
- **Alternatives considered**: Separate bottom sheets for initial input and confirmation (discarded because it creates visual flicker and a disjointed user experience).

## Risks / Trade-offs

- **Risk**: User accidentally cancels the sheet during PIN verification (e.g. by tapping outside).
  - **Mitigation**: Standardize on returning `false` or `null` from the bottom sheet `show` method when dismissed, treating cancellation as verification failure and halting the calling operation (e.g., wallet reset).

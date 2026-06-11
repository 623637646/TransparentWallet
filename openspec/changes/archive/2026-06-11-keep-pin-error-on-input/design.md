## Context

The current `PinBottomSheet` implementation clears `_errorMessage` and `_errorArgs` inside `_onKeyTap` and `_onBackspace` methods when the user interacts with the custom pinpad. This causes the error feedback (e.g. incorrect PIN red message) to vanish as soon as the user starts inputting their next attempt.

## Goals / Non-Goals

**Goals:**
- Retain the error message/red reminder when the user enters or deletes digits during a new PIN attempt.
- Clear the error message when the user successfully transitions to another step/flow (e.g. from entering an old PIN to entering a new PIN in Modify mode, or from entering a first PIN to confirming it in Create mode).

**Non-Goals:**
- Changing how PIN verification results are fetched or handled.
- Modifying the styling or positioning of the error label itself.

## Decisions

### Decision: State preservation in key/backspace event handlers
- Remove the state updates that set `_errorMessage` and `_errorArgs` to `null` inside `_onKeyTap` and `_onBackspace`.
- Rationale: This ensures that when the user begins typing, the error message remains visible on the screen.

### Decision: Explicit error clearing on flow transitions
- Explicitly set `_errorMessage = null` and `_errorArgs = null` within `setState` blocks in `_onSubmit()` when transitioning to another PIN step (such as from `PinStep.createEnterNew` to `PinStep.createConfirmNew`, or from `PinStep.modifyEnterOld` to `PinStep.createEnterNew`).
- Rationale: This prevents stale errors from carrying over to a different screen/step where they do not apply.

## Risks / Trade-offs

- **Risk**: Stale error message displayed in a new screen/step if transitions don't clear the error state.
  - **Mitigation**: Ensure that every state transition in `_onSubmit` (that changes `_step`) explicitly clears `_errorMessage` and `_errorArgs`.

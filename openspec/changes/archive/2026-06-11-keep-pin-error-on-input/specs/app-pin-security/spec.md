## MODIFIED Requirements

### Requirement: Create PIN flow
The system SHALL execute the Create PIN flow when the PIN bottom sheet is launched in "Create" mode:
1. The user SHALL be prompted to enter a new 6-digit PIN.
2. After entering 6 digits, the UI SHALL clear the input and prompt the user to confirm the new PIN by entering it again. The bottom sheet SHALL NOT close during this step.
3. If the confirmation PIN matches the first PIN, the system SHALL call FFI to create the PIN and close the bottom sheet, notifying the caller of success.
4. If the confirmation PIN does not match, the system SHALL display a mismatch error message, clear the input, and allow the user to try again. The bottom sheet SHALL NOT close.
5. Any displayed mismatch error message SHALL persist when the user begins entering a new PIN input attempt (it MUST NOT be cleared automatically when numeric keys are tapped or backspace is used) and SHALL only be updated or cleared upon submitting a new attempt or transitioning to a different step.

#### Scenario: Create PIN success with matching confirmation
- **WHEN** the user is in "Create" mode, enters "123456", and then enters "123456" again
- **THEN** the system calls the API to create the PIN, closes the bottom sheet, and returns success

#### Scenario: Create PIN fails with mismatch
- **WHEN** the user is in "Create" mode, enters "123456", and then enters "111111"
- **THEN** the system displays a mismatch error, keeps the sheet open, and lets the user try again

### Requirement: Modify PIN flow
The system SHALL execute the Modify PIN flow when the PIN bottom sheet is launched in "Modify" mode:
1. The user SHALL first be prompted to enter the old 6-digit PIN.
2. The system SHALL verify the old PIN. If the entered PIN is incorrect, the system SHALL display an error message and let the user try again. The bottom sheet SHALL NOT close.
3. Any displayed incorrect PIN error message SHALL persist when the user begins entering a new PIN input attempt (it MUST NOT be cleared automatically when numeric keys are tapped or backspace is used) and SHALL only be updated or cleared upon submitting a new attempt or transitioning to a different step.
4. Once the old PIN is correctly verified, the UI SHALL transition to the "Create PIN" flow (prompting for the new PIN and its confirmation).
5. Upon successful confirmation, the system SHALL call FFI to update the PIN with the old and new PINs, and then close the bottom sheet.

#### Scenario: Modify PIN with correct old PIN and matching new PIN
- **WHEN** the user is in "Modify" mode, enters the correct old PIN, enters a new PIN, and enters the matching new PIN again
- **THEN** the system updates the PIN, closes the bottom sheet, and returns success

#### Scenario: Modify PIN with incorrect old PIN
- **WHEN** the user is in "Modify" mode and enters an incorrect old PIN
- **THEN** the system displays an error, keeps the sheet open, and lets the user try again

### Requirement: Verify PIN flow
The system SHALL execute the Verify PIN flow when the PIN bottom sheet is launched in "Verify" mode:
1. The user SHALL be prompted to enter their current 6-digit PIN.
2. The system SHALL verify the entered PIN.
3. If correct, the system SHALL close the bottom sheet and return success to the caller.
4. If incorrect, the system SHALL display an error, keep the bottom sheet open, and allow the user to try again.
5. Any displayed incorrect PIN error message SHALL persist when the user begins entering a new PIN input attempt (it MUST NOT be cleared automatically when numeric keys are tapped or backspace is used) and SHALL only be updated or cleared upon submitting a new attempt or transitioning to a different step.
6. If the user cancels the bottom sheet, the system SHALL return failure/cancelled to the caller.

#### Scenario: Verify PIN succeeds
- **WHEN** the user is in "Verify" mode and enters the correct PIN
- **THEN** the system verifies the PIN, closes the bottom sheet, and returns success

#### Scenario: Verify PIN fails
- **WHEN** the user is in "Verify" mode and enters an incorrect PIN
- **THEN** the system displays an error, keeps the sheet open, and lets the user try again

#### Scenario: Verify PIN cancelled
- **WHEN** the user is in "Verify" mode and dismisses the bottom sheet without entering the correct PIN
- **THEN** the system returns cancellation to the caller

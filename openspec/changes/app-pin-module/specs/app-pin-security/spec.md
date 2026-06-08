## ADDED Requirements

### Requirement: App PIN UI structure and layout
The application SHALL provide a PIN input UI in the form of a modal bottom sheet.
1. The PIN input area SHALL support exactly 6 numeric characters (0-9).
2. The UI SHALL be dynamically styled utilizing tokens from `design_tokens.dart` resolved via the active `DesignTheme.of(context)`.
3. It SHALL use `LocalizedText` for all user-visible text (e.g., titles, prompts, error messages).
4. The UI SHALL show a grid of numbers (0-9) and a backspace button for user input, rather than relying on the system keyboard, ensuring a consistent custom secure layout.

#### Scenario: PIN bottom sheet renders with custom numeric keypad
- **WHEN** the PIN bottom sheet is displayed
- **THEN** it renders a custom numeric grid (0-9), backspace, and placeholder dots for the 6-digit PIN code, styled with DesignTheme tokens

### Requirement: Create PIN flow
When the PIN bottom sheet is launched in "Create" mode:
1. The user SHALL be prompted to enter a new 6-digit PIN.
2. After entering 6 digits, the UI SHALL clear the input and prompt the user to confirm the new PIN by entering it again. The bottom sheet SHALL NOT close during this step.
3. If the confirmation PIN matches the first PIN, the system SHALL call FFI to create the PIN and close the bottom sheet, notifying the caller of success.
4. If the confirmation PIN does not match, the system SHALL display a mismatch error message, clear the input, and allow the user to try again. The bottom sheet SHALL NOT close.

#### Scenario: Create PIN success with matching confirmation
- **WHEN** the user is in "Create" mode, enters "123456", and then enters "123456" again
- **THEN** the system calls the API to create the PIN, closes the bottom sheet, and returns success

#### Scenario: Create PIN fails with mismatch
- **WHEN** the user is in "Create" mode, enters "123456", and then enters "111111"
- **THEN** the system displays a mismatch error, keeps the sheet open, and lets the user try again

### Requirement: Modify PIN flow
When the PIN bottom sheet is launched in "Modify" mode:
1. The user SHALL first be prompted to enter the old 6-digit PIN.
2. The system SHALL verify the old PIN. If the entered PIN is incorrect, the system SHALL display an error message and let the user try again. The bottom sheet SHALL NOT close.
3. Once the old PIN is correctly verified, the UI SHALL transition to the "Create PIN" flow (prompting for the new PIN and its confirmation).
4. Upon successful confirmation, the system SHALL call FFI to update the PIN with the old and new PINs, and then close the bottom sheet.

#### Scenario: Modify PIN with correct old PIN and matching new PIN
- **WHEN** the user is in "Modify" mode, enters the correct old PIN, enters a new PIN, and enters the matching new PIN again
- **THEN** the system updates the PIN, closes the bottom sheet, and returns success

#### Scenario: Modify PIN with incorrect old PIN
- **WHEN** the user is in "Modify" mode and enters an incorrect old PIN
- **THEN** the system displays an error, keeps the sheet open, and lets the user try again

### Requirement: Verify PIN flow
When the PIN bottom sheet is launched in "Verify" mode:
1. The user SHALL be prompted to enter their current 6-digit PIN.
2. The system SHALL verify the entered PIN.
3. If correct, the system SHALL close the bottom sheet and return success to the caller.
4. If incorrect, the system SHALL display an error, keep the bottom sheet open, and allow the user to try again.
5. If the user cancels the bottom sheet, the system SHALL return failure/cancelled to the caller.

#### Scenario: Verify PIN succeeds
- **WHEN** the user is in "Verify" mode and enters the correct PIN
- **THEN** the system verifies the PIN, closes the bottom sheet, and returns success

#### Scenario: Verify PIN fails
- **WHEN** the user is in "Verify" mode and enters an incorrect PIN
- **THEN** the system displays an error, keeps the sheet open, and lets the user try again

#### Scenario: Verify PIN cancelled
- **WHEN** the user is in "Verify" mode and dismisses the bottom sheet without entering the correct PIN
- **THEN** the system returns cancellation to the caller

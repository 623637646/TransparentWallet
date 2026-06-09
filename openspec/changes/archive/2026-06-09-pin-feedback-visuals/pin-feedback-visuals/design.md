## Context

The user wants the visual feedback for PIN operations (and potentially other actions) to be a top-floating Toast notification instead of an inline success state inside the bottom sheet.
The Toast component must:
1. Auto-dismiss after a duration.
2. Be completely non-blocking to all touch gestures (allowing users to continue interacting with the underlying UI, even under the toast area).
3. Have a dynamic duration based on message text length.
4. Be abstracted as a reusable utility.

## Goals / Non-Goals

**Goals:**
- Implement a reusable top-floating `Toast` notification system using Flutter's `Overlay`.
- Set `IgnorePointer(ignoring: true)` on the overlay entry to ensure zero gesture blockage.
- Compute show duration dynamically: `(1500 + length * 40).clamp(1500, 4000)`.
- Re-use theme tokens from [design_tokens.dart](file:///Users/yawang/Documents/janus_wallet-worktrees/AI/lib/src/utils/design_tokens.dart) for a premium, theme-conforming capsule design.
- Integrate the toast with [pin_bottom_sheet.dart](file:///Users/yawang/Documents/janus_wallet-worktrees/AI/lib/src/widgets/common/pin_bottom_sheet.dart) so the sheet pops immediately on success and displays the toast.

**Non-Goals:**
- Custom gestures on the toast itself (the toast is strictly non-interactive and passes all touches to the underlying UI).

## Decisions

### 1. Toast Implementation using Overlay and IgnorePointer
- **File**: `lib/src/widgets/common/toast.dart`
- **Class**: `Toast` with a static method `show(BuildContext context, String textId, {Map<String, String>? args})`.
- **Overlay Entry**: We will instantiate an `OverlayEntry` which puts the Toast at the top. The root of this entry will be wrapped in `IgnorePointer(ignoring: true)` to allow user gestures to pass through completely to the background UI.
- **Positioning**: Center-top of the screen below the status bar, using `MediaQuery.of(context).padding.top` for padding.

### 2. Animated Toast Widget
- A private stateful class `_ToastWidget` inside `toast.dart` will:
  - Fetch the localized translation asynchronously via `appContext.lookUpText`.
  - Drive a 300ms `AnimationController` for sliding down (`Tween<Offset>(begin: Offset(0, -1), end: Offset.zero)`) and fading in.
  - Calculate duration once the resolved translation is received.
  - Start a `Timer` to reverse the animation and remove the overlay entry when complete.

### 3. Aesthetics & Capsule Design
- **Shape**: Capsule shaped container with border radius `DesignTokens.rounded.pill`.
- **Background**: High contrast `tokens.colors.surfaceBlack` to stand out on any background.
- **Border**: Thin line matching `tokens.colors.hairline` or `tokens.colors.primary` for a glowing look.
- **Icon**: A success checkmark icon `Icons.check_circle_rounded` colored in `tokens.colors.primary` (warm Airbnb Rausch or monochrome white).
- **Text**: `LocalizedText` styled with `tokens.colors.bodyOnDark` (white) for maximum contrast.

### 4. PIN Integration
- When PIN creation, modification, or verification is successful:
  1. Call `Toast.show(context, 'pin-create-success')`, `Toast.show(context, 'pin-modify-success')`, or `Toast.show(context, 'pin-verify-success')`.
  2. Immediately dismiss the bottom sheet via `Navigator.of(context).pop(true);`.

## Risks / Trade-offs

- **Risk**: Calling `Toast.show` when the context is no longer valid or mounted.
- **Mitigation**: Perform a null check on the retrieved `OverlayState` and verify `context.mounted` before inserting the overlay entry.

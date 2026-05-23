## Context

The user onboarding screen has a horizontal swipeable carousel of 4 pages. Currently, it has a top bar (with skip and back buttons) and a bottom action area (with a next button on pages 1-3, transitioning to wallet selection buttons on page 4). This design needs simplification by removing skip, back, and next buttons, and repositioning the page indicators at the bottom in a stable manner.

## Goals / Non-Goals

**Goals:**
- Remove the top navigation row (containing back and skip buttons) from the onboarding layout.
- Remove the "Next" button from pages 1-3.
- Place the page indicators (progress dots) at the bottom of the control area.
- Maintain a stable bottom layout height (180px-200px) across all pages to ensure no layout shift or vertical jump of indicators/content when swiping.

**Non-Goals:**
- Changing the page swiping logic or PageView configuration.
- Modifying the text content or localizations.
- Modifying the animations of icons.

## Decisions

### Bottom Control Layout Structure
To ensure that page indicators do not shift vertically and the page content remains visually stable when transitioning to the final page (where wallet mode buttons appear), the bottom control column will structure components from top to bottom:
1. **Actions Container (`SizedBox` of height 124px)**:
   - On pages 1-3, this area renders a blank spacer (`SizedBox.shrink`).
   - On page 4, it renders the "Cold Wallet" and "Hot Wallet" buttons.
   - An `AnimatedSwitcher` handles the cross-fade animation between these states.
2. **Spacing (`SizedBox` of height 24px)**.
3. **Page Indicators (`Row` of dots)**:
   - Placed below the Actions Container so they are close to the bottom of the screen.
   - Position remains constant because the Actions Container height is fixed.

*Alternative Considered*: Putting the page indicator above the Actions Container.
- *Reason for Rejection*: If placed above, on pages 1-3 where the actions container is empty, there would be a large empty gap at the bottom of the screen, making the indicators look like they are floating too high up. Placing them below the actions ensures they sit nicely at the bottom on all pages.

### Top Layout Simplification
- Remove the top Row container entirely.
- Allow the `PageView` to start directly below the `SafeArea`, utilizing more vertical screen space.

## Risks / Trade-offs

- **[Risk] User confusion on navigation** → Swiping is the default gesture for carousels. Since there's no Next button, swiping is the only way to navigate. The dots/pills at the bottom provide clear feedback that swiping is expected.

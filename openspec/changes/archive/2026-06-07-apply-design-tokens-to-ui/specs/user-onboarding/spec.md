## MODIFIED Requirements

### Requirement: Onboarding carousel swiping and UI design
The onboarding screen SHALL feature a swipeable carousel container displaying 4 onboarding slides (Welcome, Cold Wallet Details, Hot Wallet Details, and Choose Mode). The onboarding screens SHALL follow `DESIGN.md` styling:
- Text font families: SF Pro Display / SF Pro Text (with Inter fallback) as defined in DesignTokens.
- Layout and margins: padding and spacing matching `DESIGN.md` base units (multiples of 4px).
- Styling: Flat white canvas (`#ffffff`) background, high contrast, clean geometry.
- Controls: Page indicators (dots/pills) showing current slide progress, with smooth transition animations. The indicators SHALL be positioned at the bottom of the controls area, below the actions.
- Bottom actions: The bottom controls and actions area MUST maintain a stable layout height of 180px across all slides (with no buttons displayed on earlier pages, and mode selection buttons displayed on the final page) to prevent vertical shifts of page indicators and slide contents during swiping.
- Localization: All text elements SHALL use `LocalizedText` referencing keys from the Fluent locales, reacting dynamically to language switches.

#### Scenario: Swiping onboarding carousel slides
- **WHEN** the user swipes horizontally on the onboarding carousel screen
- **THEN** the active slide updates with a smooth animation, the page indicator updates to reflect the new slide index, and the vertical position of page indicators remains completely stable with no layout shift.

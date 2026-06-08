## MODIFIED Requirements

### Requirement: Premium onboarding icon animations
Selected slides of the onboarding screen SHALL feature a premium, theme-specific, looping micro-animation on its illustration icon when active.
- Page 1 (Welcome): No animation. The system SHALL NOT register, start, or run animation tickers or controllers, and SHALL NOT trigger rebuilds for this page.
- Page 2 (Cold Wallet): A continuous slow rotation combined with a gentle scaling.
- Page 3 (Hot Wallet): A protective pulsing effect with an outer glowing ring/border scaling up and fading. The pulsing ripple effect SHALL NOT utilize offscreen layer blending or Opacity widgets that force saveLayer calls.
- Page 4 (Choose Mode): No animation. The system SHALL NOT register, start, or run animation tickers or controllers, and SHALL NOT trigger rebuilds for this page.

#### Scenario: Icon animation plays when page becomes active
- **WHEN** a slide in the onboarding carousel becomes the active page
- **THEN** its specific premium icon animation SHALL trigger and play continuously if defined for that page

#### Scenario: Idle pages do not run animation tickers
- **WHEN** the active page does not have a defined animation (Page 1 or Page 4)
- **THEN** the system SHALL NOT run any animation controller or ticker for that page

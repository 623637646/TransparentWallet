# Onboarding Animations

Purpose: Defines requirements for premium, interactive looping micro-animations on illustration icons for onboarding slides.

## Requirements

### Requirement: Premium onboarding icon animations
Selected slides of the onboarding screen SHALL feature a premium, theme-specific, looping micro-animation on its illustration icon when active.
- Page 1 (Welcome): No animation.
- Page 2 (Cold Wallet): A continuous slow rotation combined with a gentle scaling.
- Page 3 (Hot Wallet): A protective pulsing effect with an outer glowing ring/border scaling up and fading (previously Page 4's animation).
- Page 4 (Choose Mode): No animation.

#### Scenario: Icon animation plays when page becomes active
- **WHEN** a slide in the onboarding carousel becomes the active page
- **THEN** its specific premium icon animation SHALL trigger and play continuously if defined for that page

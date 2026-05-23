---
version: alpha
name: Apple-styled-dual-mode-wallet-design
description: A design system implementing Apple's photographic-first, high-end structure (typography, shapes, components, layout) with dual-mode color palettes: Airbnb's warm Rausch (#ff385c) palette for Hot Wallet mode, and xAI's minimalist engineering-cosmic white-on-near-black (#0a0a0a) palette for Non-Hot Wallet mode (including Cold Wallet mode and unselected state).

colors:
  hot:
    primary: "#ff385c"            # Airbnb Rausch
    primary-focus: "#e00b41"      # Airbnb Rausch Active
    primary-on-dark: "#ff385c"    # Rausch
    ink: "#222222"                # Airbnb Ink
    body: "#3f3f3f"               # Airbnb Body
    body-on-dark: "#ffffff"
    body-muted: "#6a6a6a"         # Airbnb Muted
    ink-muted-80: "#3f3f3f"       # Airbnb Body
    ink-muted-48: "#929292"       # Airbnb Muted Soft
    divider-soft: "#ebebeb"       # Airbnb Hairline Soft
    hairline: "#dddddd"           # Airbnb Hairline
    canvas: "#ffffff"             # Airbnb Canvas
    canvas-parchment: "#f7f7f7"   # Airbnb Surface Soft
    surface-pearl: "#fafafc"      # Pearl Button
    surface-tile-1: "#f7f7f7"     # Light tile 1
    surface-tile-2: "#f2f2f2"     # Light tile 2
    surface-tile-3: "#ebebeb"     # Light tile 3
    surface-black: "#222222"      # Airbnb Ink for void surfaces
    surface-chip-translucent: "#dddddd" # Airbnb Hairline
    on-primary: "#ffffff"
    on-dark: "#ffffff"
  cold: # Also represents unselected and general non-hot-wallet state
    primary: "#ffffff"            # xAI White
    primary-focus: "#fafaf7"      # xAI Ink Hover
    primary-on-dark: "#ffffff"    # xAI White
    ink: "#ffffff"                # xAI Ink
    body: "#dadbdf"               # xAI Body
    body-on-dark: "#ffffff"
    body-muted: "#7d8187"         # xAI Mute
    ink-muted-80: "#dadbdf"       # xAI Body
    ink-muted-48: "#7d8187"       # xAI Mute
    divider-soft: "#212327"       # xAI Hairline
    hairline: "#212327"           # xAI Hairline
    canvas: "#0a0a0a"             # xAI Canvas
    canvas-parchment: "#1a1c20"   # xAI Canvas Soft
    surface-pearl: "#191919"      # xAI Canvas Card
    surface-tile-1: "#191919"     # xAI Canvas Card
    surface-tile-2: "#1a1c20"     # xAI Canvas Soft
    surface-tile-3: "#0d1726"     # xAI Midnight
    surface-black: "#0a0a0a"      # xAI Canvas
    surface-chip-translucent: "#363a3f" # xAI Canvas Mid
    on-primary: "#0a0a0a"         # xAI On Primary (near-black)
    on-dark: "#ffffff"

typography:
  hero-display:
    fontFamily: "SF Pro Display, system-ui, -apple-system, sans-serif"
    fontSize: 56px
    fontWeight: 600
    lineHeight: 1.07
    letterSpacing: -0.28px
  display-lg:
    fontFamily: "SF Pro Display, system-ui, -apple-system, sans-serif"
    fontSize: 40px
    fontWeight: 600
    lineHeight: 1.1
    letterSpacing: 0
  display-md:
    fontFamily: "SF Pro Text, system-ui, -apple-system, sans-serif"
    fontSize: 34px
    fontWeight: 600
    lineHeight: 1.47
    letterSpacing: -0.374px
  lead:
    fontFamily: "SF Pro Display, system-ui, -apple-system, sans-serif"
    fontSize: 28px
    fontWeight: 400
    lineHeight: 1.14
    letterSpacing: 0.196px
  lead-airy:
    fontFamily: "SF Pro Text, system-ui, -apple-system, sans-serif"
    fontSize: 24px
    fontWeight: 300
    lineHeight: 1.5
    letterSpacing: 0
  tagline:
    fontFamily: "SF Pro Display, system-ui, -apple-system, sans-serif"
    fontSize: 21px
    fontWeight: 600
    lineHeight: 1.19
    letterSpacing: 0.231px
  body-strong:
    fontFamily: "SF Pro Text, system-ui, -apple-system, sans-serif"
    fontSize: 17px
    fontWeight: 600
    lineHeight: 1.24
    letterSpacing: -0.374px
  body:
    fontFamily: "SF Pro Text, system-ui, -apple-system, sans-serif"
    fontSize: 17px
    fontWeight: 400
    lineHeight: 1.47
    letterSpacing: -0.374px
  dense-link:
    fontFamily: "SF Pro Text, system-ui, -apple-system, sans-serif"
    fontSize: 17px
    fontWeight: 400
    lineHeight: 2.41
    letterSpacing: 0
  caption:
    fontFamily: "SF Pro Text, system-ui, -apple-system, sans-serif"
    fontSize: 14px
    fontWeight: 400
    lineHeight: 1.43
    letterSpacing: -0.224px
  caption-strong:
    fontFamily: "SF Pro Text, system-ui, -apple-system, sans-serif"
    fontSize: 14px
    fontWeight: 600
    lineHeight: 1.29
    letterSpacing: -0.224px
  button-large:
    fontFamily: "SF Pro Text, system-ui, -apple-system, sans-serif"
    fontSize: 18px
    fontWeight: 300
    lineHeight: 1.0
    letterSpacing: 0
  button-utility:
    fontFamily: "SF Pro Text, system-ui, -apple-system, sans-serif"
    fontSize: 14px
    fontWeight: 400
    lineHeight: 1.29
    letterSpacing: -0.224px
  fine-print:
    fontFamily: "SF Pro Text, system-ui, -apple-system, sans-serif"
    fontSize: 12px
    fontWeight: 400
    lineHeight: 1.0
    letterSpacing: -0.12px
  micro-legal:
    fontFamily: "SF Pro Text, system-ui, -apple-system, sans-serif"
    fontSize: 10px
    fontWeight: 400
    lineHeight: 1.3
    letterSpacing: -0.08px
  nav-link:
    fontFamily: "SF Pro Text, system-ui, -apple-system, sans-serif"
    fontSize: 12px
    fontWeight: 400
    lineHeight: 1.0
    letterSpacing: -0.12px

rounded:
  none: 0px
  xs: 5px
  sm: 8px
  md: 11px
  lg: 18px
  pill: 9999px
  full: 9999px

spacing:
  xxs: 4px
  xs: 8px
  sm: 12px
  md: 17px
  lg: 24px
  xl: 32px
  xxl: 48px
  section: 80px

components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.body}"
    rounded: "{rounded.pill}"
    padding: 11px 22px
  button-primary-focus:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.pill}"
  button-primary-active:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.pill}"
  button-secondary-pill:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.primary}"
    typography: "{typography.body}"
    rounded: "{rounded.pill}"
    padding: 11px 22px
  button-dark-utility:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.on-dark}"
    typography: "{typography.button-utility}"
    rounded: "{rounded.sm}"
    padding: 8px 15px
  button-pearl-capsule:
    backgroundColor: "{colors.surface-pearl}"
    textColor: "{colors.ink-muted-80}"
    typography: "{typography.caption}"
    rounded: "{rounded.md}"
    padding: 8px 14px
  button-store-hero:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.button-large}"
    rounded: "{rounded.pill}"
    padding: 14px 28px
  button-icon-circular:
    backgroundColor: "{colors.surface-chip-translucent}"
    textColor: "{colors.ink}"
    rounded: "{rounded.full}"
    size: 44px
  text-link:
    backgroundColor: transparent
    textColor: "{colors.primary}"
    typography: "{typography.body}"
  text-link-on-dark:
    backgroundColor: transparent
    textColor: "{colors.primary-on-dark}"
    typography: "{typography.body}"
  global-nav:
    backgroundColor: "{colors.surface-black}"
    textColor: "{colors.on-dark}"
    typography: "{typography.nav-link}"
    height: 44px
  sub-nav-frosted:
    backgroundColor: "{colors.canvas-parchment}"
    textColor: "{colors.ink}"
    typography: "{typography.tagline}"
    height: 52px
  product-tile-light:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.ink}"
    typography: "{typography.display-lg}"
    rounded: "{rounded.none}"
    padding: 80px
  product-tile-parchment:
    backgroundColor: "{colors.canvas-parchment}"
    textColor: "{colors.ink}"
    typography: "{typography.display-lg}"
    rounded: "{rounded.none}"
    padding: 80px
  product-tile-dark:
    backgroundColor: "{colors.surface-tile-1}"
    textColor: "{colors.on-dark}"
    typography: "{typography.display-lg}"
    rounded: "{rounded.none}"
    padding: 80px
  product-tile-dark-2:
    backgroundColor: "{colors.surface-tile-2}"
    textColor: "{colors.on-dark}"
    rounded: "{rounded.none}"
  product-tile-dark-3:
    backgroundColor: "{colors.surface-tile-3}"
    textColor: "{colors.on-dark}"
    rounded: "{rounded.none}"
  store-utility-card:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.ink}"
    typography: "{typography.body-strong}"
    rounded: "{rounded.lg}"
    padding: 24px
  configurator-option-chip:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.ink}"
    typography: "{typography.caption}"
    rounded: "{rounded.pill}"
    padding: 12px 16px
  configurator-option-chip-selected:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.ink}"
    rounded: "{rounded.pill}"
  search-input:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.ink}"
    typography: "{typography.body}"
    rounded: "{rounded.pill}"
    padding: 12px 20px
    height: 44px
  floating-sticky-bar:
    backgroundColor: "{colors.canvas-parchment}"
    textColor: "{colors.ink}"
    typography: "{typography.body}"
    height: 64px
    padding: 12px 32px
  environment-quote-card:
    backgroundColor: "{colors.surface-tile-1}"
    textColor: "{colors.on-dark}"
    typography: "{typography.display-lg}"
    rounded: "{rounded.none}"
    padding: 80px
  footer:
    backgroundColor: "{colors.canvas-parchment}"
    textColor: "{colors.ink-muted-80}"
    typography: "{typography.fine-print}"
    padding: 64px
---

## Overview

Apple's web presence is a masterclass in **reverent product photography framed by near-invisible UI**. Every page is a stack of edge-to-edge product "tiles" — alternating light and dark canvases, each centered on a hero headline, a one-line tagline, two tiny pill CTAs, and an impossibly crisp product/wallet render. Typography is confident but quiet.

In this unified wallet design system, the Apple design chassis is applied globally, but the color skin flips completely depending on the wallet mode:
1. **Hot Wallet Mode** uses the **Airbnb Rausch** color system: a warm, light-dominant, generous canvas.
2. **Cold Wallet & Unselected Mode** uses the **xAI cosmic monochrome** color system: a strict, engineering-first near-black canvas.

Across both modes, the typographic system, spacing rhythm, shapes, and component models are consistent — this is one design language (Apple) expressed through two distinct color modes.

Density is unusually low even by contemporary SaaS standards. Each tile occupies roughly one viewport, and there is no decorative chrome — no borders, no gradients, no decorative frames, no shadows on chrome, only the one signature drop-shadow under product/wallet imagery resting on a surface. The result is a dashboard that feels more like a museum gallery: the wall disappears and the asset takes over.

Store and shop surfaces retain the same chassis but switch modes. The wallet configuration flow introduces a tight grid of utility cards at `{rounded.lg}` (18px) radius with a thin border, paired with a persistent thin sub-nav strip. The editorial modes lean darker and more premium. Across all surfaces the typographic system, spacing rhythm, and the mode-specific accents are consistent — this is one design language expressed at different volumes.

**Key Characteristics:**
- Photography-first presentation; UI recedes so the wallet interfaces/renders can speak.
- Alternating full-bleed tile sections: base canvas ↔ contrast tile, with the color change itself acting as the section divider.
- Mode-specific primary accent (`{colors.primary}`) carries every interactive element.
- Two button grammars: tiny pill CTAs (`{rounded.pill}`) and compact utility rects (`{rounded.sm}`).
- SF Pro Display + SF Pro Text — negative letter-spacing at display sizes for the signature "Apple tight" headline feel.
- Whisper-soft elevation used only when a wallet render/image needs to breathe — exactly one drop-shadow in the entire system.
- Tight two-row nav: slim `{component.global-nav}` + product-specific `{component.sub-nav-frosted}` with persistent right-aligned primary CTA.
- Section rhythm across multiple pages: canvas hero → contrast wallet tile → utility tile → contrast tile → parchment footer — a predictable pulse.

---

## Colors

The application operates in two distinct color modes based on the active wallet mode:

### 1. Hot Wallet Mode (Airbnb Rausch Palette)
This mode is warm, approachable, and light-dominant, signaling the active, transactional nature of the hot wallet.
- **Rausch Red** (`{colors.primary}` — #ff385c): The single brand-level interactive color. Used for primary CTAs, active selectors, and accent highlights.
- **Rausch Active** (`{colors.primary-focus}` — #e00b41): Press/focus state for interactive elements.
- **Ink Text** (`{colors.ink}` — #222222): The near-black tone used for headlines and primary text to prevent harshness.
- **Body Text** (`{colors.body}` — #3f3f3f): Secondary running text.
- **Canvas Background** (`{colors.canvas}` — #ffffff): The default white background of the app.
- **Surface Soft** (`{colors.canvas-parchment}` — #f7f7f7): Soft background fill for alternating tiles or card backdrops.

### 2. Cold Wallet / Unselected Mode (xAI Monochrome Palette)
This mode is strict, technical, and dark-dominant, signaling the security, offline nature of the cold wallet or the neutral starting state.
- **White** (`{colors.primary}` — #ffffff): The primary accent color. Used for button outlines, focus rings, and high-emphasis displays.
- **Canvas Dark** (`{colors.canvas}` — #0a0a0a): The dominant near-black page floor.
- **Ink White** (`{colors.ink}` — #ffffff): White text for headlines.
- **Body Light** (`{colors.body}` — #dadbdf): Secondary body text.
- **Canvas Soft** (`{colors.canvas-parchment}` — #1a1c20): Slightly lighter dark fill for cards and alternating tiles.
- **Sunset/Dusk Accents** (Optional product illustrations/badges):
  - Sunset Orange (`#ff7a17`)
  - Dusk Purple (`#7c3aed`)

### Color Token Mapping
The following table shows how the abstract Apple design tokens map in each mode:

| Token | Hot Wallet Mode (Airbnb) | Cold & Unselected Mode (xAI) |
|---|---|---|
| `{colors.primary}` | `#ff385c` (Rausch Red) | `#ffffff` (White) |
| `{colors.primary-focus}` | `#e00b41` (Rausch Active) | `#fafaf7` (Ink Hover) |
| `{colors.primary-on-dark}` | `#ff385c` (Rausch Red) | `#ffffff` (White) |
| `{colors.ink}` | `#222222` (Ink Text) | `#ffffff` (Ink White) |
| `{colors.body}` | `#3f3f3f` (Body Text) | `#dadbdf` (Body Light) |
| `{colors.body-on-dark}` | `#ffffff` | `#ffffff` |
| `{colors.body-muted}` | `#6a6a6a` | `#7d8187` |
| `{colors.ink-muted-80}` | `#3f3f3f` | `#dadbdf` |
| `{colors.ink-muted-48}` | `#929292` | `#7d8187` |
| `{colors.divider-soft}` | `#ebebeb` | `#212327` |
| `{colors.hairline}` | `#dddddd` | `#212327` |
| `{colors.canvas}` | `#ffffff` | `#0a0a0a` |
| `{colors.canvas-parchment}` | `#f7f7f7` | `#1a1c20` |
| `{colors.surface-pearl}` | `#fafafc` | `#191919` |
| `{colors.surface-tile-1}` | `#f7f7f7` | `#191919` |
| `{colors.surface-tile-2}` | `#f2f2f2` | `#1a1c20` |
| `{colors.surface-tile-3}` | `#ebebeb` | `#0d1726` |
| `{colors.surface-black}` | `#222222` | `#0a0a0a` |
| `{colors.surface-chip-translucent}` | `#dddddd` | `#363a3f` |
| `{colors.on-primary}` | `#ffffff` | `#0a0a0a` |
| `{colors.on-dark}` | `#ffffff` | `#ffffff` |

No decorative gradients are used for layout elements. Atmospheric depth on graphics is inherent to the media assets, not CSS gradient overlays.

---

## Typography

### Font Family
- **Display**: `SF Pro Display, system-ui, -apple-system, sans-serif` — Apple's proprietary display face, optimized for sizes ≥ 19px. Defines the voice of every headline.
- **Body / UI**: `SF Pro Text, system-ui, -apple-system, sans-serif` — the text-optimized variant used for body copy, captions, buttons, and links below 20px.
- **OpenType features**: `font-variant-numeric: numerator` is enabled on numeric links (pricing tables, spec sheets). Display sizes rely on tight tracking rather than contextual ligatures.

### Hierarchy

| Token | Size | Weight | Line Height | Letter Spacing | Use |
|---|---|---|---|---|---|
| `{typography.hero-display}` | 56px | 600 | 1.07 | -0.28px | Hero headline; the signature "Apple tight" tracking |
| `{typography.display-lg}` | 40px | 600 | 1.10 | 0 | Tile headlines atop every wallet tile |
| `{typography.display-md}` | 34px | 600 | 1.47 | -0.374px | Section heads (SF Pro Text at display proportions) |
| `{typography.lead}` | 28px | 400 | 1.14 | 0.196px | Product tile subcopy |
| `{typography.lead-airy}` | 24px | 300 | 1.5 | 0 | Editorial lead paragraphs (the rare weight 300) |
| `{typography.tagline}` | 21px | 600 | 1.19 | 0.231px | Sub-tile tagline; sub-nav mode name |
| `{typography.body-strong}` | 17px | 600 | 1.24 | -0.374px | Inline strong emphasis |
| `{typography.body}` | 17px | 400 | 1.47 | -0.374px | Default paragraph |
| `{typography.dense-link}` | 17px | 400 | 2.41 | 0 | Footer / store utility link lists (relaxed leading) |
| `{typography.caption}` | 14px | 400 | 1.43 | -0.224px | Secondary captions, button text |
| `{typography.caption-strong}` | 14px | 600 | 1.29 | -0.224px | Emphasized captions |
| `{typography.button-large}` | 18px | 300 | 1.0 | 0 | Store hero CTAs (the rare weight 300) |
| `{typography.button-utility}` | 14px | 400 | 1.29 | -0.224px | Utility/nav button labels |
| `{typography.fine-print}` | 12px | 400 | 1.0 | -0.12px | Fine-print, footer body |
| `{typography.micro-legal}` | 10px | 400 | 1.3 | -0.08px | Micro legal disclaimers |
| `{typography.nav-link}` | 12px | 400 | 1.0 | -0.12px | Global nav menu items |

### Principles
- **Negative letter-spacing at display sizes.** Every headline at 17px and up carries a slight tracking tighten (`-0.12 → -0.374px`). This produces the iconic "Apple tight" headline cadence. Never used at 12px or below.
- **Body copy at 17px, not 16px.** Paragraph text is run at 17px. The extra pixel gives the page an unmistakable "reading, not scanning" pace.
- **Weight 300 is real and rare.** Used deliberately on a handful of large-size reads (`{typography.button-large}` at 18px/300 and `{typography.lead-airy}` at 24px/300).
- **Weight 600, not 700, for headlines.** Headlines sit at weight 600. Weight 700 is used sparingly for `{typography.tagline}` (21px) when a touch more assertion is needed.
- **Line-height is context-specific.** Display sizes use 1.07–1.19 (tight). Body uses 1.47. Utility link stacks in the footer/store use an unusually relaxed 2.41 (`{typography.dense-link}`).
- **Weight 500 is deliberately absent.** The ladder is 300 / 400 / 600 / 700. Mid-weight readings always use 600.

### Note on Font Substitutes
SF Pro is Apple's proprietary system font. When building off-system:
- Use `system-ui, -apple-system, BlinkMacSystemFont` as the first stack entry — on macOS/iOS/Safari this resolves to the real SF Pro.
- For non-Apple platforms, **Inter** (Google Fonts, variable) is the closest open-source equivalent. Inter at weight 600 with `font-feature-settings: "ss03"` approximates SF Pro's rounded "a" character.
- Nudge `letter-spacing` down by `-0.01em` on display sizes to re-create the Apple tight feel; Inter's default tracking runs slightly wider than SF Pro.
- For body text, tighten line-height by `0.03` (from 1.47 → 1.44) when substituting Inter — Inter's taller x-height needs less leading.

---

## Layout

### Spacing System
- **Base unit:** 8px. Sub-base values (2, 4, 5, 6, 7) are used for tight typographic adjustments; structural layout snaps to 8/12/16/20/24.
- **Tokens:** `{spacing.xxs}` 4px · `{spacing.xs}` 8px · `{spacing.sm}` 12px · `{spacing.md}` 17px · `{spacing.lg}` 24px · `{spacing.xl}` 32px · `{spacing.xxl}` 48px · `{spacing.section}` 80px.
- **Section vertical padding:** `{spacing.section}` (80px) inside a product/wallet tile; tiles stack edge-to-edge with 0 gap (the color change provides the break).
- **Card padding:** `{spacing.lg}` (24px) inside utility grid cards.
- **Button padding:** 8–11px vertical, 15–22px horizontal.
- **Universal rhythm constants:** the 17px body line-height multiplier (~25px line) and 21px tagline size show up on every page.

### Grid & Container
- **Max content width:** ~980px on text-heavy sections, ~1440px on product grids, full-bleed for product/mode tiles.
- **Column patterns:** 3 to 5 column utility card grid on store/accessories; 2-column side-by-side tiles; single-column centered stack on product tile heroes.
- **Gutters:** 20–24px between cards in a utility grid.

### Whitespace Philosophy
Whitespace is the pedestal. Every tile begins with at least 64px of air above its headline and 48–64px below. Wallet renders are never crowded; the nearest content to an asset image is at least 40px away. The footer is the only area that breaks this — there, the system goes deliberately dense to make the full information architecture visible at a glance.

---

## Elevation & Depth

| Level | Treatment | Use |
|---|---|---|
| Flat | No shadow, no border | Full-bleed tiles, global nav, footer, body sections |
| Soft hairline | 1px `{colors.hairline}` border | Utility cards, sub-nav frosted-glass separator |
| Backdrop blur | `backdrop-filter: blur(20px)` on Parchment 80% | Sub-nav and the wallet floating sticky bar |
| Product shadow | `rgba(0, 0, 0, 0.22) 3px 5px 30px 0` | Wallet/hardware renders resting on a surface (the only true "shadow" in the system) |

**Shadow philosophy.** The system uses **exactly one** drop-shadow, and it is applied to photographic asset/wallet imagery — never to cards, never to buttons, never to text. Elevation in the UI comes from (a) surface-color change (canvas ↔ contrast tile) and (b) backdrop-blur on sticky bars. The single shadow is about giving the asset weight, not about UI hierarchy.

---

## Shapes

### Border Radius Scale

| Token | Value | Use |
|---|---|---|
| `{rounded.none}` | 0px | Full-bleed product/mode tiles (no corner rounding) |
| `{rounded.xs}` | 5px | Inline links when styled as subtle chips (rare) |
| `{rounded.sm}` | 8px | Dark utility buttons, inline card imagery |
| `{rounded.md}` | 11px | White Pearl Button capsules |
| `{rounded.lg}` | 18px | Store/wallet utility cards, grid cards |
| `{rounded.pill}` | 9999px | Primary mode CTAs, sub-nav buy button, configurator option chips, search input — the signature pill |
| `{rounded.full}` | 9999px / 50% | Circular control chips floating over photography |

### Photography Geometry
- **Hero imagery**: full-bleed, 21:9 or taller; 16:9 on interior pages. Wallet renders are photographic-realistic, often resting on a tinted surface that matches the tile background.
- **Wallet renders**: PNG/WebP with transparency; rest on a surface tile and pick up the system shadow.
- **Utility grid**: square 1:1 crops at `{rounded.lg}` (18px) radius, neutral backgrounds, item centered with 20–40px internal padding.
- **No rounded imagery in hero tiles** — images are full-bleed rectangular. Rounding (`{rounded.sm}`, `{rounded.lg}`) appears only on inline card imagery.

---

## Components

### Top Navigation

**`global-nav`** — Persistent, ultra-thin nav bar pinned to the top of every page. Background `{colors.surface-black}`, height 44px, text `{colors.on-dark}` in `{typography.nav-link}` (12px / 400 / -0.12px tracking). Links are quiet, spaced ~20px apart, running edge-to-edge across the top. Right-aligned cluster: Search, Bag/Wallet icons — always visible.

**`sub-nav-frosted`** — Mode-specific nav that sticks below the global nav. Background `{colors.canvas-parchment}` at 80% opacity with backdrop-filter blur, creating a frosted-glass effect. Height 52px. Content on left: product category name ("Hot Wallet", "Cold Wallet") in `{typography.tagline}` (21px / 600). Content right: inline nav links in `{typography.button-utility}` (14px), ending in a persistent `{component.button-primary}` or a utility link.

### Buttons

**`button-primary`** — The signature action button. Background `{colors.primary}` (Rausch Red in Hot Mode, White in Cold Mode), text `{colors.on-primary}` (White in Hot Mode, Near-Black in Cold Mode) in `{typography.body}` (SF Pro Text 17px / 400), rounded `{rounded.pill}` (capsule-shaped), padding 11px × 22px.
- Active state: `{component.button-primary-active}` — `transform: scale(0.95)` (the system-wide micro-interaction).
- Focus state: `{component.button-primary-focus}` — 2px solid `{colors.primary-focus}` outline.

**`button-secondary-pill`** — Used as the second CTA when two pills appear together ("Learn more" / "Setup"). Background transparent, text `{colors.primary}`, 1px solid `{colors.primary}` border, rounded `{rounded.pill}`, padding 11px × 22px. Reads as a "ghost pill."

**`button-dark-utility`** — Global nav actions. Background `{colors.ink}`, text `{colors.on-dark}` in `{typography.button-utility}` (14px / 400 / -0.224px tracking), rounded `{rounded.sm}` (8px), padding 8px × 15px. Active state shrinks via `transform: scale(0.95)`.

**`button-pearl-capsule`** — Card secondary button. Background `{colors.surface-pearl}`, text `{colors.ink-muted-80}` in `{typography.caption}` (14px), 3px solid `{colors.divider-soft}` border (functions as a soft ring rather than a visible line), rounded `{rounded.md}` (11px), padding 8px × 14px.

**`button-store-hero`** — A larger primary CTA. Same brand primary + paper white/dark as `{component.button-primary}`, but with `{typography.button-large}` (18px / 300) and slightly more padding (14px × 28px).

**`button-icon-circular`** — Floats over graphics. 44 × 44px, background `{colors.surface-chip-translucent}` at ~64% alpha, icon in `{colors.ink}`, rounded `{rounded.full}`.

**`text-link`** — Inline body links in `{colors.primary}`.

**`text-link-on-dark`** — Inline body links on dark tiles in `{colors.primary-on-dark}`.

### Cards & Containers

**`product-tile-light`** — Full-bleed light tile. Background `{colors.canvas}`, text `{colors.ink}`, rounded `{rounded.none}`, vertical padding `{spacing.section}` (80px). Centered stack: name in `{typography.display-lg}` (40px / 600) → tagline in `{typography.lead}` (28px / 400) → two `{component.button-primary}` CTAs → render resting on the surface with the system shadow.

**`product-tile-parchment`** — Same as `{component.product-tile-light}` but on `{colors.canvas-parchment}`. Used to break two consecutive base-canvas tiles.

**`product-tile-dark`** — Full-bleed dark tile. Background `{colors.surface-tile-1}`, text `{colors.on-dark}`, rounded `{rounded.none}`, vertical padding `{spacing.section}` (80px). Same content stack as the light tile but with `{component.text-link-on-dark}` for inline copy and `{component.button-primary}`.

**`product-tile-dark-2`** — Variant on `{colors.surface-tile-2}`. Used where a dark tile sits directly adjacent to `{component.product-tile-dark}` to create separation through micro-step lightness change.

**`product-tile-dark-3`** — Variant on `{colors.surface-tile-3}`. Used at the bottom of the stack and in embedded video/player frames.

**`store-utility-card`** — Used in grid lists. Background `{colors.canvas}`, 1px solid `{colors.hairline}` border, rounded `{rounded.lg}` (18px), padding `{spacing.lg}` (24px). Top: product image (1:1 crop with `{rounded.sm}` (8px) inner image radius). Below: name in `{typography.body-strong}` (17px / 600), info in `{typography.body}` (17px / 400), and a `{component.text-link}`. No shadow by default; asset render itself carries the system product-shadow.

**`configurator-option-chip`** — Pill-shaped tappable cell. Background `{colors.canvas}`, text `{colors.ink}` in `{typography.caption}`, rounded `{rounded.pill}`, padding 12px × 16px. Contains a small thumbnail + label. Arranged in a grid of options.

**`configurator-option-chip-selected`** — Selected state. Border upgrades to 2px solid `{colors.primary-focus}`. Same shape, same content.

### Inputs & Forms

**`search-input`** — The wallet search input. Background `{colors.canvas}`, text `{colors.ink}` in `{typography.body}` (17px), 1px solid `{colors.divider-soft}` border, rounded `{rounded.pill}` (full pill — search is also pill-shaped, matching the CTA grammar), padding 12px × 20px, height 44px.

**`floating-sticky-bar`** — Floats at the bottom of the viewport on setup pages during scroll. Background `{colors.canvas-parchment}` at 80% opacity with `backdrop-filter: blur(20px)`, height 64px, padding 12px × 32px. Left: running stats in `{typography.body}`. Right: `{component.button-primary}`.

**`environment-quote-card`** — A photographic-canvas hero. Dark photographic backdrop with `{colors.surface-tile-1}` as the fallback color, centered white-text headline in `{typography.display-lg}` (40px), single `{component.button-primary}` below. Padding `{spacing.section}` (80px).

### Footer

**`footer`** — Background `{colors.canvas-parchment}`, text `{colors.ink-muted-80}`. Link columns in `{typography.dense-link}` (17px / 400 / 2.41 line-height). Column headings in `{typography.caption-strong}` (14px / 600). Legal row at the very bottom in `{typography.fine-print}` (12px / 400) with `{colors.ink-muted-48}` text. Vertical padding 64px.

---

## Do's and Don'ts

### Do
- Use `{colors.primary}` (Rausch Red in Hot mode, White in Cold/Unselected mode) for interactive elements — links, pill CTAs, focus signals — and nothing else.
- Set headlines in `{typography.hero-display}` or `{typography.display-lg}` with negative letter-spacing (`-0.28 → -0.374px`) to get the signature "Apple tight" cadence.
- Run body copy at `{typography.body}` (17px / 400 / 1.47 / -0.374px) — not 16px. The extra pixel defines the reading pace.
- Alternate `{component.product-tile-light}` (or parchment) and `{component.product-tile-dark}` for full-bleed section rhythm. The color change IS the divider.
- Reserve `{rounded.pill}` for the primary CTA and any other element that should read as an "action" (configurator chips, search input, sticky bar CTA).
- Apply the single product-shadow (`rgba(0, 0, 0, 0.22) 3px 5px 30px`) only to hardware/wallet renders resting on a surface — never on cards, buttons, or text.
- Use `transform: scale(0.95)` as the active/press state on every button — it's the system-wide micro-interaction.
- Keep the global nav `{colors.surface-black}` — it's the anchor of the screen.

### Don't
- Don't introduce a second accent color; every "click me" signal is `{colors.primary}`.
- Don't add shadows to cards, buttons, or text — shadow is reserved for photographic assets.
- Don't use gradients as decorative backgrounds; depth comes from photographic atmosphere.
- Don't set body copy at weight 500 — the ladder is 300 / 400 / 600 / 700, with 500 deliberately absent. Body is always 400; strong inline is 600; display is 600.
- Don't round full-bleed tiles — tiles are rectangular and edge-to-edge; the color change is the divider.
- Don't tighten line-height below 1.47 for body copy — the editorial leading is part of the brand.
- Don't mix radii grammars — use `{rounded.sm}` for compact utility, `{rounded.lg}` for utility cards, `{rounded.pill}` for pills, and nothing in between (except the rare `{rounded.md}` Pearl Button).

---

## Responsive Behavior

### Breakpoints

| Name | Width | Key Changes |
|---|---|---|
| Small phone | ≤ 419px | Single-column tiles; sub-nav collapses to category name + primary CTA only; hero typography drops to 28px |
| Phone | 420–640px | Single-column stack; renders scale to 80% of tile width; hero h1 drops to 34px |
| Large phone | 641–735px | Tiles transition to tighter padding (48px vertical vs 80px); fine-print wraps |
| Tablet portrait | 736–833px | Global nav collapses to hamburger; sub-nav hides category chips, keeps primary CTA |
| Tablet landscape | 834–1023px | Global nav returns fully expanded; 3-column utility grids become 2-column |
| Small desktop | 1024–1068px | Product tiles use 2/3 width with margin gutters; hero h1 stays at 40px |
| Desktop | 1069–1440px | Full layout; 4–5 column grids; 1440px content max |
| Wide desktop | ≥ 1441px | Content locks at 1440px, margins absorb extra width |

The structural breakpoints that matter for layout: 1440px (content lock), 1068px (small-desktop), 833px (tablet landscape switch), 734px (tablet portrait), 640px (phone), 480px (small phone).

### Touch Targets
- Minimum 44 × 44px. `{component.button-primary}` lands at ~44 × 100px (with the full-pill radius making the visible hit area more generous than the label suggests).
- `{component.button-icon-circular}` is exactly 44 × 44px.
- Global nav utility links are smaller (~32 × 80px) — they deliberately sit at a tighter target because they're precision desktop actions, and the mobile hamburger replaces them at ≤ 833px.

### Collapsing Strategy
- **Global nav**: full horizontal link row on desktop → collapses to logo + hamburger + wallet icon at 834px and below.
- **Sub-nav**: category name + inline links + primary CTA → category name + primary CTA only at mobile; inline links move into a hamburger tray.
- **Product/Mode tiles**: stack from 2-column to 1-column at 834px; vertical padding tightens from 80px → 48px at small-phone.
- **Utility grids**: 5-col → 4-col (1440px) → 3-col (1068px) → 2-col (834px) → 1-col (640px).
- **Hero typography**: `{typography.hero-display}` (56px) → `{typography.display-lg}` (40px) at 1068px → 34px at 640px → 28px at 419px.

### Image Behavior
- All graphics use responsive media sizes matching breakpoints.
- Hero imagery may switch art direction at mobile to a taller aspect ratio, framing subjects/wallets differently.
- Renders maintain aspect ratios; only scale changes.

---

## Iteration Guide

1. Focus on ONE component at a time. Reference its YAML key directly (`{component.product-tile-dark}`, `{component.search-input}`).
2. Variants of an existing component (`-active`, `-focus`, `-2`, `-3`) live as separate entries in `components:`.
3. Use `{token.refs}` everywhere — never inline hex.
4. Never document hover. Default and Active/Pressed states only.
5. Display headlines stay SF Pro Display 600 with negative letter-spacing. Body stays SF Pro Text 400 at 17px. The boundary is unbreakable.
6. The single drop-shadow (`rgba(0, 0, 0, 0.22) 3px 5px 30px`) is reserved for photography/renders only.
7. When in doubt about emphasis: alternate surface (canvas ↔ contrast tile) before adding chrome.

---

## Known Gaps

- Form validation and error states are not detailed here; only the neutral text/search input is documented.
- Dark-mode counterparts for store and accessories utility cards are not mapped separately; the dual mode automatically skins them via the `hot` vs `cold` token sets.
- The exact backdrop-filter blur radius on frosted components is platform-dependent; production CSS/Flutter uses typical baselines but the value isn't formalized as a token.

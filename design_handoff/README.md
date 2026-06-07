# Handoff: Tadpole Talk — Visual Theme & App Icon

## Overview
This bundle delivers the **visual theme** and **app-icon assets** for **Tadpole Talk**, the
parent-led home-practice companion for families of children with Childhood Apraxia of Speech.
It contains:

1. **Drop-in app-icon assets** — a friendly tadpole mascot on a soft pond gradient, exported
   as production `AppIcon.appiconset` PNGs (light / dark / tinted) plus vector masters.
2. **The full visual theme** — colour, type, spacing, shape and elevation tokens, documented
   and cross-checked against the values already in the app's `Theme.swift`.
3. **An interactive HTML spec** (`reference/Tadpole Talk Theme.html`) showing the theme applied
   to the practice card, progress view and reward screen.

> **Target codebase:** the existing `TadpoleTalk` repo — **iOS / iPadOS 17+, SwiftUI, MVVM,
> SwiftData**. The app already centralises styling in `TadpoleTalk/Shared/Theme.swift`, and the
> tokens below **match that file** — so the bulk of "implement the theme" is *already done*.
> The genuinely new work is **shipping the app icon** and, optionally, **using the mascot
> in-app**. Everything else is a verification/polish pass.

## About the design files
The files in `reference/` are **design references authored in HTML/SVG** — they show the
intended look and behaviour, not production code to paste in. Recreate any UI deltas in
SwiftUI using the app's established patterns (`Theme` tokens, SF Symbols, Dynamic Type). The
files in `assets/` **are** production-ready and meant to be used directly.

## Fidelity
**High-fidelity.** Final colours, type, spacing and the icon artwork are all production values.
Match them exactly. The icon PNGs are final, 1024×1024, full-bleed.

---

# Part A — App Icon (new work)

## What's included (`assets/`)
| File | Use |
|---|---|
| `AppIcon.appiconset/` | **Drop-in** asset catalog entry: `Contents.json` + 3 PNGs |
| `AppIcon.appiconset/icon-light-1024.png` | Default (any-appearance) icon, full-bleed 1024² |
| `AppIcon.appiconset/icon-dark-1024.png` | Dark-appearance variant |
| `AppIcon.appiconset/icon-tinted-1024.png` | Tinted variant — **grayscale on dark** (OS paints the user's tint) |
| `icon-{light,dark,tinted}.svg` | Vector masters **with** the rounded preview mask (docs / App Store mockups) |
| `icon-{light,dark,tinted}-square.svg` | Vector masters **full-bleed square** — re-rasterise from these if you need to tweak |
| `mascot.svg` / `mascot-dark.svg` | The tadpole **alone**, no background, for in-app use |

## Install (Xcode)
1. In the repo, the icon set lives at
   `TadpoleTalk/Resources/Assets.xcassets/AppIcon.appiconset/`.
2. Replace that folder's contents with the three PNGs and `Contents.json` from
   `assets/AppIcon.appiconset/`. (Or, in Xcode, select the AppIcon asset → set **Appearances:
   Any, Dark, Tinted** and **Single Size**, then drag each PNG into its well.)
3. Confirm the target's **App Icon source** build setting is `AppIcon` (it already is in
   `project.yml`). Clean build folder, run.

## Important icon rules (already honoured by these files — keep them if you regenerate)
- **Full-bleed square, no transparency** for the light & dark PNGs. iOS applies the
  rounded-rectangle (continuous-corner squircle) mask itself — **never** bake corner rounding
  or a drop shadow into the asset.
- **Tinted = grayscale on a dark background.** Do not add colour; the system derives the tint
  from luminance. Keep strong light/dark contrast so the tinted result stays legible.
- **No fine detail.** The design is deliberately a few bold shapes + one high-contrast eye so
  it survives down to 29 px (Settings/Spotlight). Verified 1024 → 29 px in the HTML spec.

## Using the mascot in-app (optional, nice-to-have)
`mascot.svg` is the tadpole with no background — good for empty states, the onboarding header,
or as a friendlier companion on the reward screen. Two ways to bring SVG into SwiftUI:
- **Simplest:** open the SVG in any editor, **export to PDF**, add the PDF to
  `Assets.xcassets` with *Preserve Vector Data* ✓ and *Render As: Original*, then
  `Image("tadpoleMascot")`. Scales crisply.
- **Tokenised (recommended for theme-following tint):** port the paths into a SwiftUI `Canvas`
  / `Shape` exactly like the existing `MouthDiagram.swift` does, reading `Theme.brand`,
  `Theme.label`, etc. so it adapts to light/dark for free. The geometry (0–100 space) is in
  `icon-light-square.svg`.
- The reward burst in `RewardView.swift` already uses SF Symbols (never emoji) — that pattern
  is correct; the mascot is complementary, not a replacement.

---

# Part B — Visual Theme (verify against `Theme.swift`)

The app already defines every token below in `TadpoleTalk/Shared/Theme.swift` ("Bright Sky" /
"Deep Sky"). Use this as a **specification + verification checklist**. Values are stated as the
hex literals that file resolves to. If any drift, `Theme.swift` is the single source of truth —
update it, never hard-code a hex in a View.

## Colour tokens
All pairs below were contrast-checked (WCAG 2.1). "AA" = ≥4.5:1 normal text, "AA Large" =
≥3:1 (≥19px bold / large UI), "UI" = ≥3:1 graphics/components.

### Light — "Bright Sky"
| Token | Hex | Role | Contrast |
|---|---|---|---|
| `Theme.brand` | `#3B82C4` | tint / large text / UI | 4.06:1 on white — **UI/large only** |
| `Theme.brandInk` | `#2C649A` | body text on light | 6.18:1 — **AA** |
| `Theme.accent` | `#F2A03D` | fill / celebration | 2.13:1 — **fill only, never small text** |
| `Theme.accentInk` | `#D27F1E` | accent text on light | 3.09:1 — **AA Large** |
| `Theme.bg` | `#F7FBFF` | app background | surface |
| `Theme.bgGrouped` | `#EDF4FB` | grouped background | surface |
| `Theme.card` | `#FFFFFF` | card surface | surface |
| `Theme.fillQuat` | `rgba(27,58,90,0.08)` | quaternary fill / track | surface |
| `Theme.hairline` | `rgba(27,58,90,0.14)` | hairline / border | surface |
| `Theme.label` | `#1E2A36` | primary text | 14.03:1 — **AAA** |
| `Theme.label2` | `#5A6B7B` | secondary text | 5.49:1 — **AA** |
| `Theme.label3` | `#92A2B2` | tertiary / hints | 2.61:1 — **decorative / large only** |
| `Theme.correct` | `#3FA66A` | success / "Got it!" | 3.06:1 — **UI** |
| `Theme.approx` | `#E9A23B` | warning / "Close" | fill — pair with darker ink for text |
| `Theme.tryAgain` | `#6C8094` | neutral / "Try again" | UI |
| `Theme.teal` | `#3BA8A0` | accent gfx | UI |
| `Theme.pink` | `#D98BA0` | reward confetti | decorative |
| `Theme.purple` | `#8B7FD0` | reward confetti | decorative |
| `Theme.red` | `#D5694E` | error / destructive | UI |

### Dark — "Deep Sky"
| Token | Hex | Role |
|---|---|---|
| `Theme.brand` | `#6FB0E8` | tint / UI |
| `Theme.brandInk` | `#9CCBF2` | body text on dark |
| `Theme.accent` | `#F6B968` | fill / celebration |
| `Theme.accentInk` | `#F9CB8E` | accent text on dark |
| `Theme.bg` | `#10171F` | app background |
| `Theme.bgGrouped` | `#141C26` | grouped background |
| `Theme.card` | `#1B2530` | card surface |
| `Theme.fillQuat` | `rgba(255,255,255,0.08)` | quaternary fill |
| `Theme.hairline` | `rgba(255,255,255,0.12)` | hairline |
| `Theme.label` | `#E8EEF4` | primary text |
| `Theme.label2` | `#9DAFBF` | secondary text |
| `Theme.label3` | `#62748A` | tertiary |
| `Theme.correct` | `#5FC489` | success |
| `Theme.approx` | `#F0BA62` | warning |
| `Theme.tryAgain` | `#8AA0B4` | neutral |
| `Theme.teal` | `#5FC6BE` · `Theme.pink` | `#E6A3B5` · `Theme.purple` `#A99EE6` · `Theme.red` `#E2856A` | accents |

> **Note on the icon vs. `AccentColor`:** `Assets.xcassets/AccentColor.colorset` currently
> resolves to ~`#3B82C4` (matches `Theme.brand`) — leave it. The icon's deep-blue tadpole
> (`#235C90`) and aqua→blue gradient are derived from this same family, so the icon and app
> read as one product.

## Spacing — 4-pt scale
`sp1 4` · `sp2 8` · `sp3 12` · `sp4 16` · `sp5 20` · `sp6 24` (pt). Default screen padding is
`sp4`; card internal padding `sp4`–`sp5`; content max width 640 (`Theme.contentMaxWidth`).

## Shape / radius
`Theme.corner 24` (cards) · `Theme.cornerSm 16` (controls) · `Theme.cornerXs 12` (chips).

## Elevation
Two soft, **blue-tinted** shadows — never harsh black on light:
- resting: `0 4px 14px rgba(27,58,90,0.08)`
- raised card: `0 10px 30px rgba(27,58,90,0.10), 0 2px 6px rgba(27,58,90,0.06)`
- dark mode: swap to `rgba(0,0,0,0.35–0.5)`.

## Tap targets
`Theme.tapMin 44` (floor) · `Theme.btnHeight 52` (standard buttons) · `Theme.tapBig 64` ·
`Theme.bigButton 120` (the chunky kid-facing rating buttons). Honour these for shared
parent/child use.

## Typography
Native: **SF Pro Rounded** (`.system(..., design: .rounded)`) — already used for the practice
word and big numbers. Keep it; it's the system equivalent of the web fonts in the spec.
- The HTML reference maps it to **Baloo 2** (display/headings/numbers) + **Nunito** (body/UI)
  *for web preview only* — you do **not** need to bundle fonts; ship with SF Pro Rounded.
- Type scale used in the spec (point sizes / weights): Display 52/800 (the word), Large Title
  34/800, Title 24/700, Headline 18/700, Body 17/400, Subhead 15/600, Caption 13/700.
- Support **Dynamic Type** and large sizes (the app already declares this) — never cap text.

---

## Screens reference (already built — match the theme to these)
These exist in the repo; the HTML spec is the visual target to match pixel-for-feel.
| Screen | File | Key theme usage |
|---|---|---|
| Practice / exercise card | `Features/Practice/PracticeSessionView.swift` | Word in SF Rounded 56; shape capsule = `brand`@14% + `brandInk`; three `bigButton` (120pt) ratings tinted at 14% behind their semantic colour (`correct`/`approx`/`tryAgain`) |
| Cue ladder | `Features/Practice/CueLadderView.swift` | `brand`@10% card, `cornerSm`, `brandInk` text |
| Progress | `Features/Progress/ProgressDashboardView.swift` | Stat tiles on `card`; chart bars `correct` + `brand`@35%; per-word `ProgressView` tinted `correct`/`brand` |
| Reward / summary | `Features/Practice/RewardView.swift` | `accent` star, multicolour SF-Symbol burst (`accent`,`correct`,`pink`,`brand`,`purple`), `correct`/`brand` tallies |

## Accessibility checklist
- Body text uses `label` / `label2` / `brandInk` / `accentInk` (all ≥4.5:1). `label3`, raw
  `brand`, raw `accent` are for large text / fills / graphics only — don't set small body
  copy in them.
- Semantic colours appear as 14% tints **behind their own ink**, not as text on white.
- Maintain 44pt minimum hit targets; ratings at 120pt.
- VoiceOver labels and stable a11y IDs already exist (`Shared/AccessibilityIDs.swift`).

## Files in this bundle
```
design_handoff_tadpole_theme/
├── README.md                      ← this file
├── assets/
│   ├── AppIcon.appiconset/        ← drop-in: Contents.json + 3× 1024² PNG
│   ├── icon-{light,dark,tinted}.svg         (rounded preview masters)
│   ├── icon-{light,dark,tinted}-square.svg  (full-bleed masters)
│   └── mascot.svg, mascot-dark.svg          (background-free tadpole)
└── reference/
    ├── Tadpole Talk Theme.html    ← interactive spec (open in a browser)
    ├── icons.js                   ← SVG icon/mascot generator (source of the artwork)
    └── palette.js                 ← palette + live WCAG contrast logic
```

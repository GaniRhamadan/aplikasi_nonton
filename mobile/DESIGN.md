# AniMobile — Design Specification (Clean Minimalist)

## 1. Identity & Mood
- **Character**: Clean Minimalist, modern official media platform aesthetic.
- **Mood**: Refined, lightweight, high readability, distraction-free anime streaming companion for ani-cli.
- **Dials**:
  - ENERGY: 2 (Subtle, focused, clean)
  - RHYTHM: 2 (Intentional structure with varying card layouts)
  - MOTION: 1 (Standard micro-transitions, no looping animations)

## 2. Color Palette & Hierarchy
- **Canvas / Background**: `#F8FAFC` (Slate 50)
- **Surface / Cards**: `#FFFFFF` (Pure White) with 1px border `#E2E8F0`
- **Text Primary**: `#0F172A` (Slate 900) — High contrast ratio > 11:1
- **Text Secondary**: `#475569` (Slate 600) — Contrast ratio > 5:1
- **Text Muted**: `#94A3B8` (Slate 400)
- **Deliberate Accent**: `#E11D48` (Japanese Crimson / Rose 600) — Used exclusively for:
  - Primary Play / Streaming Action
  - Active Tab indicator
  - Currently playing episode indicator
- **Accent Muted Surface**: `#FFF1F2` (Rose 50) — For active badge background

## 3. Typography
- Hierarchy:
  - Headline Large: 24sp, SemiBold (w700), `#0F172A`
  - Title Medium: 18sp, SemiBold (w600), `#0F172A`
  - Body Medium: 14sp, Regular (w400), `#475569`
  - Label / Badge: 12sp, Medium (w500)
- No decorative emojis in headings or buttons.

## 4. Mobile Ergonomics (Layoutmobile & Accessibility)
- **Thumb Zone**:
  - Bottom Navigation Bar (Height: 68px, Tap targets: 52px height)
  - Floating / bottom-anchored "Lanjutkan Tonton" (Continue Watching) quick resume banner
- **Tap Targets**:
  - Episode pills: min 48px height, 12px padding
  - Action buttons: min 48px height
  - Search input: 50px height with clear button
- **Spacing Scale**:
  - Screen Padding: 16px horizontal
  - Section Spacing: 20px - 24px vertical
  - Item Gaps: 12px
- **Contrast & States**:
  - Active, pressed, disabled states clearly differentiated with opacity and borders
  - Meaningful empty states ("Belum ada riwayat tontonan") with single clear CTA

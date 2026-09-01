# SunSafe Check-In — Design System

> Figma equivalent: `SunSafe — Design System` file.

## Color tokens

| Token | Senior (cream) | Senior (high contrast) | Caregiver |
|-------|----------------|------------------------|-----------|
| background | `#FFF8E7` | `#0D1117` | `#F5F7FA` |
| surface | `#FFFFFF` | `#1A2332` | `#FFFFFF` |
| primary | `#FFC947` | `#FFD54F` | `#1565C0` |
| onPrimary | `#1A1200` | `#1A1200` | `#FFFFFF` |
| success | `#2E7D32` | `#4CAF50` | `#2E7D32` |
| warning | `#F57C00` | `#FFB74D` | `#F57C00` |
| error | `#C62828` | `#FF5252` | `#C62828` |
| textPrimary | `#1A1A2E` | `#FFFFFF` | `#1A1A2E` |
| textSecondary | `#546E7A` | `#B0BEC5` | `#546E7A` |

## Spacing scale

`4 / 8 / 16 / 24 / 32 / 48 / 72` — see `lib/core/theme/app_spacing.dart`.

## Typography

| Role | Display | Headline | Body | Label |
|------|---------|----------|------|-------|
| Senior | 40pt w900 | 28pt w800 | 22pt w600 | 22pt w700 |
| Caregiver | 32pt w800 | 22pt w700 | 16pt | 14pt w600 |

## Core components (Flutter: `lib/core/widgets/`)

| Component | Purpose |
|-----------|---------|
| `StatusPill` | Green / yellow / red check-in status |
| `PrimaryCta` | Senior 120px+ or caregiver 48px button |
| `GreetingCard` | Family message with photo/voice actions |
| `QuickActionTile` | 2×2 caregiver dashboard grid cell |
| `VoiceNoteRow` | List row with free play + premium analyze |
| `WizardStepHeader` | "Step 2 of 4" + title |
| `OfflineBanner` | Persistent offline queue strip |
| `RoleSelectionCard` | Dual-role entry cards |

## Screen frame size

Mobile: 390 × 844 (iPhone 14 reference). Implemented directly in Flutter widgets.

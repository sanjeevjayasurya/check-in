# SunSafe Check-In — Design Review Checklist

## Pre-implementation gate (completed)

- [x] Senior home has ≤6 visible actions on one screen
- [x] Caregiver dashboard answers "Is parent okay?" in <3 seconds (hero status pill)
- [x] All flows have empty, loading, success, error, offline states (documented + implemented)
- [x] Onboarding uses wizard pattern (≤1 primary action per step)
- [x] Voice note playback is free; AI analysis is premium
- [x] Copy is respectful (not patronizing)
- [x] Both role themes visually distinct; `RolePageRoute` wraps pushed routes
- [x] Accessibility: 4.5:1 contrast on cream/dark senior + caregiver palettes

## Resolved decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Senior background | Warm cream default | AgeCare warmth; less clinical than dark-only |
| High contrast | Toggle in senior settings | WCAG option without forcing dark on all seniors |
| Need help | Call primary emergency contact | v1 scope; Novaq SOS deferred |
| Senior logout | Hidden in settings | Device handoff without cluttering home |

## Figma note

Figma MCP was unavailable in the cloud agent environment. Equivalent deliverables:

- [01-research-synthesis.md](./01-research-synthesis.md)
- [02-user-flows.md](./02-user-flows.md)
- [03-design-system.md](./03-design-system.md)
- Flutter implementation in `lib/core/widgets/` and feature screens

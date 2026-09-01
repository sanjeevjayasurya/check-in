# SunSafe Check-In — Research Synthesis

Design north star: **Collaboration, not surveillance.**

## Competitive patterns mapped to SunSafe

| Source | Key insight | SunSafe decision |
|--------|-------------|------------------|
| [AgeCare](https://agecare.app/) | Senior Mode: one column, ≤6 choices, live clock, plain words, no charts | Senior home shows clock + name + one primary CTA; max 6 actions |
| [AgeCare](https://agecare.app/) | Caregiver dashboard answers "Is she okay?" | Hero status pill (green/yellow/red) above the fold |
| [Caring Village](https://caringvillage.com/) | Role-based privacy, warm collaborative tone | Trust copy on role selection; "shared journey" language |
| [Novaq](https://novq.app/) | One-tap help, unified family dashboard | "Need help?" calls primary emergency contact (v1) |
| [MyWisdom UX audit](https://allsimiles.com/the-senior-ux-crisis-7-design-problems-we-diagnosed-and-solved-at-mywisdom/) | Progressive disclosure wizard onboarding | 3-step senior + 4-step caregiver onboarding wizards |
| [MyWisdom UX audit](https://allsimiles.com/the-senior-ux-crisis-7-design-problems-we-diagnosed-and-solved-at-mywisdom/) | Practice mode builds confidence | Practice check-in step before real home |
| Academic / gov guidelines | 18–22pt body, 48–72dp targets, 4.5:1 contrast | Tokens in `app_theme.dart`; cream senior theme default |
| Academic / gov guidelines | Wizard pattern reduces cognitive load | Greeting send = 3 steps; onboarding = 1 action per step |

## Resolved design decisions

1. **Senior background:** Warm cream `#FFF8E7` (default). High-contrast dark mode toggle in senior settings.
2. **Need help scope:** One-tap call to first emergency contact from alert settings.
3. **Premium gating:** Voice playback free; AI sentiment + digest premium.
4. **Typography:** System rounded feel via Material 3 with enlarged scale for senior role.

## FigJam sticky equivalents

These map to the research stickies that would appear in `SunSafe — User Flows` FigJam:

- **Sticky: AgeCare** — "Separate interfaces. Senior never sees charts."
- **Sticky: Caring Village** — "Privacy + warmth. Not monitoring."
- **Sticky: Novaq** — "One tap for urgent help. Offline queue."
- **Sticky: MyWisdom** — "Wizard onboarding. Practice scary features."
- **Sticky: Accessibility** — "72dp senior / 48dp caregiver. Text labels always."

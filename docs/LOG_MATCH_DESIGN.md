# PadelArena Log Match Flow - UI/UX Design

## Design Overview
A streamlined 4-screen flow that makes match logging effortless and rewarding, following PadelArena's design system.

## Brand Guidelines Applied
- **Primary Colors**: #1D556D (Dark Blue), #2A809E (Light Blue), #D3FF21 (Lime Green)
- **Typography**: Poppins Bold for headings, Inter Regular for body
- **Layout**: Card-based, minimal typing, large tappable zones
- **Motion**: 250-300ms transitions, expansion/pulse effects

---

## WIREFRAME FLOW

### Screen 1: Entry Point - "Log a Match"
```
┌─────────────────────────────────┐
│ ← Log Match          [Profile]  │
├─────────────────────────────────┤
│                                 │
│     🎾 Ready to Log Your       │
│        Latest Victory?          │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ [🗓] Today, Nov 4           │ │
│ │ [📍] Select Club ▼          │ │
│ │ [👥] 2v2 Match Type         │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │     Continue to Score       │ │ ← Big lime green button
│ └─────────────────────────────┘ │
│                                 │
│     Quick Actions:              │
│ [📷 Scan QR] [🕐 Recent]       │
└─────────────────────────────────┘
```

### Screen 2: Score Entry
```
┌─────────────────────────────────┐
│ ← Score Entry         [2/4]     │
├─────────────────────────────────┤
│              SET 1              │
│                                 │
│  Your Team    VS    Opponents   │
│     [6]              [4]        │
│                                 │
│  ┌─┐ ┌─┐ ┌─┐     ┌─┐ ┌─┐ ┌─┐  │
│  │7│ │8│ │9│     │7│ │8│ │9│   │
│  └─┘ └─┘ └─┘     └─┘ └─┘ └─┘   │
│  ┌─┐ ┌─┐ ┌─┐     ┌─┐ ┌─┐ ┌─┐  │
│  │4│ │5│ │6│     │4│ │5│ │6│   │
│  └─┘ └─┘ └─┘     └─┘ └─┘ └─┘   │
│  ┌─┐ ┌─┐ ┌─┐     ┌─┐ ┌─┐ ┌─┐  │
│  │1│ │2│ │3│     │1│ │2│ │3│   │
│  └─┘ └─┘ └─┘     └─┘ └─┘ └─┘   │
│      ┌─┐             ┌─┐        │
│      │0│             │0│        │
│      └─┘             └─┘        │
│                                 │
│ Set 2 Played? [Yes] [No]        │
│                                 │
│ ┌─────────────────────────────┐ │
│ │      ✓ Confirm Set 1        │ │ ← Green confirm
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

### Screen 3: Players Selection
```
┌─────────────────────────────────┐
│ ← Players                [3/4]  │
├─────────────────────────────────┤
│         Who Played?             │
│                                 │
│ Your Partner:                   │
│ ┌─────────────────────────────┐ │
│ │ [👤] Search or Recent ▼     │ │
│ └─────────────────────────────┘ │
│                                 │
│ Opponents:                      │
│ ┌─────────────────────────────┐ │
│ │ [👤] Player 1 ▼            │ │
│ └─────────────────────────────┘ │
│ ┌─────────────────────────────┐ │
│ │ [👤] Player 2 ▼            │ │
│ └─────────────────────────────┘ │
│                                 │
│     Recent Players:             │
│ [😊 Alex] [😊 Maria] [😊 John]  │
│                                 │
│ ┌─────────────────────────────┐ │
│ │    Continue to Review       │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

### Screen 4: Confirmation & Success
```
┌─────────────────────────────────┐
│           Success! ✨           │
├─────────────────────────────────┤
│                                 │
│        🎾 ✓ ✨                 │
│     Match Logged!               │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ Final Score: 6-4, 7-5       │ │
│ │ Result: Victory! 🏆         │ │
│ │                             │ │
│ │ Your Elo: 1450 (+15) ⬆     │ │
│ │ Rank: Advanced              │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │     Share Victory 📱        │ │
│ └─────────────────────────────┘ │
│ ┌─────────────────────────────┐ │
│ │      Log Another           │ │
│ └─────────────────────────────┘ │
│ ┌─────────────────────────────┐ │
│ │      Back to Home          │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

---

## HIGH-FIDELITY IMPLEMENTATION

Now I'll create the actual Flutter implementation with the design system:
# Minotaurs & Masks
## Global Game Jam 2026 Entry
## Game Design Document

**Jam Theme:** Mask  
**Engine:** Godot 4.6  
**Genre:** First-Person Grid-Based Puzzle Horror  
**Dev Time:** 48 hours (Friday 20:00 → Sunday 20:00)

---

## Table of Contents

1. [Vision Statement](#1-vision-statement)
2. [MDA Framework](#2-mda-framework)
3. [Core Mechanics](#3-core-mechanics)
4. [The Masks](#4-the-masks)
5. [The Minotaur](#5-the-minotaur)
6. [Level Design](#6-level-design)
7. [Visual Style](#7-visual-style)
8. [Godot Implementation Guide](#8-godot-implementation-guide)
9. [48-Hour Schedule](#9-48-hour-schedule)
10. [Scope Management](#10-scope-management)

---

## 1. Vision Statement

You are Ariadne's champion, descending into the labyrinth to destroy the Minotaur's phylactery. But sight is treacherous here — different masks reveal different truths. The Hunter's Mask shows the beast but blinds you to the pits. The Seer's Mask reveals hidden paths but hides your pursuer. The Ghost Mask exposes traps but conceals escape routes.

**Core Fantasy:** Every step is a decision. Every mask swap is a gamble.

```
┌─────────────────────────────────────────────────────────┐
│                     THE CORE LOOP                       │
│                                                         │
│    ┌──────────┐      ┌──────────┐      ┌──────────┐     │
│    │  MOVE    │ ──── │  SWAP    │ ──── │  SURVIVE │     │
│    │          │      │  MASK    │      │          │     │
│    └──────────┘      └──────────┘      └──────────┘     │
│         │                 │                  │          │
│         ▼                 ▼                  ▼          │
│    Risk: What's     Risk: Costs         Risk: Did I     │
│    on this tile?    your action!        see enough?     │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 2. MDA Framework

### Aesthetics (Target Feelings)

| Primary | Secondary |
|---------|-----------|
| **Challenge** — Risk/reward evaluation every turn | **Discovery** — The maze reveals itself differently through each mask |
| **Tension** — The Minotaur is always coming | **Sensation** — The visual shift when swapping masks |

### Dynamics (Emergent Behavior)

- Constant evaluation: "Do I need to see the Minotaur or the pits right now?"
- Information as resource — you're always partially blind
- Backtracking with different masks reveals new paths
- Legendary action creates rhythm: safe → danger spike → safe
- Mask-swap timing creates "oh shit" moments when Minotaur closes in

### Mechanics (Player Verbs)

```
┌────────────────────────────────────────────────┐
│              PLAYER ACTIONS                    │
├────────────────────────────────────────────────┤
│  MOVE        │ Step one tile in facing dir     │
│  TURN        │ Rotate 90° (free action)        │
│  SWAP MASK   │ Change equipped mask (action)   │
│  INTERACT    │ Open door / use phylactery      │
└────────────────────────────────────────────────┘
```

---

## 3. Core Mechanics

### 3.1 Grid-Based Movement

```
         N
         │
    W ───┼─── E        Player can face 4 cardinal directions
         │             Movement: 1 tile per move action
         S             Turning: Free (no action cost)
         
    ┌───┬───┬───┬───┬───┐
    │   │   │ ▲ │   │   │    ▲ = Player facing North
    ├───┼───┼───┼───┼───┤
    │   │ █ │   │ █ │   │    █ = Wall
    ├───┼───┼───┼───┼───┤
    │   │   │   │   │   │
    └───┴───┴───┴───┴───┘
```

**Why Grid-Based?**
- Discrete steps = discrete decisions
- Each tile can have hidden properties (pit, secret door)
- Easier to implement in 48 hours than free movement
- Authentic to classic dungeon crawlers (Doom, Eye of the Beholder)

### 3.2 Turn Economy (D&D Style)

Each turn, the player has:

| Resource | Options |
|----------|---------|
| **Move Action** | Move 1 tile forward/backward |
| **Standard Action** | Swap mask OR Interact |

**Combinations:**
- Move + Action (normal turn)
- Move + Move (double move, no other action)
- Action only (swap mask, stay still)

```
┌─────────────────────────────────────────────────────────┐
│                    TURN SEQUENCE                        │
│                                                         │
│   PLAYER TURN                    MINOTAUR TURN          │
│   ┌─────────────┐               ┌─────────────┐         │
│   │ Move Action │               │ Move toward │         │
│   │     +       │      ───►     │   player    │         │
│   │ Std Action  │               │ (2 tiles)   │         │
│   └─────────────┘               └─────────────┘         │
│                                        │                │
│                                        ▼                │
│                              ┌─────────────────┐        │
│                              │ Legendary ready?│        │
│                              │   Count down    │        │
│                              └─────────────────┘        │
└─────────────────────────────────────────────────────────┘
```

---

## 4. The Masks

### 4.1 Mask Trade-off Matrix

The core innovation: **every mask reveals AND conceals**.

```
┌──────────────────────────────────────────────────────────────┐
│                    MASK VISIBILITY MATRIX                    │
├────────────────┬──────────────┬───────────────┬──────────────┤
│     MASK       │   REVEALS    │    HIDES      │   USE WHEN   │
├────────────────┼──────────────┼───────────────┼──────────────┤
│ 🏹 HUNTER'S.   │ Minotaur     │ Pits          │ Need to know │
│    MASK        │ (thru walls) │ Traps         │ where he is  │
├────────────────┼──────────────┼───────────────┼──────────────┤
│ 👁 SEER'S      │ Secret doors │ Minotaur      │ Looking for  │
│    MASK        │ Exit         │               │ escape route │
├────────────────┼──────────────┼───────────────┼──────────────┤
│ 👻 GHOST'S     │ Pits         │ Secret doors  │ Navigating   │
│    MASK        │ Traps        │               │ hazard areas │
├────────────────┼──────────────┼───────────────┼──────────────┤
│ ❌ NO MASK     │ Normal walls │ Everything    │ Never ideal  │
│                │ Normal doors │ else          │ (baseline)   │
└────────────────┴──────────────┴───────────────┴──────────────┘
```

### 4.2 Mask-Swap Decision Points

**Scenario 1: Safe exploration**
> "I'm far from the Minotaur. I'll use Seer's Mask to find secret doors."

**Scenario 2: Danger close**
> "I hear him nearby. Swap to Hunter's Mask — but now I can't see the pits..."

**Scenario 3: Known hazard area**
> "There were pits here. Ghost Mask to navigate — but where is he now?"

```
    THE MASK DILEMMA
    
    ┌─────────────┐         ┌─────────────┐
    │  "I need    │         │  "I need    │
    │  to see     │   VS    │  to see     │
    │  the beast" │         │  the traps" │
    └──────┬──────┘         └──────┬──────┘
           │                       │
           ▼                       ▼
    ┌─────────────┐         ┌─────────────┐
    │  Hunter's   │         │   Ghost's   │
    │    Mask     │         │    Mask     │
    │  ⚔️ → 🕳️❌    │         │  🕳️ → ⚔️❌   │
    └─────────────┘         └─────────────┘
    
    You can never see everything.
```

---

## 5. The Minotaur

### 5.1 Base Behavior

- Same action economy as player (Move + Move, or Move + Action)
- **AI: Pathfind toward player** (A* or simple axis pursuit)
- Cannot use masks
- **Caught = Death** (player on same tile)

### 5.2 Legendary Action

Every **5 turns**, the Minotaur performs a Legendary Action.

**Visible Counter:** Players always know when it's coming.

```
    LEGENDARY ACTION COUNTDOWN
    
    Turn 1:  [█████] 5
    Turn 2:  [████░] 4
    Turn 3:  [███░░] 3
    Turn 4:  [██░░░] 2    ← Player should be preparing escape
    Turn 5:  [█░░░░] 1    ← Danger imminent
    Turn 6:  [░░░░░] 0    ← LEGENDARY TRIGGERS
    
    Then counter resets to 5.
```

**Recommended Legendary: CHARGE**
- Minotaur moves in a straight line until hitting a wall
- If player is in the path: death
- Creates "firing lanes" player must avoid

```
    CHARGE EXAMPLE
    
    Before:                    After:
    ┌───┬───┬───┬───┬───┐     ┌───┬───┬───┬───┬───┐
    │   │   │   │   │   │     │   │   │   │   │   │
    ├───┼───┼───┼───┼───┤     ├───┼───┼───┼───┼───┤
    │ M │ → │ → │ → │ █ │     │   │   │   │ M │ █ │
    ├───┼───┼───┼───┼───┤     ├───┼───┼───┼───┼───┤
    │   │   │ P │   │   │     │   │   │ P │   │   │
    └───┴───┴───┴───┴───┘     └───┴───┴───┴───┴───┘
    
    M = Minotaur, P = Player, █ = Wall
    Minotaur charges East until wall. Player survives (not in path).
```

---

## 6. Level Design

### 6.1 Maze Layout

**Recommended Size:** 9×9 to 12×12 tiles (manageable for jam)

```
    EXAMPLE MAZE STRUCTURE
    
    ┌───┬───┬───┬───┬───┬───┬───┬───┬───┐
    │ P │   │ █ │   │   │ █ │   │   │   │  P = Player Start
    ├───┼───┼───┼───┼───┼───┼───┼───┼───┤  G = Goal (Phylactery)
    │   │ █ │ █ │   │ █ │   │   │ █ │   │  M = Minotaur Start
    ├───┼───┼───┼───┼───┼───┼───┼───┼───┤  █ = Wall
    │   │   │   │   │ █ │   │ █ │   │   │  ○ = Pit (hidden)
    ├───┼───┼───┼───┼───┼───┼───┼───┼───┤  ◊ = Secret Door (hidden)
    │ █ │   │ █ │ ◊ │   │   │   │   │ █ │
    ├───┼───┼───┼───┼───┼───┼───┼───┼───┤
    │   │   │ █ │ █ │ G │ █ │ █ │   │   │
    ├───┼───┼───┼───┼───┼───┼───┼───┼───┤
    │ █ │   │   │ ◊ │ █ │   │   │   │ █ │
    ├───┼───┼───┼───┼───┼───┼───┼───┼───┤
    │   │   │ █ │   │ █ │   │ █ │ ○ │   │
    ├───┼───┼───┼───┼───┼───┼───┼───┼───┤
    │   │ █ │   │   │   │ █ │ █ │   │   │
    ├───┼───┼───┼───┼───┼───┼───┼───┼───┤
    │   │   │   │ █ │ M │   │   │ ○ │   │
    └───┴───┴───┴───┴───┴───┴───┴───┴───┘
```

### 6.2 Design Principles

1. **Multiple paths to center** — No single solution
2. **Each mask needed at least once** — Force mask swapping
3. **Secret doors as shortcuts** — Reward Seer's Mask use
4. **Pits guard direct routes** — Punish rushing
5. **Minotaur patrol zone** — Center-ish, unpredictable

### 6.3 Win/Lose Conditions

| Condition | Trigger | Result |
|-----------|---------|--------|
| **WIN** | Player reaches phylactery + Interact | Victory screen |
| **LOSE** | Minotaur occupies same tile as player | Death screen |
| **LOSE** | Player steps on hidden pit | Death screen |

---

## 7. Visual Style

### 7.1 Aesthetic: Doom 1 (1993)

```
┌────────────────────────────────────────────────────────────┐
│                     VISUAL TARGETS                         │
├────────────────────────────────────────────────────────────┤
│  ✓ Low-res textures (64×64, 128×128)                       │
│  ✓ No texture filtering (crispy pixels)                    │
│  ✓ Limited color palette                                   │
│  ✓ Billboarded sprites for enemies/items                   │
│  ✓ Simple geometry (CSG boxes)                             │
│  ✗ No PBR materials                                        │
│  ✗ No normal maps                                          │
│  ✗ No complex 3D models                                    │
└────────────────────────────────────────────────────────────┘
```

### 7.2 Development Art Pipeline

| Day | Visual Approach |
|-----|-----------------|
| Friday | CSGBox3D with solid color materials |
| Saturday | Same — focus on mechanics |
| Sunday AM | Add textures to existing CSGs |
| Sunday PM | Polish only if core works |

### 7.3 Color Coding (Placeholder Art)

```
    PLACEHOLDER COLORS
    
    ┌──────────────┬────────────┬─────────────────┐
    │   Element    │   Color    │   Hex           │
    ├──────────────┼────────────┼─────────────────┤
    │ Walls        │ Gray       │ #555555         │
    │ Floor        │ Dark Gray  │ #333333         │
    │ Pits         │ Red        │ #AA0000         │
    │ Secret Doors │ Purple     │ #660066         │
    │ Minotaur     │ Bright Red │ #FF0000         │
    │ Phylactery   │ Gold       │ #FFD700         │
    │ UI Text      │ White      │ #FFFFFF         │
    └──────────────┴────────────┴─────────────────┘
```

### 7.4 Sprite Approach

**All props use Sprite3D with billboarding:**

```gdscript
# Sprite always faces camera
sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
```

**Sprite Assets Needed:**

| Asset | Size | Priority |
|-------|------|----------|
| Minotaur (front) | 64×64 | HIGH |
| Phylactery | 32×32 | HIGH |
| Pit (top-down) | 64×64 | MEDIUM (can be texture) |

### 7.5 Godot Texture Settings

```
Project Settings → Rendering → Textures:
  default_texture_filter = TEXTURE_FILTER_NEAREST

Per-texture Import Settings:
  Filter: Nearest (NOT Linear)
```

---

## 8. Godot Implementation Guide

### 8.1 Project Structure

```
res://
├── Scenes/
│   ├── Main.tscn              # Entry point
│   ├── Game.tscn              # Main game scene
│   ├── Player/
│   │   └── Player.tscn        # Camera + input
│   ├── Minotaur/
│   │   └── Minotaur.tscn      # Enemy
│   ├── Maze/
│   │   └── Maze.tscn          # Level geometry
│   └── UI/
│       ├── HUD.tscn           # Turn indicator, mask slots
│       ├── DeathScreen.tscn
│       └── WinScreen.tscn
├── Scripts/
│   ├── GameManager.gd         # Turn state machine
│   ├── Player.gd              # Input, movement, masks
│   ├── Minotaur.gd            # AI, pathfinding
│   ├── Tile.gd                # Tile data (hasPit, etc.)
│   └── MaskSystem.gd          # Visibility toggling
├── Assets/
│   ├── Textures/
│   └── Sprites/
└── Audio/                      # Stretch goal
```
## 9. 48-Hour Schedule

### Overview

```
    FRIDAY          SATURDAY                 SUNDAY
    20:00           07:00                    07:00
      │               │                        │
      ▼               ▼                        ▼
    ┌─────┐  ┌─────────────────────┐  ┌─────────────────────┐
    │FOUND│  │ TURN SYSTEM + AI    │  │ VISUALS + POLISH    │
    │ATION│  │ MASK SYSTEM         │  │ PLAYTEST            │
    │     │  │ WIN/LOSE            │  │ SUBMIT              │
    └──┬──┘  └──────────┬──────────┘  └──────────┬──────────┘
       │                │                        │
    02:00            02:00                    20:00
    SLEEP            SLEEP                    DONE!
```

### Detailed Schedule

#### FRIDAY

| Time | Task | Milestone |
|------|------|-----------|
| 20:00–23:00 | Foundation | Camera moves on grid |
| 23:00–02:00 | Movement polish, test maze | Navigable maze |
| 02:00–07:00 | **SLEEP** | 😴 |

#### SATURDAY

| Time | Task | Milestone |
|------|------|-----------|
| 07:00–10:00 | Turn system + UI | Turns ping-pong |
| 10:00–13:00 | Minotaur AI | Minotaur chases |
| 13:00–15:00 | Legendary action | Scary spike moment |
| 15:00–16:00 | Playtest + bugs | Core loop works |
| 16:00–20:00 | **MASK SYSTEM** ⚠️ | Swapping changes vision |
| 20:00–23:00 | Hazards + secret doors | Masks matter |
| 23:00–01:00 | Win condition | Game completable |
| 01:00–02:00 | Start real maze | Layout sketched |
| 02:00–07:00 | **SLEEP** | 😴 |

#### SUNDAY

| Time | Task | Milestone |
|------|------|-----------|
| 07:00–09:00 | Finish maze | Real level |
| 09:00–11:00 | Visual pass | Textures + sprites |
| 11:00–12:00 | Audio pass | Atmosphere |
| 12:00–15:00 | Polish + juice | Feels complete |
| 15:00–17:00 | Playtesting | Balanced + fun |
| 17:00–19:00 | Bug fixing | Stable build |
| 19:00–20:00 | **SUBMIT** | 🎉 |

---

## 10. Scope Management

### 10.1 Cut List (In Order)

If behind schedule, cut these **first**:

```
    CUT PRIORITY (first to go → last to go)
    
    1. Audio            → Ship silent
    2. Third mask       → Two masks still works
    3. Legendary action → Minotaur just chases
    4. Secret doors     → Pits + Minotaur enough
    5. Smooth movement  → Snap is acceptable
```

### 10.2 Decision Points

| Time | Check | Action if Behind |
|------|-------|------------------|
| Sat 16:00 | Minotaur working? | Cut legendary action |
| Sat 23:00 | Masks working? | Cut third mask |
| Sun 11:00 | Visuals done? | Skip audio entirely |
| Sun 15:00 | In polish phase? | Cut scope hard, ship |

### 10.3 Stretch Goals

**Only if core done by Sunday 15:00:**

- [ ] Thread/rope visual trail
- [ ] Second legendary action type (Roar: skip player action)
- [ ] Mini-map (revealed tiles only)
- [ ] Death animation
- [ ] Minotaur roar SFX warns 1 turn before legendary

### 10.4 The Golden Rule

```
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   PLAYABLE  >  PRETTY                                     ║
║                                                           ║
║   A working game with gray boxes beats                    ║
║   a beautiful game that crashes.                          ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

---

## Appendix A: Input Mapping

```
Project → Project Settings → Input Map

move_forward    W, Up Arrow
move_backward   S, Down Arrow
turn_left       A, Left Arrow
turn_right      D, Right Arrow
swap_mask_1     1
swap_mask_2     2
swap_mask_3     3
remove_mask     0
interact        E, Space
```

## Appendix B: Quick Reference Card

```
┌─────────────────────────────────────────────────────────┐
│                  QUICK REFERENCE                        │
├─────────────────────────────────────────────────────────┤
│  TURN: Move + Action, or Move + Move                    │
│  TURN (free): Any number                                │
│  SWAP MASK: Costs your Action                           │
├─────────────────────────────────────────────────────────┤
│  HUNTER 🏹  → See Minotaur, blind to pits              │
│  SEER 👁    → See secrets, blind to Minotaur           │
│  GHOST 👻   → See pits, blind to secrets               │
├─────────────────────────────────────────────────────────┤
│  LEGENDARY: Every 5 turns, Minotaur charges            │
│  WIN: Reach center, interact with phylactery           │
│  LOSE: Touched by Minotaur OR step in hidden pit       │
└─────────────────────────────────────────────────────────┘
```

---

*Document generated: January 2025*  
*Good luck with the jam, Reupje! 🎮*


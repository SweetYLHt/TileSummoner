# TileSummoner - AI Development Context

## Tech Stack

- **Engine**: Godot 4.5.1
- **Language**: GDScript

## Project Status

| Module | Status |
|--------|--------|
| Design Docs | Complete (13 docs) |
| Message System | Implemented |
| Core Gameplay | Not started |

## Module Structure

| Path | Purpose | Status |
|------|---------|--------|
| `Docs/` | Game design documents | Existing |
| `Docs/game_design/` | Detailed design docs | Existing |
| `Scenes/` | Scene files (.tscn) | Existing (test scenes) |
| `Scripts/` | Game logic scripts (.gd) | Existing (message system) |
| `Scripts/message/` | Message system framework | Implemented |
| `Resources/` | Data resources (.tres) | Empty |

## Quick Start

- **Main Scene**: `res://Scenes/visual_test/message_visual_test.tscn`
- **AutoLoad**: `MessageServer` (`res://Scripts/message/message_server.gd`)

## Tool Preferences (IMPORTANT)

When exploring or debugging, prioritize these MCPs:

| MCP | Purpose |
|-----|---------|
| **Serena MCP** | Code structure, symbol search, file navigation |
| **Godot MCP** | Project info, scene operations, running game |

## Development Standards

See `Docs/CODING_STANDARDS.md` for:
- Naming conventions
- Type annotations
- Godot-specific rules (StringName, AutoLoad, paths, memory)
- Comment standards
- Data-driven principle
- Performance guidelines
- Factory pattern
- Message system usage
- Commit message format

## Directory Structure

```
Scripts/
├── message/           # Message system (implemented)
│   ├── message_server.gd
│   ├── messages/      # 19 game message types
│   └── ...
├── visual_test/       # Visual test scripts
└── ...

Scenes/
├── visual_test/       # Test scenes
└── ...

Resources/
└── (empty, to create .tres data files)
```

## AI Usage Guidelines

1. Read `Docs/game_design/` for game design details
2. Use Serena MCP for code exploration
3. Use Godot MCP for project operations
4. Follow `Docs/CODING_STANDARDS.md` for all code

## Related Documentation

| Document | Purpose |
|----------|---------|
| `Docs/CODING_STANDARDS.md` | Complete GDScript coding standards |
| `Docs/game_design/*.md` | Game design documents (13 files) |
| `Docs/游戏创意记录——地块召唤师.md` | Core design concepts |

## Current Implementation

### Message System (`Scripts/message/`)

- **MessageServer** - Global singleton for message routing
- **19 Message Types** - Tile, Unit, Card, Combat, Base, Flow, Economy, Zone events

### To Implement

1. Map System - 7x9 grid, tile rendering
2. Terrain Types - 9 terrain definitions
3. Connectivity Algorithm - Path detection
4. Unit System - Summon, movement, AI
5. Economy System - Mana, gold management
6. UI System - Tile selection, card operations
7. Combat System - Attack, skills, win/loss

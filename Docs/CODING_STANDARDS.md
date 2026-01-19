# TileSummoner - GDScript Coding Standards

## Naming Conventions

| Type | Format | Example |
|------|--------|---------|
| Class | `PascalCase` + `class_name` | `class_name MapManager` |
| Function | `snake_case` | `func get_tile_data()` |
| Variable | `snake_case` | `var grid_position` |
| Constant | `UPPER_SNAKE_CASE` | `const MAX_UNITS = 8` |
| Private | Prefix `_` | `var _cached_data` |
| Signal | `snake_case` | `signal tile_changed` |

**Important**: One `.gd` file = one class. Only one `extends` and one `class_name` per file.

## Type Annotations

Always use explicit types:

```gdscript
# ✅ Recommended
func get_tile(cell: Vector2i) -> TileData:
    return _grid_data[cell.x][cell.y]

# ❌ Avoid
func get_tile(cell):
    return _grid_data[cell.x][cell.y]
```

## Godot Specific Rules

### StringName

Use `StringName` for frequently compared strings (IDs):

```gdscript
var tile_type: StringName = &"forest"
if TileDatabase.has_type(&"forest"):
    pass
```

### AutoLoad Singletons

Scripts inherit `Node`, no `class_name` needed. Access globally without `static`:

```gdscript
# AutoLoad script
extends Node

func register_tile(data: TileData) -> void:
    pass

# Usage anywhere
TileDatabase.register_tile(data)
```

### Resource Paths

Always use `res://` absolute paths:

```gdscript
const TILE_SCENE = "res://scenes/tile.tscn"
var texture = preload("res://assets/sprite.png")
```

### Memory Management

```gdscript
# ✅ Safe deferred free
node.queue_free()

# ❌ Immediate free (may crash)
node.free()
```

### Null Checks

```gdscript
func spawn_unit(data: UnitData, pos: Vector2i) -> Unit:
    if not data:
        push_error("UnitData is null")
        return null
```

### Signal Connections

```gdscript
if not signal.is_connected(_on_event):
    signal.connect(_on_event)
```

## Comment Standards

```gdscript
## File header: Describe class purpose
extends Node
class_name TileManager

## Tile manager - Handles tile creation and connectivity
##
## Usage:
##   var manager = TileManager.new()
##   manager.initialize(size)

## Function comment: Describe params and return
## Sets tile type at given cell
## @param cell: Grid coordinate
## @param tile_type: Terrain type ID
## @return: Success status
func set_tile(cell: Vector2i, tile_type: StringName) -> bool:
    # Inline comment for complex logic
    pass
```

## Data-Driven Principle

Prefer `.tres` resources over hardcoded values:

```gdscript
# ❌ Hardcoded
var health = 100

# ✅ From resource
@export var data: TileData
var health = data.base_health
```

## Performance Guidelines

| Area | Guideline |
|------|-----------|
| IDs | Use `StringName` not `String` |
| Objects | Use object pools for频繁创建的对象 |
| Nodes | Prefer `RefCounted` over `Node` for data |
| Batching | Merge same-frame operations |
| Loading | Use `load()` over `preload()` for large resources |

## Factory Pattern

Static methods for creation:

```gdscript
extends Node
class_name UnitFactory

static func create(data: UnitData, pos: Vector2i) -> Unit:
    if not data:
        return null
    var unit = BASE_SCENE.instantiate()
    unit.data = data
    unit.position = pos
    return unit
```

## Message System

Implemented in `Scripts/message/message_server.gd`:

```gdscript
# Send message
var msg = TileChangedMessage.new()
msg.cell = Vector2i(3, 4)
msg.new_type = &"forest"
MessageServer.send_message(msg)

# Receive message
MessageServer.message_sent.connect(_on_message)

func _on_message(msg: Message) -> void:
    if msg is TileChangedMessage:
        # Handle tile change
        pass
```

## Debugging

```gdscript
# Debug output
print("[Manager] Creating tile at: %s" % pos)

# Warning
push_warning("Type '%s' not found" % type_id)

# Error
push_error("Invalid position: %s" % pos)

# Use F12 for Godot debugger
```

## Commit Message Format

Conventional Commits:

| Type | Usage | Example |
|------|-------|---------|
| `feat` | New feature | `feat: add forest terrain` |
| `fix` | Bug fix | `fix: connectivity check` |
| `docs` | Documentation | `docs: update standards` |
| `style` | Style only | `style: format code` |
| `refactor` | Refactor | `refactor: simplify manager` |
| `perf` | Performance | `perf: optimize rendering` |
| `test` | Test related | `test: add unit tests` |
| `chore` | Maintenance | `chore: update deps` |

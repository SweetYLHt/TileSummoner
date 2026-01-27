# TDD Patterns for Godot

## Red-Green-Refactor Cycle

### 1. Red Phase - Write Failing Test

Start by writing a test that fails:

```gdscript
func test_tile_initialization():
    var tile := Tile.new(TileType.FOREST)
    assert_that(tile.get_type()).is_equal(TileType.FOREST)
    assert_that(tile.get_defense_bonus()).is_equal(2)
```

**Run test immediately to confirm it fails.**

### 2. Green Phase - Make Test Pass

Write minimal code to pass:

```gdscript
class_name Tile extends Node2D:
    var _type: TileType

    func _init(type: TileType):
        _type = type

    func get_type() -> TileType:
        return _type

    func get_defense_bonus() -> int:
        return 2  # Minimal implementation
```

**Run test to confirm it passes.**

### 3. Refactor Phase - Improve Code

Clean up while tests stay green:

```gdscript
class_name Tile extends Node2D:
    var _type: TileType

    func _init(type: TileType):
        _type = type

    func get_type() -> TileType:
        return _type

    func get_defense_bonus() -> int:
        return TileConstants.get_defense_bonus(_type)  # Extracted to constants
```

**Run tests again to ensure nothing broke.**

---

## AAA Pattern (Arrange-Act-Assert)

Structure tests clearly:

```gdscript
func test_unit_movement_after_move():
    # Arrange - Set up test conditions
    var unit := Unit.new()
    var start_pos := Vector2(0, 0)
    unit.position = start_pos
    var target_pos := Vector2(3, 0)

    # Act - Execute the behavior
    unit.move_to(target_pos)

    # Assert - Verify expected outcome
    assert_that(unit.position).is_equal(target_pos)
    assert_that(unit.get_movement_points()).is_equal(2)  # 3 - 1 = 2
```

---

## Test Doubles

### Mock

Replace dependency with test double:

```gdscript
class TestMessageServer:
    var _messages: Array[Dictionary] = []

    func send_message(type: StringName, data: Dictionary):
        _messages.append({'type': type, 'data': data})

    func get_message_count() -> int:
        return _messages.size()

    func clear():
        _messages.clear()

# In test
func before():
    MessageServer = TestMessageServer.new()

func test_unit_sends_move_message():
    var unit := Unit.new()
    unit.move_to(Vector2(1, 0))
    assert_that(MessageServer.get_message_count()).is_equal(1)
```

### Stub

Provide canned responses:

```gdscript
class StubTileDatabase:
    func get_tile_defense(type: TileType) -> int:
        return 5  # Always returns 5 for testing

func test_attack_calculation_with_stub():
    var db := StubTileDatabase.new()
    var damage := CombatCalculator.calculate_attack(10, db, TileType.FOREST)
    assert_that(damage).is_equal(5)  # 10 - 5 = 5
```

### Fake

Working but simplified implementation:

```gdscript
class FakeInventory:
    var _items: Array[String] = []

    func add_item(item: String) -> bool:
        _items.append(item)
        return true

    func has_item(item: String) -> bool:
        return item in _items

func test_inventory_looting():
    var inventory := FakeInventory.new()
    inventory.add_item("sword")
    assert_that(inventory.has_item("sword")).is_true()
```

---

## Parameterized Tests

Test multiple cases:

```gdscript
func test_tile_defense_bonuses():
    var test_cases := [
        {type = TileType.FOREST, expected = 2},
        {type = TileType.MOUNTAIN, expected = 3},
        {type = TileType.PLAINS, expected = 0},
    ]

    for case in test_cases:
        var tile := Tile.new(case.type)
        assert_that(tile.get_defense_bonus()).is_equal(case.expected,
            "Failed for type: %s" % TileType.keys()[case.type])
```

---

## Testing Async Operations

Use GdUnit4 async support:

```gdscript
func test_async_unit_movement():
    var unit := Unit.new()
    var moved := false

    unit.movement_completed.connect(func(): moved = true)

    # Start async movement
    unit.move_async(Vector2(5, 0))

    # Wait for signal (max 1 second)
    await await_signal(unit.movement_completed, 1000)

    assert_that(moved).is_true()
    assert_that(unit.position).is_equal(Vector2(5, 0))
```

---

## Test Isolation

Each test should be independent:

```gdscript
var test_unit: Unit

func before():
    # Fresh instance for each test
    test_unit = Unit.new()

func after():
    # Clean up
    test_unit.queue_free()

func test_unit_health():
    test_unit.set_health(100)
    assert_that(test_unit.get_health()).is_equal(100)

func test_unit_mana():
    test_unit.set_mana(50)
    assert_that(test_unit.get_mana()).is_equal(50)
    # Health is not affected - tests are isolated
    assert_that(test_unit.get_health()).is_equal(0)  # Default
```

---

## Edge Case Testing

Test boundaries and edge cases:

```gdscript
func test_movement_edge_cases():
    var unit := Unit.new()

    # Zero movement
    unit.move_to(Vector2(0, 0))
    assert_that(unit.position).is_equal(Vector2(0, 0))

    # Maximum range
    var max_pos := Vector2(9, 9)  # Assuming 10x10 grid
    unit.move_to(max_pos)
    assert_that(unit.position).is_equal(max_pos)

    # Negative coordinates (should fail)
    unit.move_to(Vector2(-1, 0))
    assert_that(unit.position).is_equal(Vector2(0, 0))  # Should not move

    # Beyond maximum
    unit.move_to(Vector2(20, 20))
    assert_that(unit.position.x).is_less(10)  # Should clamp
```

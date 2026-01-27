# Test Doubles Example

## Overview

Test doubles (mocks, stubs, fakes, and spies) replace real dependencies with test-specific implementations. This isolates the code under test and makes tests faster and more reliable.

## When to Use Test Doubles

1. **Dependency is slow** - Database calls, network requests, file I/O
2. **Dependency is unreliable** - External services, random values
3. **Dependency has side effects** - Sending emails, writing files
4. **Dependency doesn't exist yet** - Interface-first development

---

## 1. Mock Objects

### Purpose
Verify behavior (which methods were called, with what arguments).

### Example: Mock Message Server

```gdscript
# Production dependency
class_name MessageServer
extends Node

func send(type: StringName, data: Dictionary) -> void:
    # Real implementation - sends to network
    pass

func register(type: StringName, callable: Callable) -> void:
    # Real implementation - registers listener
    pass
```

```gdscript
# Mock implementation
class_name MockMessageServer
extends RefCounted

var sent_messages: Array[Dictionary] = []
var registered_listeners: Dictionary = {}

func send(type: StringName, data: Dictionary) -> void:
    sent_messages.append({"type": type, "data": data})

func register(type: StringName, callable: Callable) -> void:
    if not registered_listeners.has(type):
        registered_listeners[type] = []
    registered_listeners[type].append(callable)

# Verification helpers
func was_message_sent(type: StringName) -> bool:
    for msg in sent_messages:
        if msg.type == type:
            return true
    return false

func get_message_count(type: StringName) -> int:
    var count := 0
    for msg in sent_messages:
        if msg.type == type:
            count += 1
    return count

func get_last_message_data(type: StringName) -> Dictionary:
    for i in range(sent_messages.size() - 1, -1, -1):
        if sent_messages[i].type == type:
            return sent_messages[i].data
    return {}

func clear() -> void:
    sent_messages.clear()
    registered_listeners.clear()
```

```gdscript
# Test using mock
extends GdUnitTestSuite

var mock_server: MockMessageServer
var original_server: MessageServer

func before():
    # Save original
    original_server = MessageServer
    # Replace with mock
    mock_server = MockMessageServer.new()
    MessageServer = mock_server

func after():
    # Restore original
    MessageServer = original_server

func test_unit_sends_move_message():
    var unit := Unit.new()
    unit.move_to(Vector2(5, 0))

    # Verify message was sent
    assert_that(mock_server.was_message_sent(&"unit_moved")).is_true()

func test_move_message_contains_position():
    var unit := Unit.new()
    unit.move_to(Vector2(3, 7))

    var data := mock_server.get_last_message_data(&"unit_moved")
    assert_that(data["position"]).is_equal(Vector2(3, 7))

func test_multiple_moves():
    var unit := Unit.new()

    unit.move_to(Vector2(1, 0))
    unit.move_to(Vector2(2, 0))
    unit.move_to(Vector2(3, 0))

    assert_that(mock_server.get_message_count(&"unit_moved")).is_equal(3)
```

---

## 2. Stub Objects

### Purpose
Provide canned responses to method calls.

### Example: Stub Database

```gdscript
# Production dependency
class_name Database
extends Node

func query(sql: String) -> Array:
    # Real implementation - queries database
    return []

func save(data: Dictionary) -> int:
    # Real implementation - saves to database
    return 0
```

```gdscript
# Stub implementation
class_name StubDatabase
extends RefCounted

var _query_responses: Dictionary = {}
var _save_results: Dictionary = {}

func set_query_response(sql: String, response: Array) -> void:
    _query_responses[sql] = response

func set_save_result(data_key: String, id: int) -> void:
    _save_results[data_key] = id

func query(sql: String) -> Array:
    if _query_responses.has(sql):
        return _query_responses[sql]
    return []

func save(data: Dictionary) -> int:
    var key := data.to_string()
    if _save_results.has(key):
        return _save_results[key]
    return -1
```

```gdscript
# Test using stub
extends GdUnitTestSuite

var stub_db: StubDatabase
var original_db: Database

func before():
    original_db = Database
    stub_db = StubDatabase.new()

    # Set up canned responses
    stub_db.set_query_response("SELECT * FROM units", [
        {"id": 1, "name": "Warrior", "hp": 100},
        {"id": 2, "name": "Archer", "hp": 50}
    ])

    stub_db.set_save_result("unit_data", 42)

    Database = stub_db

func after():
    Database = original_db

func test_load_units():
    var loader := UnitLoader.new()
    var units := loader.load_all_units()

    assert_that(units.size()).is_equal(2)
    assert_that(units[0].name).is_equal("Warrior")
    assert_that(units[1].name).is_equal("Archer")

func test_save_unit():
    var unit := Unit.new()
    unit.name = "Knight"

    var saver := UnitSaver.new()
    var id := saver.save(unit)

    assert_that(id).is_equal(42)
```

---

## 3. Fake Objects

### Purpose
Working but simplified implementation for testing.

### Example: Fake Inventory

```gdscript
# Production implementation
class_name Inventory
extends Node

var _items: Dictionary = {}
var _capacity: int = 20

func add_item(item_id: String, quantity: int) -> bool:
    # Real implementation with validation, persistence, etc.
    return true

func remove_item(item_id: String, quantity: int) -> bool:
    # Real implementation with validation, persistence, etc.
    return true

func get_item_count(item_id: String) -> int:
    return _items.get(item_id, 0)

func serialize() -> Dictionary:
    # Complex serialization logic
    return {}

func load_from_save(data: Dictionary) -> void:
    # Complex deserialization logic
    pass
```

```gdscript
# Fake implementation - simplified but working
class_name FakeInventory
extends RefCounted

var _items: Dictionary = {}

func add_item(item_id: String, quantity: int) -> bool:
    if _items.has(item_id):
        _items[item_id] += quantity
    else:
        _items[item_id] = quantity
    return true

func remove_item(item_id: String, quantity: int) -> bool:
    if not _items.has(item_id):
        return false
    if _items[item_id] < quantity:
        return false

    _items[item_id] -= quantity
    if _items[item_id] == 0:
        _items.erase(item_id)
    return true

func get_item_count(item_id: String) -> int:
    return _items.get(item_id, 0)

func get_total_items() -> int:
    var total := 0
    for count in _items.values():
        total += count
    return total

func is_empty() -> bool:
    return _items.is_empty()
```

```gdscript
# Test using fake
extends GdUnitTestSuite

var fake_inventory: FakeInventory
var original_inventory: Inventory

func before():
    original_inventory = PlayerInventory  # AutoLoad
    fake_inventory = FakeInventory.new()
    PlayerInventory = fake_inventory

func after():
    PlayerInventory = original_inventory

func test_loot_system():
    var loot := LootTable.new()
    var enemy := Enemy.new()

    # Enemy drops loot
    enemy.die()

    var dropped_items := loot.generate_drop(enemy)
    for item in dropped_items:
        fake_inventory.add_item(item.id, item.quantity)

    # Verify using fake
    assert_that(fake_inventory.get_total_items()).is_greater(0)
    assert_that(fake_inventory.is_empty()).is_false()
```

---

## 4. Spy Objects

### Purpose
Wrap real objects and record interactions.

### Example: Spy on Card Effects

```gdscript
class_name EffectSpy
extends RefCounted

var _effect_calls: Array[Dictionary] = []

func record_effect(effect_name: String, target: Node, magnitude: int) -> void:
    _effect_calls.append({
        "effect": effect_name,
        "target": target,
        "magnitude": magnitude
    })

func was_effect_applied(effect_name: String) -> bool:
    for call in _effect_calls:
        if call.effect == effect_name:
            return true
    return false

func get_effect_count(effect_name: String) -> int:
    var count := 0
    for call in _effect_calls:
        if call.effect == effect_name:
            count += 1
    return count

func get_last_target(effect_name: String) -> Node:
    for i in range(_effect_calls.size() - 1, -1, -1):
        if _effect_calls[i].effect == effect_name:
            return _effect_calls[i].target
    return null

func clear() -> void:
    _effect_calls.clear()
```

```gdscript
# Test using spy
extends GdUnitTestSuite

var spy: EffectSpy

func before():
    spy = EffectSpy.new()

func test_card_applies_damage_effect():
    var card := DamageCard.new()
    card.set_spy(spy)

    var target := Unit.new()
    card.play(target)

    assert_that(spy.was_effect_applied("damage")).is_true()
    assert_that(spy.get_effect_count("damage")).is_equal(1)
    assert_that(spy.get_last_target("damage")).is_equal(target)
```

---

## 5. Test Double Builder Pattern

### Helper for creating test doubles

```gdscript
# test_double_builder.gd
class_name TestDoubleBuilder
extends RefCounted

static func create_mock_database() -> MockDatabase:
    var mock := MockDatabase.new()
    mock.set_query_response("SELECT * FROM players WHERE id = 1", [
        {"id": 1, "name": "TestPlayer", "level": 5}
    ])
    mock.set_save_result("player_data", 1)
    return mock

static func create_mock_message_server() -> MockMessageServer:
    return MockMessageServer.new()

static func create_fake_inventory(items: Dictionary) -> FakeInventory:
    var fake := FakeInventory.new()
    for item_id in items:
        fake.add_item(item_id, items[item_id])
    return fake
```

---

## 6. Integration with AutoLoad

### AutoLoad Replacement Pattern

```gdscript
# test_autoload_manager.gd
class_name TestAutoLoadManager
extends RefCounted

var _originals: Dictionary = {}
var _doubles: Dictionary = {}

func replace_autoload(autoload_name: String, double: Object) -> void:
    # Store original reference
    _originals[autoload_name] = ClassDB.class_get_property(
        ClassDB.class_get_name("Game"), autoload_name
    )

    # Replace with double
    _doubles[autoload_name] = double
    # (Actual implementation depends on how AutoLoad is accessed)

func restore_all() -> void:
    for name in _originals:
        # Restore original
        pass

    _originals.clear()
    _doubles.clear()
```

---

## 7. Example: Complete Test Suite with Doubles

```gdscript
# test_combat_system.gd
extends GdUnitTestSuite

var mock_damage_calculator: MockDamageCalculator
var fake_inventory: FakeInventory
var spy_effect_tracker: EffectSpy
var original_dependencies: Dictionary

func before():
    # Save originals
    original_dependencies["DamageCalc"] = DamageCalc
    original_dependencies["Inventory"] = PlayerInventory

    # Create doubles
    mock_damage_calculator = MockDamageCalculator.new()
    mock_damage_calculator.set_base_damage(50)

    fake_inventory = FakeInventory.new()
    fake_inventory.add_item("health_potion", 3)

    spy_effect_tracker = EffectSpy.new()

    # Replace dependencies
    DamageCalc = mock_damage_calculator
    PlayerInventory = fake_inventory

func after():
    # Restore originals
    for name in original_dependencies:
        if name == "DamageCalc":
            DamageCalc = original_dependencies[name]
        elif name == "Inventory":
            PlayerInventory = original_dependencies[name]

func test_attack_uses_damage_calculator():
    var attacker := Unit.new()
    var defender := Unit.new()

    attacker.attack(defender)

    # Verify damage calculator was used
    assert_that(mock_damage_calculator.was_called()).is_true()

func test_attack_applies_damage():
    var attacker := Unit.new()
    var defender := Unit.new()

    attacker.set_effect_spy(spy_effect_tracker)
    attacker.attack(defender)

    assert_that(spy_effect_tracker.was_effect_applied("damage")).is_true()

func test_use_potion():
    var unit := Unit.new()
    unit.take_damage(30)

    unit.use_health_potion()

    assert_that(fake_inventory.get_item_count("health_potion")).is_equal(2)
    assert_that(unit.get_health()).is_equal(70)  # Assuming heal for 40
```

---

## Best Practices

1. **Prefer real objects** - Use doubles only when necessary
2. **Keep doubles simple** - They're for testing, not production
3. **Name them clearly** - `MockX`, `StubX`, `FakeX`
4. **Document behavior** - Comment what the double does
5. **Restore originals** - Always clean up in `after()`
6. **Test the double** - Ensure the double works correctly
7. **Use patterns** - Builder pattern for consistent doubles

## When NOT to Use Test Doubles

- The dependency is fast and reliable
- The dependency is core to the functionality
- Testing the integration is the goal
- The double would be as complex as the real thing

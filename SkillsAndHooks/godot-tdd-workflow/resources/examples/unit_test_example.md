# Unit Test Example

## Overview

This example demonstrates a complete unit test for a simple `Counter` class.

## Production Code

```gdscript
# counter.gd
class_name Counter
extends RefCounted

var _value: int = 0

func increment() -> void:
    _value += 1

func decrement() -> void:
    _value -= 1

func get_value() -> int:
    return _value

func reset() -> void:
    _value = 0

func set_value(value: int) -> void:
    if value < 0:
        push_error("Counter value cannot be negative")
        return
    _value = value
```

## Unit Test

```gdscript
# test_counter.gd
extends GdUnitTestSuite

var counter: Counter

func before():
    # Fresh counter for each test
    counter = Counter.new()

func after():
    # Cleanup
    counter = null

# Basic functionality tests
func test_initial_value():
    assert_that(counter.get_value()).is_equal(0)

func test_increment():
    counter.increment()
    assert_that(counter.get_value()).is_equal(1)

    counter.increment()
    assert_that(counter.get_value()).is_equal(2)

func test_decrement():
    counter.decrement()
    assert_that(counter.get_value()).is_equal(-1)

func test_reset():
    counter.increment()
    counter.increment()
    counter.reset()
    assert_that(counter.get_value()).is_equal(0)

# Edge cases
func test_multiple_increments():
    for i in range(10):
        counter.increment()
    assert_that(counter.get_value()).is_equal(10)

func test_set_value():
    counter.set_value(5)
    assert_that(counter.get_value()).is_equal(5)

func test_set_negative_value_rejected():
    var error_caught := false

    # Capture error output
    counter.set_value(-1)

    # Value should not change
    assert_that(counter.get_value()).is_equal(0)
```

## Testing a More Complex Class

```gdscript
# inventory.gd
class_name Inventory
extends RefCounted

signal item_added(item_name: String, quantity: int)
signal item_removed(item_name: String, quantity: int)
signal inventory_full

const MAX_CAPACITY: int = 20

var _items: Dictionary = {}

func add_item(item_name: String, quantity: int) -> bool:
    var current_total := _calculate_total()
    if current_total + quantity > MAX_CAPACITY:
        inventory_full.emit()
        return false

    if _items.has(item_name):
        _items[item_name] += quantity
    else:
        _items[item_name] = quantity

    item_added.emit(item_name, quantity)
    return true

func remove_item(item_name: String, quantity: int) -> bool:
    if not _items.has(item_name):
        return false

    if _items[item_name] < quantity:
        return false

    _items[item_name] -= quantity
    if _items[item_name] == 0:
        _items.erase(item_name)

    item_removed.emit(item_name, quantity)
    return true

func get_item_count(item_name: String) -> int:
    return _items.get(item_name, 0)

func get_total_items() -> int:
    return _calculate_total()

func _calculate_total() -> int:
    var total := 0
    for count in _items.values():
        total += count
    return total

func is_full() -> bool:
    return _calculate_total() >= MAX_CAPACITY
```

```gdscript
# test_inventory.gd
extends GdUnitTestSuite

var inventory: Inventory

func before():
    inventory = Inventory.new()

func after():
    inventory = null

# Basic add/remove tests
func test_add_item():
    var result := inventory.add_item("sword", 1)
    assert_that(result).is_true()
    assert_that(inventory.get_item_count("sword")).is_equal(1)

func test_add_multiple_items():
    inventory.add_item("sword", 3)
    assert_that(inventory.get_item_count("sword")).is_equal(3)

    inventory.add_item("sword", 2)
    assert_that(inventory.get_item_count("sword")).is_equal(5)

func test_remove_item():
    inventory.add_item("potion", 5)
    var result := inventory.remove_item("potion", 2)

    assert_that(result).is_true()
    assert_that(inventory.get_item_count("potion")).is_equal(3)

func test_remove_all_of_item():
    inventory.add_item("potion", 3)
    inventory.remove_item("potion", 3)

    assert_that(inventory.get_item_count("potion")).is_equal(0)

func test_remove_nonexistent_item():
    var result := inventory.remove_item("nonexistent", 1)
    assert_that(result).is_false()

# Signal tests
func test_item_added_signal():
    var signal_received := false
    var received_item := ""
    var received_qty := 0

    inventory.item_added.connect(func(item, qty):
        signal_received = true
        received_item = item
        received_qty = qty
    )

    inventory.add_item("shield", 2)

    assert_that(signal_received).is_true()
    assert_that(received_item).is_equal("shield")
    assert_that(received_qty).is_equal(2)

func test_item_removed_signal():
    var signal_received := false

    inventory.item_removed.connect(func(_item, _qty): signal_received = true)
    inventory.add_item("potion", 5)
    inventory.remove_item("potion", 2)

    assert_that(signal_received).is_true()

func test_inventory_full_signal():
    var signal_received := false
    inventory.inventory_full.connect(func(): signal_received = true)

    # Fill inventory
    inventory.add_item("item", 20)
    inventory.add_item("overflow", 1)  # Should fail and emit signal

    assert_that(signal_received).is_true()

# Edge cases
func test_inventory_capacity():
    assert_that(inventory.is_full()).is_false()

    inventory.add_item("filler", 20)
    assert_that(inventory.is_full()).is_true()

    var result := inventory.add_item("more", 1)
    assert_that(result).is_false()

func test_total_items_count():
    assert_that(inventory.get_total_items()).is_equal(0)

    inventory.add_item("sword", 3)
    inventory.add_item("potion", 5)
    inventory.add_item("shield", 2)

    assert_that(inventory.get_total_items()).is_equal(10)

func test_remove_more_than_available():
    inventory.add_item("potion", 3)
    var result := inventory.remove_item("potion", 5)  # Try to remove 5

    assert_that(result).is_false()
    assert_that(inventory.get_item_count("potion")).is_equal(3)
```

## Testing with Dependencies

```gdscript
# player.gd
class_name Player
extends Node2D

var _health: int = 100
var _inventory: Inventory

func _init(inventory: Inventory):
    _inventory = inventory

func take_damage(amount: int) -> void:
    _health -= amount
    if _health <= 0:
        die()

func heal(amount: int) -> void:
    _health += amount
    if _health > 100:
        _health = 100

func use_potion() -> bool:
    if _inventory.get_item_count("potion") > 0:
        _inventory.remove_item("potion", 1)
        heal(30)
        return true
    return false

func get_health() -> int:
    return _health

func die():
    queue_free()
```

```gdscript
# test_player.gd
extends GdUnitTestSuite

var player: Player
var mock_inventory: Inventory

func before():
    mock_inventory = Inventory.new()
    player = Player.new(mock_inventory)

func after():
    if is_instance_valid(player):
        player.queue_free()

func test_take_damage():
    player.take_damage(20)
    assert_that(player.get_health()).is_equal(80)

func test_take_damage_lethal():
    var test_tree := Node.new()
    get_tree().root.add_child(test_tree)
    test_tree.add_child(player)

    player.take_damage(100)

    await await_process_frame()
    assert_that(is_instance_valid(player)).is_false()

    test_tree.queue_free()

func test_heal():
    player.take_damage(30)
    player.heal(20)
    assert_that(player.get_health()).is_equal(90)

func test_heal_cap_at_max():
    player.take_damage(10)
    player.heal(50)  # Would exceed 100
    assert_that(player.get_health()).is_equal(100)

func test_use_potion():
    mock_inventory.add_item("potion", 2)
    player.take_damage(50)

    var result := player.use_potion()

    assert_that(result).is_true()
    assert_that(player.get_health()).is_equal(80)
    assert_that(mock_inventory.get_item_count("potion")).is_equal(1)

func test_use_potion_when_empty():
    var result := player.use_potion()
    assert_that(result).is_false()
```

## Key Takeaways

1. **Arrange-Act-Assert**: Clear test structure
2. **Setup/Teardown**: Use `before()` and `after()` for common setup
3. **Test isolation**: Each test should be independent
4. **Edge cases**: Test boundaries, empty states, and invalid inputs
5. **Signal testing**: Connect and verify signal emissions
6. **Dependencies**: Inject dependencies for testability

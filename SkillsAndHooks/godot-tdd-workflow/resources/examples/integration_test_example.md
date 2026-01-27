# Integration Test Example

## Overview

Integration tests verify that multiple components work together correctly. Unlike unit tests, which isolate single units, integration tests test real interactions between objects.

## Scene Integration Test

### Production Scene: Battle Map

```gdscript
# battle_map.gd
class_name BattleMap
extends Node2D

signal unit_placed(unit: Unit, position: Vector2)
signal turn_changed(player_index: int)

var _tiles: Array[Tile] = []
var _units: Array[Unit] = []
var _current_player: int = 0

func _ready():
    _generate_map()

func _generate_map():
    for x in range(7):
        for y in range(9):
            var tile := Tile.new()
            tile.position = Vector2(x * 64, y * 64)
            tile.tile_clicked.connect(_on_tile_clicked)
            add_child(tile)
            _tiles.append(tile)

func place_unit(unit: Unit, tile_index: int) -> bool:
    if tile_index < 0 or tile_index >= _tiles.size():
        return false

    if _tiles[tile_index].has_unit():
        return false

    _tiles[tile_index].set_unit(unit)
    _units.append(unit)
    add_child(unit)
    unit_placed.emit(unit, _tiles[tile_index].position)

    return true

func get_tile_at_position(pos: Vector2) -> Tile:
    for tile in _tiles:
        if tile.get_global_rect().has_point(pos):
            return tile
    return null

func end_turn():
    _current_player = (_current_player + 1) % 2
    turn_changed.emit(_current_player)

func _on_tile_clicked(tile: Tile, button_index: int):
    if button_index == MOUSE_BUTTON_LEFT:
        MessageServer.send("tile_selected", {"tile": tile})
```

### Integration Test

```gdscript
# test_battle_map_integration.gd
extends GdUnitTestSuite

var battle_map: BattleMap

func before():
    battle_map = BattleMap.new()
    get_tree().root.add_child(battle_map)
    await await_process_frame()  # Wait for _ready

func after():
    if is_instance_valid(battle_map):
        battle_map.queue_free()
        await await_process_frame()

# Test scene initialization
func test_map_generation():
    var tiles_found := 0
    for child in battle_map.get_children():
        if child is Tile:
            tiles_found += 1

    assert_that(tiles_found).is_equal(63)  # 7x9 grid

func test_tiles_have_positions():
    var tiles := battle_map.find_children("*", "Tile")

    for tile in tiles:
        assert_that(tile.position).is_not_equal(Vector2.ZERO)

func test_tiles_clickable():
    var tiles := battle_map.find_children("*", "Tile")
    var first_tile := tiles[0] as Tile

    assert_that(first_tile.has_signal("tile_clicked")).is_true()

# Test unit placement
func test_place_unit_on_map():
    var unit := Unit.new()
    var tile_index := 0

    var result := battle_map.place_unit(unit, tile_index)

    assert_that(result).is_true()
    assert_that(unit.get_parent()).is_equal(battle_map)

func test_place_unit_emits_signal():
    var unit := Unit.new()
    var signal_received := false
    var received_unit: Unit = null
    var received_pos: Vector2

    battle_map.unit_placed.connect(func(u: Unit, pos: Vector2):
        signal_received = true
        received_unit = u
        received_pos = pos
    )

    battle_map.place_unit(unit, 5)

    assert_that(signal_received).is_true()
    assert_that(received_unit).is_equal(unit)
    assert_that(received_pos).is_not_equal(Vector2.ZERO)

func test_cannot_place_unit_on_occupied_tile():
    var unit1 := Unit.new()
    var unit2 := Unit.new()

    battle_map.place_unit(unit1, 0)
    var result := battle_map.place_unit(unit2, 0)

    assert_that(result).is_false()

func test_cannot_place_unit_out_of_bounds():
    var unit := Unit.new()

    var result1 := battle_map.place_unit(unit, -1)
    var result2 := battle_map.place_unit(unit, 100)

    assert_that(result1).is_false()
    assert_that(result2).is_false()

# Test turn system
func test_end_turn_changes_player():
    battle_map.end_turn()
    assert_that(battle_map._current_player).is_equal(1)

    battle_map.end_turn()
    assert_that(battle_map._current_player).is_equal(0)  # Wrapped around

func test_end_turn_emits_signal():
    var signal_received := false
    var received_player := -1

    battle_map.turn_changed.connect(func(player: int):
        signal_received = true
        received_player = player
    )

    battle_map.end_turn()

    assert_that(signal_received).is_true()
    assert_that(received_player).is_equal(1)

# Test tile selection flow
func test_tile_selection_flow():
    var tiles := battle_map.find_children("*", "Tile")
    var tile := tiles[0] as Tile

    var message_received := false
    MessageServer.connect_to("tile_selected", func(data): message_received = true)

    tile.simulate_click(MOUSE_BUTTON_LEFT)

    assert_that(message_received).is_true()
```

## Message System Integration

### Production Code

```gdscript
# message_bus.gd
class_name MessageBus
extends Node

var _listeners: Dictionary = {}

func register(type: StringName, callable: Callable) -> void:
    if not _listeners.has(type):
        _listeners[type] = []
    _listeners[type].append(callable)

func send(type: StringName, data: Dictionary) -> void:
    if _listeners.has(type):
        for listener in _listeners[type]:
            listener.call(data)

# card_system.gd
class_name CardSystem
extends Node

signal card_played(card: Card)

func _init():
    MessageBus.register("card_played", _on_card_played_message)

func play_card(card: Card) -> void:
    card_played.emit(card)
    MessageBus.send("card_played", {"card": card})

func _on_card_played_message(data: Dictionary):
    var card := data["card"] as Card
    print("Card played message received: %s" % card.card_name)

# mana_system.gd
class_name ManaSystem
extends Node

var _current_mana: int = 10

func _init():
    MessageBus.register("card_played", _on_card_played)

func _on_card_played(data: Dictionary):
    var card := data["card"] as Card
    _current_mana -= card.mana_cost
    MessageBus.send("mana_changed", {"mana": _current_mana})

func get_mana() -> int:
    return _current_mana
```

### Integration Test

```gdscript
# test_system_integration.gd
extends GdUnitTestSuite

var card_system: CardSystem
var mana_system: ManaSystem
var message_bus: MessageBus

func before():
    message_bus = MessageBus.new()
    card_system = CardSystem.new()
    mana_system = ManaSystem.new()

    get_tree().root.add_child(message_bus)
    get_tree().root.add_child(card_system)
    get_tree().root.add_child(mana_system)

func after():
    message_bus.queue_free()
    card_system.queue_free()
    mana_system.queue_free()
    await await_process_frame()

func test_card_played_sends_message():
    var message_received := false
    var received_card: Card = null

    MessageBus.register("test_card", func(data):
        message_received = true
        received_card = data["card"]
    )

    var card := Card.new()
    card.card_name = "Fireball"

    message_bus.send("test_card", {"card": card})

    assert_that(message_received).is_true()
    assert_that(received_card.card_name).is_equal("Fireball")

func test_card_played_reduces_mana():
    var card := Card.new()
    card.mana_cost = 5

    card_system.play_card(card)
    await await_process_frame()

    assert_that(mana_system.get_mana()).is_equal(5)  # 10 - 5

func test_multiple_listeners_receive_message():
    var listener1_count := 0
    var listener2_count := 0

    MessageBus.register("test", func(_data): listener1_count += 1)
    MessageBus.register("test", func(_data): listener2_count += 1)

    message_bus.send("test", {})

    assert_that(listener1_count).is_equal(1)
    assert_that(listener2_count).is_equal(1)
```

## Resource Loading Integration

```gdscript
# test_resource_integration.gd
extends GdUnitTestSuite

func test_load_tile_database():
    var db := load("res://Resources/tile_database.tres") as TileDatabase

    assert_that(db).is_not_null()
    assert_that(db).is_instanceof(TileDatabase)

func test_tile_database_has_all_terrain_types():
    var db := load("res://Resources/tile_database.tres") as TileDatabase

    for type in TileType.values():
        var defense := db.get_defense_bonus(type)
        assert_that(defense).is_greater_or_equal(0)

func test_load_and_instantiate_tile_scene():
    var scene := load("res://Scenes/tile.tscn") as PackedScene
    var instance := scene.instantiate()

    assert_that(instance).is_not_null()
    assert_that(instance).is_instanceof(Tile)

    instance.queue_free()

func test_tile_scene_has_required_components():
    var scene := load("res://Scenes/tile.tscn") as PackedScene
    var tile := scene.instantiate()

    var sprite := tile.get_node_or_null("Sprite2D")
    var collision := tile.get_node_or_null("CollisionShape2D")

    assert_that(sprite).is_not_null()
    assert_that(collision).is_not_null()

    tile.queue_free()
```

## AutoLoad Integration

```gdscript
# test_autoload_integration.gd
extends GdUnitTestSuite

func test_message_server_autoload_exists():
    assert_that(MessageServer).is_not_null()

func test_message_server_can_send_messages():
    var received := false

    MessageServer.connect_to("test_message", func(_data): received = true)
    MessageServer.send("test_message", {})

    assert_that(received).is_true()

func test_tile_database_autoload_exists():
    assert_that(TileDatabase).is_not_null()

func test_tile_database_can_query_data():
    var defense := TileDatabase.get_defense_bonus(TileType.FOREST)

    assert_that(defense).is_greater_or_equal(0)
```

## End-to-End Game Flow Test

```gdscript
# test_game_flow.gd
extends GdUnitTestSuite

var game: Game
var player: Player
var enemy: Enemy

func before():
    game = Game.new()
    get_tree().root.add_child(game)
    await await_process_frame()

    player = game.get_player()
    enemy = game.get_enemy()

func after():
    game.queue_free()
    await await_process_frame()

# Complete game scenario
func test_complete_turn_flow():
    var initial_health := enemy.get_health()

    # Player draws card
    game.draw_card()
    assert_that(game.get_hand_size()).is_equal(1)

    # Player plays card
    var card := game.get_hand()[0]
    game.play_card(card, enemy)

    # Enemy takes damage
    await await_signal(enemy.health_changed, 1000)
    assert_that(enemy.get_health()).is_less(initial_health)

    # Turn ends
    game.end_turn()

    # Enemy's turn - AI makes move
    await await_signal(game.turn_changed, 1000)
    assert_that(game.get_current_player()).is_equal(1)  # Enemy

func test_player_death_ends_game():
    player.take_damage(999)

    await await_signal(player.died, 1000)

    assert_that(game.is_game_over()).is_true()
    assert_that(game.get_winner()).is_equal(enemy)

func test_mana_replenishes_on_turn():
    game.play_card(game.get_hand()[0], enemy)
    var mana_after_play := player.get_mana()

    game.end_turn()
    await await_signal(game.turn_changed, 1000)

    game.end_turn()  # Back to player
    await await_signal(game.turn_changed, 1000)

    assert_that(player.get_mana()).is_greater(mana_after_play)
```

## Key Takeaways

1. **Scene integration**: Test scene instantiation and hierarchy
2. **Signal chains**: Verify signal propagation between objects
3. **Message systems**: Test bus-style communication
4. **Resource loading**: Verify resources load and configure correctly
5. **AutoLoad dependencies**: Test singleton integrations
6. **End-to-end flows**: Test complete user scenarios
7. **Async operations**: Use `await_signal` and `await_process_frame` for timing
8. **Cleanup**: Always queue_free nodes and wait for cleanup

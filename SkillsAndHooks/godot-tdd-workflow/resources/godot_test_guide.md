# Godot Testing Guide

Testing patterns specific to Godot 4.x engine features.

## AutoLoad Singletons

### Problem
AutoLoad singletons are global and persistent between tests.

### Solution: Mock Pattern

```gdscript
extends GdUnitTestSuite

var _original_message_server: MessageServer
var _original_tile_db: TileDatabase

func before():
    # Save original references
    _original_message_server = MessageServer
    _original_tile_db = TileDatabase

    # Replace with mocks
    MessageServer = MockMessageServer.new()
    TileDatabase = MockTileDatabase.new()

func after():
    # Restore original singletons
    MessageServer = _original_message_server
    TileDatabase = _original_tile_db

func test_message_sending():
    MessageServer.send("test_event", {})
    assert_that(MockMessageServer.message_count).is_equal(1)
```

### Mock Singleton Template

```gdscript
# test_doubles/mock_message_server.gd
class_name MockMessageServer

var message_count: int = 0
var last_message_type: StringName = ""
var last_message_data: Dictionary = {}

func send(type: StringName, data: Dictionary) -> void:
    message_count += 1
    last_message_type = type
    last_message_data = data

func clear() -> void:
    message_count = 0
    last_message_type = ""
    last_message_data = {}
```

---

## Resource Testing

### Load and Validate Resources

```gdscript
func test_load_tile_data_resource():
    var tile_data := load("res://Resources/tile_data.tres") as TileData

    assert_that(tile_data).is_not_null()
    assert_that(tile_data).is_instanceof(TileData)
    assert_that(tile_data.tile_types).has_size(9)  # 9 terrain types
```

### Test Resource Properties

```gdscript
func test_tile_resource_properties():
    var tile_data := load("res://Resources/tile_data.tres") as TileData

    assert_that(tile_data.get_defense_bonus(TileType.FOREST)).is_equal(2)
    assert_that(tile_data.get_movement_cost(TileType.MOUNTAIN)).is_equal(3)
```

### Test Resource Creation

```gdscript
func test_create_tile_resource():
    var tile_data := TileData.new()

    tile_data.set_defense_bonus(TileType.FOREST, 2)
    tile_data.set_movement_cost(TileType.MOUNTAIN, 3)

    var save_path := "user://test_tile_data.tres"
    var result := ResourceSaver.save(tile_data, save_path)

    assert_that(result).is_equal(OK)

    # Verify reload
    var loaded := load(save_path) as TileData
    assert_that(loaded.get_defense_bonus(TileType.FOREST)).is_equal(2)

    # Cleanup
    DirAccess.remove_absolute(save_path)
```

---

## Scene Testing

### Instantiate and Test Scene

```gdscript
func test_tile_scene_instantiation():
    var scene := load("res://Scenes/tile.tscn") as PackedScene

    assert_that(scene).is_not_null()
    assert_that(scene).is_instanceof(PackedScene)

    var instance := scene.instantiate()

    assert_that(instance).is_not_null()
    assert_that(instance).is_instanceof(Tile)
    assert_that(instance.has_signal("tile_clicked")).is_true()

    instance.queue_free()
```

### Test Scene Node Properties

```gdscript
func test_tile_scene_properties():
    var scene := load("res://Scenes/tile.tscn") as PackedScene
    var tile := scene.instantiate() as Tile

    # Test default values
    assert_that(tile.tile_type).is_equal(TileType.PLAINS)
    assert_that(tile.position).is_equal(Vector2.ZERO)

    # Test methods
    tile.set_tile_type(TileType.FOREST)
    assert_that(tile.tile_type).is_equal(TileType.FOREST)

    tile.queue_free()
```

### Test Scene Hierarchy

```gdscript
func test_scene_hierarchy():
    var tile_scene := load("res://Scenes/tile.tscn") as PackedScene
    var tile := tile_scene.instantiate()

    # Check child nodes exist
    var sprite := tile.get_node("Sprite2D")
    assert_that(sprite).is_not_null()

    var collision := tile.get_node("CollisionShape2D")
    assert_that(collision).is_not_null()

    tile.queue_free()
```

### Add Scene to Tree for Testing

```gdscript
var test_scene: Node2D

func before():
    test_scene = Node2D.new()
    get_tree().root.add_child(test_scene)

func after():
    test_scene.queue_free()

func test_tile_in_scene_tree():
    var tile_scene := load("res://Scenes/tile.tscn") as PackedScene
    var tile := tile_scene.instantiate()

    test_scene.add_child(tile)

    # Now tile can process and use tree features
    assert_that(tile.is_inside_tree()).is_true()
    assert_that(tile.get_tree()).is_not_null()
```

---

## Signal Testing

### Connect and Verify Signal

```gdscript
func test_signal_emission():
    var unit := Unit.new()
    var signal_received := false
    var received_data := null

    unit.health_changed.connect(func(amount): signal_received = true; received_data = amount)

    unit.take_damage(10)

    assert_that(signal_received).is_true()
    assert_that(received_data).is_equal(10)
```

### Test Signal Connection

```gdscript
func test_signal_connection():
    var tile := Tile.new()

    assert_that(tile.has_signal("tile_clicked")).is_true()
    assert_that(tile.get_signal_list().any(
        func(s): return s.name == "tile_clicked"
    )).is_true()
```

### Count Signal Emissions

```gdscript
func test_multiple_signal_emissions():
    var unit := Unit.new()
    var emission_count := 0

    unit.health_changed.connect(func(_amount): emission_count += 1)

    unit.take_damage(10)
    unit.take_damage(5)
    unit.take_damage(3)

    assert_that(emission_count).is_equal(3)
```

### Await Signal (Async)

```gdscript
func test_async_signal():
    var async_node := AsyncNode.new()

    async_node.start_async_work()

    await await_signal(async_node.work_completed, 2000)  # 2 second timeout

    assert_that(async_node.is_complete).is_true()
```

---

## Enum Type Safety Testing

### Test Enum Values

```gdscript
func test_tile_type_enum():
    assert_that(TileType.PLAINS).is_equal(0)
    assert_that(TileType.FOREST).is_equal(1)
    assert_that(TileType.MOUNTAIN).is_equal(2)

    # Test all enum values
    var type_count := TileType.keys().size()
    assert_that(type_count).is_equal(9)  # 9 terrain types
```

### Test Enum String Conversion

```gdscript
func test_enum_to_string():
    assert_that(TileType.keys()[TileType.FOREST]).is_equal("FOREST")
    assert_that(TileType.values().has(TileType.PLAINS)).is_true()
```

### Test Invalid Enum Handling

```gdscript
func test_invalid_enum_handling():
    var tile := Tile.new()

    # Should handle invalid enum gracefully
    var result := tile.set_type(-1)
    assert_that(result).is_equal(Error.ERR_INVALID_PARAMETER)
```

---

## Node Lifecycle Testing

### Test Ready Method

```gdscript
func test_node_ready():
    var tile := Tile.new()

    assert_that(tile.is_node_ready()).is_false()

    # Add to tree to trigger _ready
    var test_tree := Node.new()
    test_tree.add_child(tile)

    # Wait for ready
    await await_process_frame()

    assert_that(tile.is_node_ready()).is_true()

    test_tree.queue_free()
```

### Test Process Method

```gdscript
func test_process_delta():
    var node := ProcessingNode.new()
    node.process_mode = Node.PROCESS_MODE_ALWAYS

    var test_scene := Node.new()
    get_tree().root.add_child(test_scene)
    test_scene.add_child(node)

    assert_that(node.delta_sum).is_equal(0.0)

    # Wait for process frames
    await await_process_frame()
    await await_process_frame()

    assert_that(node.delta_sum).is_greater_than(0.0)

    test_scene.queue_free()
```

### Test Queue Free

```gdscript
func test_queue_free():
    var node := Node.new()
    var test_scene := Node.new()
    test_scene.add_child(node)

    node.queue_free()

    # Node still exists until frame ends
    assert_that(is_instance_valid(node)).is_true()

    await await_process_frame()

    # Node is now freed
    assert_that(is_instance_valid(node)).is_false()
```

---

## Physics Testing

### Test Movement

```gdscript
func test_physics_movement():
    var body := RigidBody2D.new()
    var test_scene := Node2D.new()

    get_tree().root.add_child(test_scene)
    test_scene.add_child(body)

    body.apply_central_force(Vector2(100, 0))

    # Wait for physics frame
    await await_physics_frame()

    assert_that(body.position.x).is_greater_than(0)

    test_scene.queue_free()
```

### Test Collision Detection

```gdscript
func test_collision_detection():
    var body_1 := Area2D.new()
    var body_2 := Area2D.new()

    var collision_shape := CollisionShape2D.new()
    collision_shape.shape = CircleShape2D.new()
    body_1.add_child(collision_shape)

    body_2.add_child(collision_shape.duplicate())

    var test_scene := Node.new()
    get_tree().root.add_child(test_scene)
    test_scene.add_child(body_1)
    test_scene.add_child(body_2)

    body_1.position = Vector2(0, 0)
    body_2.position = Vector2(10, 0)

    var collision_detected := false
    body_1.body_entered.connect(func(_body): collision_detected = true)

    # Move bodies into collision
    body_2.position = Vector2(0, 0)
    await await_physics_frame()

    assert_that(collision_detected).is_true()

    test_scene.queue_free()
```

---

## Input Testing

### Mock Input

```gdscript
func test_input_handling():
    var input_handler := InputHandler.new()

    # Mock input
    Input.action_press("ui_select")

    var result := input_handler.is_action_pressed("ui_select")
    assert_that(result).is_true()

    # Cleanup
    Input.action_release("ui_select")
```

### Test Input Map

```gdscript
func test_input_map_exists():
    assert_that(InputMap.has_action("ui_up")).is_true()
    assert_that(InputMap.has_action("ui_down")).is_true()

    var events := InputMap.action_get_events("ui_up")
    assert_that(events.is_empty()).is_false()
```

---

## File System Testing

### Test File Write

```gdscript
func test_file_write():
    var test_path := "user://test_data.json"
    var data := {"key": "value"}

    var file := FileAccess.open(test_path, FileAccess.WRITE)
    file.store_string(JSON.stringify(data))
    file.close()

    assert_that(FileAccess.file_exists(test_path)).is_true()

    # Cleanup
    DirAccess.remove_absolute(test_path)
```

### Test File Read

```gdscript
func test_file_read():
    var test_path := "user://test_read.json"
    var content := '{"test": "data"}'

    # Write test file
    var file := FileAccess.open(test_path, FileAccess.WRITE)
    file.store_string(content)
    file.close()

    # Read back
    var read_file := FileAccess.open(test_path, FileAccess.READ)
    var read_content := read_file.get_as_text()
    read_file.close()

    assert_that(read_content).is_equal(content)

    # Cleanup
    DirAccess.remove_absolute(test_path)
```

---

## Performance Testing

### Measure Execution Time

```gdscript
func test_performance():
    var algorithm := ExpensiveAlgorithm.new()

    var start_time := Time.get_ticks_usec()
    algorithm.process()
    var end_time := Time.get_ticks_usec()

    var elapsed_ms := (end_time - start_time) / 1000.0

    assert_that(elapsed_ms).is_less(100)  # Should complete in <100ms
```

### Memory Leak Detection

```gdscript
func test_no_memory_leak():
    var initial_objects := GC.get_object_count()

    for i in range(100):
        var obj := MyObject.new()
        obj.queue_free()

    # Force garbage collection
    GC.gc()

    var final_objects := GC.get_object_count()
    var leaked := final_objects - initial_objects

    assert_that(leaked).is_less(10)  # Allow some tolerance
```

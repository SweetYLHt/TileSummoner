# GdUnit4 API Reference

Complete reference for GdUnit4 testing framework in Godot 4.x.

## Basic Test Structure

```gdscript
extends GdUnitTestSuite

var test_instance: MyClass

func before():
    # Setup - runs before EACH test
    test_instance = MyClass.new()

func after():
    # Teardown - runs after EACH test
    test_instance.queue_free()

func test_example():
    assert_that(5).is_equal(5)
```

## Assertions

### Equality

```gdscript
# Exact equality
assert_that(actual).is_equal(expected)
assert_that(actual).is_not_equal(unexpected)

# Numeric comparison
assert_that(5).is_greater_than(3)
assert_that(3).is_less_than(5)
assert_that(5).is_greater_or_equal(5)
assert_that(5).is_less_or_equal(5)

# Float comparison with tolerance
assert_that(0.1 + 0.2).is_approx(0.3, 0.0001)
```

### Boolean

```gdscript
assert_that(condition).is_true()
assert_that(condition).is_false()
```

### Null Check

```gdscript
assert_that(value).is_null()
assert_that(value).is_not_null()
```

### Type Check

```gdscript
assert_that(value).is_instanceof(Node2D)
assert_that(value).is_not_instanceof(Node3D)
```

### String

```gdscript
assert_that(text).is_equal("expected")
assert_that(text).contains("substring")
assert_that(text).starts_with("prefix")
assert_that(text).ends_with("suffix")
assert_that(text).matches_regex(r"\d+")
assert_that(text).has_length(10)
```

### Array

```gdscript
var arr := [1, 2, 3]

assert_that(arr).is_equal([1, 2, 3])
assert_that(arr).contains(2)
assert_that(arr).not_contains(4)
assert_that(arr).is_empty()
assert_that(arr).has_size(3)
```

### Dictionary

```gdscript
var dict := {"key": "value", "count": 5}

assert_that(dict).has_key("key")
assert_that(dict).has_value("value")
assert_that(dict).has_size(2)
```

### Custom Failure Messages

```gdscript
assert_that(value).is_equal(expected,
    "Value should be %s but got %s" % [expected, value])
```

## Test Lifecycle

### Suite Level (runs once per test suite)

```gdscript
static func before_suite():
    # Setup before all tests in suite
    pass

static func after_suite():
    # Cleanup after all tests in suite
    pass
```

### Test Level (runs before/after EACH test)

```gdscript
func before():
    # Setup before each test
    pass

func after():
    # Cleanup after each test
    pass
```

### Execution Order

```
before_suite() → once
  before() → test_1() → after()
  before() → test_2() → after()
  before() → test_3() → after()
after_suite() → once
```

## Parameterized Tests

```gdscript
func test_with_parameters(p1, p2):
    assert_that(p1 + p2).is_equal(p2 + p1)

# Define test cases
func test_with_parameters__cases():
    return [
        [1, 2],
        [5, 10],
        [-1, 1],
    ]
```

## Async Testing

### Wait for Signal

```gdscript
func test_async_operation():
    var node := Node.new()
    var signal_emitted := false

    node.custom_signal.connect(func(): signal_emitted = true)

    # Do async work
    node.emit_signal_delayed(100)

    # Wait up to 1 second
    await await_signal(node.custom_signal, 1000)

    assert_that(signal_emitted).is_true()
```

### Wait for Condition

```gdscript
func test_wait_for_condition():
    var node := Node.new()
    node.start_work()

    # Wait up to 2 seconds for condition
    await await_condition(func(): return node.is_work_done(), 2000)

    assert_that(node.is_work_done()).is_true()
```

### Wait for Frame

```gdscript
func test_frame_delay():
    var node := Node.new()
    node.process_mode = Node.PROCESS_MODE_ALWAYS

    await await_frame_processed(5)  # Wait 5 frames

    assert_that(node.frame_count).is_equal(5)
```

## Mocking with GdUnit4

```gdscript
func test_mock_example():
    # Create mock
    var mock := mock(MyClass)

    # Setup return value
    do_return(42).on(mock, "get_value")

    # Verify method was called
    assert_that(mock.get_value()).is_equal(42)
    verify(mock, 1).get_value()

    # Verify never called
    verify(mock, 0).get_value()

    # Verify called at least N times
    verify(mock, times(2)).get_value()
```

## Testing Exceptions

```gdscript
func test_throws_error():
    assert_that(func(): invalid_operation()).throws_error()
```

## Timeouts

```gdscript
func test_with_timeout():
    # Test will fail if takes longer than 1 second
    await await_timeout(1000)
```

## Disabling Tests

```gdscript
func _failing_test():
    # Test name starting with _ is ignored
    pass

func test_disabled():
    skip_test("Not implemented yet")
    pass
```

## Test Categories/Tags

```gdscript
@Category("Unit")
@Category("Tile")
func test_tile_type():
    pass

@Category("Integration")
@Category("Message")
func test_message_routing():
    pass
```

## Common Patterns

### Test Resource Loading

```gdscript
func test_load_resource():
    var tile_data := load("res://Resources/tile_data.tres") as TileData
    assert_that(tile_data).is_not_null()
    assert_that(tile_data).is_instanceof(TileData)
```

### Test Scene Instantiation

```gdscript
func test_scene_instantiation():
    var scene := load("res://Scenes/tile.tscn") as PackedScene
    var instance := scene.instantiate()

    assert_that(instance).is_not_null()
    assert_that(instance).is_instanceof(Tile)

    instance.queue_free()
```

### Test AutoLoad Access

```gdscript
func test_autoload_access():
    # AutoLoad singletons are available in tests
    assert_that(MessageServer).is_not_null()
    assert_that(TileDatabase).is_not_null()
```

### Test Signal Emission

```gdscript
func test_signal_emission():
    var tile := Tile.new()
    var received_data := null

    tile.tile_clicked.connect(func(data): received_data = data)

    tile.simulate_click({"position": Vector2(5, 5)})

    assert_that(received_data).is_not_null()
    assert_that(received_data["position"]).is_equal(Vector2(5, 5))
```

## Best Practices

1. **One assertion per test** - Keep tests focused
2. **Descriptive test names** - `test_tile_defense_bonus_on_forest`
3. **Arrange-Act-Assert** - Clear test structure
4. **Test isolation** - Don't depend on test execution order
5. **Use setup/teardown** - Avoid code duplication
6. **Mock external dependencies** - Test only the unit under test
7. **Test edge cases** - Boundaries, null, empty collections

## Troubleshooting

### Test Not Found

Ensure test methods:
- Start with `test_`
- Are public (no `func _test_...`)
- Take no parameters (unless using parameterized tests)

### Timeouts

Increase timeout for async tests:
```gdscript
await await_signal(signal, 5000)  # 5 seconds
```

### Mock Issues

- Mock requires original class to have `class_name`
- Can't mock built-in Godot classes directly
- Use interface pattern for better mockability

### AutoLoad Errors

Replace AutoLoad in tests:
```gdscript
func before():
    # Save original
    _original_server = MessageServer
    # Replace with mock
    MessageServer = MockMessageServer.new()

func after():
    # Restore
    MessageServer = _original_server
```

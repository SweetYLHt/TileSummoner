---
name: godot-tdd-workflow
description: Test-driven development workflow for Godot 4.x GDScript with GdUnit4. Generate tests, run suites, validate coverage. Use when implementing features or refactoring.
version: 2.0
---

# Godot TDD Workflow

Test-driven development for Godot 4.x projects using GdUnit4 testing framework with **requirement-first planning** and **continuous validation**.

## Workflow Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Requirements   │ -> │    Planning     │ -> │  TDD Cycle      │
│  Gathering      │    │    & Design     │    │  (Red-Green)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
     Interview              Plan Mode           LSP + Lint
       Users                                    Validation
```

---

## Phase 1: Requirements Gathering (需求收集)

**BEFORE writing any code**, conduct user interview to gather requirements:

### Interview Checklist

Ask these questions systematically:

```yaml
Core Understanding:
  - What feature/fix is needed? Describe in one sentence.
  - What problem does this solve? Who is affected?
  - What is the expected behavior? Give examples.

User Scenarios:
  - Who are the users? (Players, developers, systems)
  - In what contexts will this be used?
  - What are common edge cases?

Success Criteria:
  - How do we know it's working? (Observable outcomes)
  - What are the performance requirements?
  - Are there constraints (memory, frame rate, file size)?

Integration Points:
  - What existing systems interact? (MessageServer, TileSystem, etc.)
  - What signals need to be emitted/received?
  - What resources (.tres, scenes) are involved?

Testing Strategy:
  - What test cases cover the happy path?
  - What are the critical failure modes?
  - How will we test AutoLoad/singletons?
```

### Example Interview Session

**User Request**: "Add tile rotation feature"

**AI Interview Questions**:
1. **Scope**: What does "tile rotation" mean? (Visual only? Data update? Both?)
2. **Trigger**: How does the user initiate rotation? (Click? Keyboard? Drag?)
3. **Data**: Does rotation affect gameplay mechanics? (Connectivity? Combat?)
4. **UI**: What visual feedback shows rotation? (Animation? Instant?)
5. **Testing**: What are the test cases for rotation? (Valid angles? Invalid input?)

---

## Phase 2: Planning Mode (计划模式)

### Enter Plan Mode When

- **New feature implementation** with multiple valid approaches
- **Multi-file changes** affecting existing systems
- **Architectural decisions** (pattern selection, data structure)
- **Complex requirements** requiring exploration

### Planning Steps

1. **Explore codebase** using MCP tools:
   ```
   - Godot MCP: get_project_info, list_projects
   - Serena MCP: symbol search, code navigation
   - Read: existing implementations, test files
   ```

2. **Design the approach**:
   ```yaml
   Architecture:
     - What pattern? (Factory, Observer, State Machine)
     - What classes/files to create/modify?
     - How does it integrate with existing code?

   Test Strategy:
     - What test suite? (unit, integration, visual test)
     - How to test dependencies? (mock, stub, fake)
     - What coverage target? (80%+ recommended)

   Validation:
     - LSP check: syntax, type safety, symbols
     - Lint check: style, best practices
     - GdUnit4: all tests passing
   ```

3. **Write implementation plan** to `Docs/next-steps/plan-{feature}.md`:
   ```markdown
   # Feature: Tile Rotation

   ## Requirements Summary
   - Rotate tiles 90° increments
   - Update connectivity graph
   - Emit rotation_complete signal

   ## Implementation Steps
   1. Create `tile_rotator.gd` with rotation logic
   2. Add `tile_rotated` signal to Tile class
   3. Update connectivity algorithm
   4. Create test suite `test_tile_rotator.gd`

   ## Validation Checklist
   - [ ] LSP validation passes
   - [ ] Lint check passes
   - [ ] All tests passing
   - [ ] Coverage >= 80%
   ```

4. **Present plan to user** for approval

5. **Only after approval**, exit plan mode and implement

---

## Phase 3: TDD Cycle (测试驱动开发)

After plan approval, follow Red-Green-Refactor with continuous validation:

### 3.1 Red Phase (Write Failing Test)

**Generate test stub**:
```bash
scripts/generate_test_stub.py Scripts/tile/tile_rotator.gd
```

**Write failing test**:
```gdscript
func test_rotate_clockwise_90_degrees():
    var rotator := TileRotator.new()
    var tile := Tile.new(TileType.FOREST)
    tile.rotation_degrees = 0

    rotator.rotate_clockwise(tile)

    assert_that(tile.rotation_degrees).is_equal(90)
    assert_signal(tile, "tile_rotated").is_emit_count(1)
```

**Validate test code** with LSP:
```
- Check syntax
- Verify symbol resolution
- Validate type annotations
```

### 3.2 Green Phase (Make Test Pass)

**Write minimal implementation**:
```gdscript
class_name TileRotator
extends Node

signal rotation_completed(tile: Tile)

func rotate_clockwise(tile: Tile) -> void:
    tile.rotation_degrees = (tile.rotation_degrees + 90) % 360
    tile.tile_rotated.emit()
    rotation_completed.emit(tile)
```

**Validate implementation** with LSP + Lint:
```
LSP Check:
  - Syntax errors: NONE
  - Type annotations: Valid
  - Symbol resolution: Complete
  - AutoLoad dependencies: Resolved

Lint Check:
  - Naming conventions: snake_case
  - Type hints: Present
  - Docstrings: Added if needed
  - No unused variables
```

**Run test**:
```bash
scripts/run_quick_test.py test_suites/test_tile_rotator.gd
```

### 3.3 Refactor Phase (Improve Code)

**Refactor while tests stay green**:
```gdscript
# Extract common rotation logic
func _rotate_tile(tile: Tile, degrees: int) -> void:
    tile.rotation_degrees = (tile.rotation_degrees + degrees) % 360
    tile.tile_rotated.emit()
```

**Validate refactored code** (LSP + Lint + Tests):
```bash
# LSP validation
godot-lsp validate Scripts/tile/tile_rotator.gd

# Lint check
scripts/check_lint.py Scripts/tile/tile_rotator.gd

# Run tests
scripts/run_quick_test.py test_suites/test_tile_rotator.gd
```

---

## Phase 4: Continuous Validation (持续验证)

### Validation Pipeline

**Every code change must pass**:

```bash
# 1. LSP Syntax & Type Check
godot-lsp validate <file>

# 2. Lint Style & Best Practices
scripts/check_lint.py <file>

# 3. Run Tests
scripts/run_quick_test.py <test_file>

# 4. Coverage Report
scripts/check_coverage.py --threshold 80
```

### Using Godot MCP for Validation

```yaml
Syntax Check:
  tool: godot_lsp_file
  purpose: Syntax validation, type checking, symbol resolution

Code Quality:
  tool: godot_lint_file
  purpose: Style checks, best practices, anti-patterns

Test Execution:
  tool: godot_run_test_file
  purpose: Run specific test suite

Coverage Analysis:
  tool: godot_get_test_coverage
  purpose: Ensure adequate test coverage
```

---

## Common Scenarios

### Scenario 1: New Feature with Dependencies

**Flow**:
1. **Interview user** about requirements
2. **Enter plan mode** to explore dependencies
3. **Identify AutoLoad dependencies** (MessageServer, etc.)
4. **Design mock strategy** for tests
5. **Write implementation plan**
6. **Generate test stub** for each file
7. **Write tests** with mocks
8. **Implement** feature
9. **Validate** with LSP + Lint + Tests
10. **Check coverage** meets threshold

### Scenario 2: Refactoring Existing Code

**Flow**:
1. **Interview user** about refactoring goals
2. **Enter plan mode** to analyze current code
3. **Identify test gaps** in current coverage
4. **Write tests** for existing behavior (characterization tests)
5. **Refactor** incrementally
6. **Validate** after each change (LSP + Lint + Tests)
7. **Ensure coverage** doesn't decrease

### Scenario 3: Bug Fix

**Flow**:
1. **Interview user** about bug symptoms
2. **Enter plan mode** to locate bug
3. **Write failing test** reproducing bug
4. **Fix bug** with minimal change
5. **Validate** fix (LSP + Lint + Tests pass)
6. **Add regression tests** for similar bugs

---

## Testing Patterns Reference

### Testing AutoLoad Singletons

```gdscript
func before():
    # Mock MessageServer
    MessageServer = MockMessageServer.new() auto_free.free

func after():
    # Restore real MessageServer
    MessageServer = get_node("/root/MessageServer")
```

### Testing Resources (.tres)

```gdscript
func test_load_tile_data():
    var data := load("res://Resources/tile_data.tres") as TileData
    assert_that(data).is_not_null()
    assert_that(data.terrain_types).is_not_empty()
```

### Testing Signals

```gdscript
func test_tile_clicked_signal():
    var tile := Tile.new() auto_free.free
    var signal_fired := false

    tile.tile_clicked.connect(func(): signal_fired = true)
    tile.simulate_click()

    assert_that(signal_fired).is_true()
```

### Parameterized Tests

```gdscript
func test_rotation_for_all_angles():
    var test_cases := [
        {angle = 0, expected = 90},
        {angle = 90, expected = 180},
        {angle = 270, expected = 0},
    ]

    for case in test_cases:
        var tile := Tile.new()
        tile.rotation_degrees = case.angle
        _rotator.rotate_clockwise(tile)
        assert_that(tile.rotation_degrees).is_equal(case.expected)
```

---

## Quick Reference

### Command Summary

```bash
# Requirements & Planning
# (No commands - use interview questions)

# Test Generation
scripts/generate_test_stub.py <path_to_script>

# Testing
scripts/run_quick_test.py <test_file>           # Single file
scripts/run_all_tests.py                        # Full suite

# Validation
godot-lsp validate <file>                       # LSP check
scripts/check_lint.py <file>                    # Lint check
scripts/check_coverage.py --threshold 80        # Coverage

# Godot MCP Tools
godot_run_tests                                 # Full suite
godot_run_test_file <file>                      # Single file
godot_get_test_coverage                         # Coverage report
godot_lint_file <file>                          # Code quality
godot_analyze_dependencies <file>               # Dependencies
```

### MCP Tool Integration

```yaml
Planning Phase:
  - godot_get_project_info: Understand project structure
  - godot_list_projects: Find related projects
  - Serena MCP: Symbol search, code navigation

Implementation Phase:
  - godot_lsp_file: Validate syntax & types
  - godot_lint_file: Check code quality
  - godot_run_test_file: Run tests
  - godot_get_test_coverage: Verify coverage
```

---

## Advanced Guides

See detailed guides:
- [patterns.md](./resources/patterns.md) - AAA, Test Doubles, parameterized tests
- [gdunit4_api.md](./resources/gdunit4_api.md) - Complete API reference
- [godot_test_guide.md](./resources/godot_test_guide.md) - AutoLoad, scene, signal testing
- [examples/](./resources/examples/) - Working code examples

---

## Best Practices

1. **Never skip requirements gathering** - Always interview user first
2. **Plan before implementing** - Use plan mode for non-trivial tasks
3. **Validate continuously** - LSP → Lint → Tests → Coverage
4. **Keep tests green** - Never commit failing tests
5. **Maintain coverage** - Aim for 80%+ coverage
6. **Mock dependencies** - Use test doubles for AutoLoad, external services
7. **Test signals** - Verify signal emission and handling
8. **Document edge cases** - Add tests for boundary conditions

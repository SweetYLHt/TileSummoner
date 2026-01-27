# Scripts Reference

Helper scripts for Godot TDD workflow automation.

## generate_test_stub.py

Generate GdUnit4 test skeleton from GDScript source.

```bash
python generate_test_stub.py Scripts/tile/tile_database.gd test_suites
```

**Features:**
- Extracts class_name and extends
- Finds public methods (skips private `_` methods)
- Generates test methods with templates
- Auto-creates output directory

**Output:** `test_suites/test_<classname>.gd`

## run_quick_test.py

Run single test file with formatted output.

```bash
python run_quick_test.py test_suites/test_tile_database.gd
python run_quick_test.py test_suites/test_tile_database.gd --verbose
```

**Features:**
- Finds Godot executable automatically
- Locates project root via project.godot
- Parses GdUnit4 output
- Shows pass/fail summary
- Lists failed tests

**Exit codes:** 0 (all pass), 1 (any fail)

## check_coverage.py

Validate test coverage threshold.

```bash
python check_coverage.py --threshold 80
python check_coverage.py --threshold 75 --output json
```

**Features:**
- Finds coverage.json automatically
- Parses line-by-line coverage
- Shows file-by-file breakdown
- Sorts by lowest coverage
- Lists files needing attention

**Exit codes:** 0 (meets threshold), 1 (below threshold)

## Requirements

- Python 3.7+
- Godot 4.x
- GdUnit4 plugin installed

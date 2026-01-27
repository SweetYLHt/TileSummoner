# Godot TDD Workflow

Test-driven development workflow for Godot 4.x GDScript projects with GdUnit4 integration, featuring **requirement-first planning** and **continuous validation**.

## About

This skill provides a complete TDD workflow for Godot projects with four key phases:

1. **Requirements Gathering** - Interview users to capture needs and use cases
2. **Planning Mode** - Design architecture and create implementation plans
3. **TDD Cycle** - Red-Green-Refactor with continuous validation
4. **Continuous Validation** - LSP syntax check, Lint style check, Test execution, Coverage analysis

### Key Features

- Generate test scaffolds from GDScript files
- Run individual test files with formatted output
- Validate test coverage thresholds (80%+ recommended)
- **Requirements interview checklist** for capturing user needs
- **Plan-driven development** for complex features
- **LSP + Lint integration** for code quality validation
- Comprehensive documentation on testing patterns

## Quick Start

```bash
# Generate test skeleton from source
python scripts/generate_test_stub.py Scripts/tile/tile_database.gd

# Run specific test file
python scripts/run_quick_test.py test_suites/test_tile_database.gd

# Check coverage
python scripts/check_coverage.py --threshold 80

# LSP validation
godot-lsp validate Scripts/tile/tile_database.gd

# Lint check
python scripts/check_lint.py Scripts/tile/tile_database.gd
```

## Workflow

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Requirements   │ -> │    Planning     │ -> │  TDD Cycle      │
│  Gathering      │    │    & Design     │    │  (Red-Green)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
     Interview              Plan Mode           LSP + Lint
       Users                                    Validation
```

### Phase 1: Requirements Gathering

Before writing code, conduct user interviews using the checklist in SKILL.md:
- Core understanding (What? Why? How?)
- User scenarios (Who? When? Where?)
- Success criteria (Observable outcomes)
- Integration points (Existing systems, signals, resources)
- Testing strategy (Test cases, failure modes)

### Phase 2: Planning Mode

Enter plan mode when:
- Implementing new features with multiple approaches
- Making multi-file changes affecting existing systems
- Making architectural decisions
- Dealing with complex requirements

Planning steps:
1. Explore codebase using Godot MCP and Serena MCP
2. Design architecture and test strategy
3. Write implementation plan to `Docs/next-steps/plan-{feature}.md`
4. Present plan to user for approval
5. Implement only after approval

### Phase 3: TDD Cycle

Follow Red-Green-Refactor with validation at each step:

**Red Phase**:
- Generate test stub
- Write failing test
- Validate test code with LSP

**Green Phase**:
- Write minimal implementation
- Validate with LSP + Lint
- Run tests

**Refactor Phase**:
- Improve code while tests stay green
- Validate with LSP + Lint + Tests

### Phase 4: Continuous Validation

Every code change must pass:
1. LSP syntax & type check
2. Lint style & best practices check
3. Test execution (all tests passing)
4. Coverage analysis (80%+ threshold)

## Requirements

- Godot 4.x
- GdUnit4 plugin installed
- Python 3.7+
- Godot LSP (for syntax validation)

## Documentation

- **SKILL.md** - Complete workflow with four phases
- **resources/patterns.md** - TDD patterns (AAA, Test Doubles, Red-Green-Refactor)
- **resources/gdunit4_api.md** - Complete GdUnit4 API reference
- **resources/godot_test_guide.md** - Godot-specific testing patterns
- **resources/examples/** - Working code examples

## Best Practices

1. **Never skip requirements gathering** - Always interview user first
2. **Plan before implementing** - Use plan mode for non-trivial tasks
3. **Validate continuously** - LSP → Lint → Tests → Coverage
4. **Keep tests green** - Never commit failing tests
5. **Maintain coverage** - Aim for 80%+ coverage
6. **Mock dependencies** - Use test doubles for AutoLoad, external services
7. **Test signals** - Verify signal emission and handling
8. **Document edge cases** - Add tests for boundary conditions

## License

MIT License - See LICENSE.txt for details.

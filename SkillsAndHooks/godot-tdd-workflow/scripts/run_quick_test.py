#!/usr/bin/env python3
"""
Quick test runner for single test file.

Usage:
    python run_quick_test.py <test_file> [--verbose]

Example:
    python run_quick_test.py test_suites/test_tile_database.gd
"""

import subprocess
import sys
import os
import re
from pathlib import Path


def find_godot_executable():
    """Find Godot executable in common locations."""
    possible_paths = [
        r"C:\Program Files\Godot\Godot_v4.5.1-stable_win64.exe",
        r"C:\Program Files\Godot\Godot_v4.5-stable_win64.exe",
        r"C:\Godot\Godot_v4.5.1-stable_win64.exe",
    ]

    for path in possible_paths:
        if os.path.exists(path):
            return path

    # Check PATH
    for path in os.environ.get('PATH', '').split(os.pathsep):
        godot_path = os.path.join(path, 'godot.exe')
        if os.path.exists(godot_path):
            return godot_path

    return None


def parse_test_results(output):
    """Parse GdUnit4 test output and extract results."""
    results = {
        'total': 0,
        'passed': 0,
        'failed': 0,
        'skipped': 0,
        'errors': 0,
        'tests': []
    }

    # Parse test counts
    match = re.search(r'Tests:\s+(\d+)', output, re.IGNORECASE)
    if match:
        results['total'] = int(match.group(1))

    # Parse passed/failed
    match = re.search(r'Passed:\s+(\d+)', output, re.IGNORECASE)
    if match:
        results['passed'] = int(match.group(1))

    match = re.search(r'Failed:\s+(\d+)', output, re.IGNORECASE)
    if match:
        results['failed'] = int(match.group(1))

    match = re.search(r'Skipped:\s+(\d+)', output, re.IGNORECASE)
    if match:
        results['skipped'] = int(match.group(1))

    match = re.search(r'Errors:\s+(\d+)', output, re.IGNORECASE)
    if match:
        results['errors'] = int(match.group(1))

    # Extract individual test results
    test_pattern = r'\[TEST\]\s+(\w+)\s+-\s+(\w+)::(\w+)\(\)\s+-\s+(\w+)'
    for match in re.finditer(test_pattern, output):
        results['tests'].append({
            'status': match.group(1),
            'suite': match.group(2),
            'test': match.group(3),
            'result': match.group(4)
        })

    return results


def run_test_file(test_file, verbose=False):
    """Run a specific test file using GdUnit4."""
    # Find Godot executable
    godot = find_godot_executable()
    if not godot:
        print("Error: Godot executable not found")
        print("Please ensure Godot 4.x is installed")
        sys.exit(1)

    # Find project root (look for project.godot)
    current_dir = Path.cwd()
    project_root = current_dir
    for parent in [current_dir] + list(current_dir.parents):
        if (parent / 'project.godot').exists():
            project_root = parent
            break

    # Resolve test file path
    test_path = Path(test_file)
    if not test_path.is_absolute():
        test_path = project_root / test_file

    if not test_path.exists():
        print(f"Error: Test file '{test_path}' not found")
        sys.exit(1)

    # Convert to res:// path
    test_res_path = f"res://{test_path.relative_to(project_root).as_posix()}"

    print(f"Running: {test_res_path}")
    print(f"Project: {project_root}")
    print(f"Godot: {godot}")
    print("-" * 60)

    # Build command
    cmd = [
        godot,
        '--path', str(project_root),
        '--headless',
        '--run-tests',
        test_res_path
    ]

    # Run test
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=120  # 2 minute timeout
        )

        output = result.stdout + result.stderr

        if verbose:
            print(output)

        # Parse and display results
        parsed = parse_test_results(output)
        print("\n" + "=" * 60)
        print("TEST RESULTS")
        print("=" * 60)
        print(f"Total:  {parsed['total']}")
        print(f"Passed: {parsed['passed']} ✓")
        print(f"Failed: {parsed['failed']} ✗")
        print(f"Skipped: {parsed['skipped']} -")
        if parsed['errors'] > 0:
            print(f"Errors: {parsed['errors']} !")
        print("=" * 60)

        # Show failed tests
        if parsed['failed'] > 0:
            print("\nFailed tests:")
            for test in parsed['tests']:
                if test['result'] in ['FAILED', 'ERROR']:
                    print(f"  - {test['suite']}::{test['test']}")

        return 0 if parsed['failed'] == 0 and parsed['errors'] == 0 else 1

    except subprocess.TimeoutExpired:
        print("Error: Test execution timed out (120s)")
        return 1
    except Exception as e:
        print(f"Error running tests: {e}")
        return 1


def main():
    if len(sys.argv) < 2:
        print("Usage: python run_quick_test.py <test_file> [--verbose]")
        sys.exit(1)

    test_file = sys.argv[1]
    verbose = '--verbose' in sys.argv or '-v' in sys.argv

    exit_code = run_test_file(test_file, verbose)
    sys.exit(exit_code)


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""
Generate GdUnit4 test stub from GDScript source.

Usage:
    python generate_test_stub.py <source_file> [output_dir]

Example:
    python generate_test_stub.py Scripts/tile/tile_database.gd test_suites
"""

import re
import sys
import os
from pathlib import Path


def parse_gdscript(filepath):
    """Parse GDScript file and extract class info."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Extract class_name
    class_name_match = re.search(r'class_name\s+(\w+)', content)
    class_name = class_name_match.group(1) if class_name_match else None

    # Extract extends
    extends_match = re.search(r'extends\s+(\w+)', content)
    extends = extends_match.group(1) if extends_match else 'RefCounted'

    # Extract public methods
    methods = []
    method_pattern = r'func\s+(\w+)\s*\(([^)]*)\)'
    for match in re.finditer(method_pattern, content):
        method_name = match.group(1)
        # Skip private methods and test methods
        if not method_name.startswith('_') and not method_name.startswith('test_'):
            methods.append({
                'name': method_name,
                'params': match.group(2).strip() if match.group(2).strip() else ''
            })

    return {
        'class_name': class_name,
        'extends': extends,
        'methods': methods,
        'source_file': filepath
    }


def generate_test_suite(parsed):
    """Generate GdUnit4 test suite content."""
    class_name = parsed['class_name'] or Path(parsed['source_file']).stem
    test_class_name = f"Test{class_name}"

    lines = [
        '# Auto-generated test suite',
        '# Source: ' + parsed['source_file'],
        'extends GdUnitTestSuite',
        '',
    ]

    # Add before/after hooks
    lines.append('# Setup/Teardown')
    lines.append('func before():')
    lines.append('\t# Setup test environment')
    lines.append('\tpass')
    lines.append('')
    lines.append('func after():')
    lines.append('\t# Cleanup after tests')
    lines.append('\tpass')
    lines.append('')
    lines.append('')

    # Generate test methods
    lines.append('# Test Methods')
    for method in parsed['methods']:
        lines.append(f'func test_{method["name"]}():')
        lines.append(f'\t# TODO: Implement test for {method["name"]}()')

        # Add template based on method signature
        if not method['params']:
            lines.append(f'\tvar instance := {class_name}.new()')
            lines.append(f'\tvar result := instance.{method["name"]}()')
            lines.append(f'\tassert_that(result).is_not_null()')
        else:
            params = [p.strip().split(':')[0].split('=')[0].strip()
                     for p in method['params'].split(',') if p.strip()]
            if params:
                param_str = ', '.join([f'# {p}' for p in params])
                lines.append(f'\tvar instance := {class_name}.new()')
                lines.append(f'\t# var result := instance.{method["name"]}({param_str})')
                lines.append(f'\tassert_that(false).is_true()  # TODO: Implement')

        lines.append('')
        lines.append('')

    return '\n'.join(lines)


def main():
    if len(sys.argv) < 2:
        print("Usage: python generate_test_stub.py <source_file> [output_dir]")
        sys.exit(1)

    source_file = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) > 2 else 'test_suites'

    if not os.path.exists(source_file):
        print(f"Error: Source file '{source_file}' not found")
        sys.exit(1)

    # Create output directory
    os.makedirs(output_dir, exist_ok=True)

    # Parse source file
    parsed = parse_gdscript(source_file)
    class_name = parsed['class_name'] or Path(source_file).stem

    # Generate test content
    test_content = generate_test_suite(parsed)

    # Write test file
    output_file = os.path.join(output_dir, f'test_{class_name.to_lower()}.gd')
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(test_content)

    print(f"✓ Generated test suite: {output_file}")
    print(f"  Methods found: {len(parsed['methods'])}")
    for method in parsed['methods']:
        print(f"    - test_{method['name']}()")


if __name__ == '__main__':
    main()

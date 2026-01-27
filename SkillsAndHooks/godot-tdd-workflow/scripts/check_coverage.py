#!/usr/bin/env python3
"""
Validate test coverage threshold.

Usage:
    python check_coverage.py [--threshold PERCENT] [--output FORMAT]

Example:
    python check_coverage.py --threshold 80
    python check_coverage.py --threshold 75 --output json
"""

import sys
import os
import json
import re
from pathlib import Path


def find_coverage_file(project_root):
    """Find GdUnit4 coverage report file."""
    possible_paths = [
        project_root / 'coverage.json',
        project_root / 'reports' / 'coverage.json',
        project_root / '.gdunit4' / 'coverage' / 'coverage.json',
    ]

    for path in possible_paths:
        if path.exists():
            return path

    return None


def parse_coverage_report(coverage_path):
    """Parse coverage report and extract metrics."""
    with open(coverage_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    results = {
        'total_files': 0,
        'covered_files': 0,
        'total_lines': 0,
        'covered_lines': 0,
        'coverage_percent': 0.0,
        'files': []
    }

    # GdUnit4 format
    if 'files' in data:
        for file_data in data['files']:
            file_path = file_data.get('path', file_data.get('file', ''))
            if not file_path:
                continue

            total_lines = file_data.get('total_lines', 0)
            covered_lines = file_data.get('covered_lines', 0)
            coverage_percent = (covered_lines / total_lines * 100) if total_lines > 0 else 0

            results['files'].append({
                'path': file_path,
                'total_lines': total_lines,
                'covered_lines': covered_lines,
                'coverage_percent': coverage_percent
            })

            results['total_files'] += 1
            results['total_lines'] += total_lines
            results['covered_lines'] += covered_lines

            if coverage_percent > 0:
                results['covered_files'] += 1

    # Calculate overall coverage
    if results['total_lines'] > 0:
        results['coverage_percent'] = (results['covered_lines'] / results['total_lines']) * 100

    return results


def format_coverage_report(results, threshold):
    """Generate formatted coverage report."""
    lines = []
    lines.append("=" * 70)
    lines.append("COVERAGE REPORT")
    lines.append("=" * 70)
    lines.append(f"Overall Coverage: {results['coverage_percent']:.2f}%")
    lines.append(f"Threshold:        {threshold}%")
    lines.append("")
    lines.append(f"Files:            {results['covered_files']}/{results['total_files']}")
    lines.append(f"Lines:            {results['covered_lines']}/{results['total_lines']}")
    lines.append("")

    # Pass/Fail indicator
    if results['coverage_percent'] >= threshold:
        lines.append(f"✓ PASSED - Coverage meets threshold ({results['coverage_percent']:.2f}% >= {threshold}%)")
    else:
        lines.append(f"✗ FAILED - Coverage below threshold ({results['coverage_percent']:.2f}% < {threshold}%)")

    lines.append("")

    # File breakdown
    if results['files']:
        lines.append("-" * 70)
        lines.append("File Breakdown:")
        lines.append("-" * 70)

        # Sort by coverage (lowest first)
        sorted_files = sorted(results['files'], key=lambda x: x['coverage_percent'])

        for file_data in sorted_files:
            name = Path(file_data['path']).name
            coverage = file_data['coverage_percent']
            status = "✓" if coverage >= threshold else "✗"
            lines.append(f"{status} {name:40s} {coverage:6.2f}% ({file_data['covered_lines']}/{file_data['total_lines']} lines)")

    lines.append("=" * 70)

    return "\n".join(lines)


def generate_untested_files_list(results):
    """Generate list of files with low or zero coverage."""
    untested = []

    for file_data in results['files']:
        if file_data['coverage_percent'] < 50:
            untested.append({
                'path': file_data['path'],
                'coverage': file_data['coverage_percent']
            })

    return untested


def main():
    # Parse arguments
    threshold = 80
    output_format = 'text'

    args = sys.argv[1:]
    i = 0
    while i < len(args):
        if args[i] == '--threshold' and i + 1 < len(args):
            threshold = float(args[i + 1])
            i += 2
        elif args[i] == '--output' and i + 1 < len(args):
            output_format = args[i + 1]
            i += 2
        else:
            i += 1

    # Find project root
    current_dir = Path.cwd()
    project_root = current_dir
    for parent in [current_dir] + list(current_dir.parents):
        if (parent / 'project.godot').exists():
            project_root = parent
            break

    # Find coverage file
    coverage_path = find_coverage_file(project_root)
    if not coverage_path:
        print("Warning: Coverage report not found")
        print("Run tests with coverage first:")
        print("  godot --headless --run-tests --coverage")
        sys.exit(1)

    # Parse coverage
    results = parse_coverage_report(coverage_path)

    # Generate output
    if output_format == 'json':
        print(json.dumps(results, indent=2))
    else:
        print(format_coverage_report(results, threshold))

        # Show untested files if below threshold
        if results['coverage_percent'] < threshold:
            untested = generate_untested_files_list(results)
            if untested:
                print("\nFiles needing attention:")
                for file in untested:
                    print(f"  - {file['path']} ({file['coverage']:.1f}%)")

    # Exit with error if below threshold
    sys.exit(0 if results['coverage_percent'] >= threshold else 1)


if __name__ == '__main__':
    main()

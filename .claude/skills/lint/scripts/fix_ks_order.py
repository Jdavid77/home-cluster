#!/usr/bin/env python3
"""One-off script to fix ks.yaml spec property order across all app files."""
import os
import re
import sys

CANONICAL_SPEC_ORDER = [
    "targetNamespace", "dependsOn", "path", "prune", "sourceRef",
    "healthChecks", "healthCheckExprs", "components", "postBuild",
    "wait", "interval", "retryInterval", "timeout",
]

SPEC_KEY_RE = re.compile(r'^  (\w+):')


def reorder_spec_in_lines(lines):
    spec_line_idx = None
    for i, line in enumerate(lines):
        if line.rstrip('\n').rstrip() == 'spec:':
            spec_line_idx = i
            break
    if spec_line_idx is None:
        return lines

    spec_props = []
    current_key = None
    current_prop_lines = []
    i = spec_line_idx + 1

    while i < len(lines):
        line = lines[i]
        stripped = line.rstrip('\n')
        if stripped and not stripped.startswith(' '):
            break
        m = SPEC_KEY_RE.match(stripped)
        if m:
            if current_key is not None:
                spec_props.append((current_key, current_prop_lines))
            current_key = m.group(1)
            current_prop_lines = [line]
        elif current_key is not None:
            current_prop_lines.append(line)
        i += 1

    if current_key is not None:
        spec_props.append((current_key, current_prop_lines))

    end_of_spec = i
    key_order = {k: idx for idx, k in enumerate(CANONICAL_SPEC_ORDER)}
    reordered = sorted(spec_props, key=lambda p: key_order.get(p[0], len(CANONICAL_SPEC_ORDER)))

    result = lines[:spec_line_idx + 1]
    for _, prop_lines in reordered:
        result.extend(prop_lines)
    result.extend(lines[end_of_spec:])
    return result


def fix_file(filepath):
    with open(filepath, encoding='utf-8') as f:
        content = f.read()

    # Split into per-document line lists, preserving --- separators
    segments = []
    current_lines = []
    for line in content.splitlines(keepends=True):
        if line.rstrip('\n') == '---':
            segments.append(current_lines)
            current_lines = []
        else:
            current_lines.append(line)
    segments.append(current_lines)

    fixed_segments = [reorder_spec_in_lines(seg) for seg in segments]
    result = '---\n'.join(''.join(seg) for seg in fixed_segments)

    if result != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(result)
        return True
    return False


if __name__ == '__main__':
    fixed = []
    for dirpath, _, filenames in os.walk('k8s/apps/'):
        for filename in sorted(filenames):
            if filename != 'ks.yaml':
                continue
            filepath = os.path.join(dirpath, filename)
            if fix_file(filepath):
                fixed.append(filepath)

    if fixed:
        print(f"Fixed {len(fixed)} file(s):")
        for f in fixed:
            print(f"  {f}")
    else:
        print("Nothing to fix.")

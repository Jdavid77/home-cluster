#!/usr/bin/env python3
"""Bulk-fix helm-release.yaml values property order for app-template releases."""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))
from checks.hr_order import CANONICAL_VALUES_ORDER, CANONICAL_CONTROLLER_ORDER, CANONICAL_CONTAINER_ORDER

_KEY_RE = re.compile(r'(\w[\w-]*):')


def _get_children_and_end(lines, parent_line, parent_indent):
    """Return ([(key, line_idx)], block_end) for direct children at parent_indent+2."""
    child_indent = parent_indent + 2
    children = []
    block_end = len(lines)

    for i in range(parent_line + 1, len(lines)):
        s = lines[i].rstrip('\n')
        stripped = s.lstrip()
        if not stripped or stripped.startswith('#'):
            continue
        current_indent = len(s) - len(stripped)
        if current_indent <= parent_indent:
            block_end = i
            break
        if current_indent == child_indent:
            m = _KEY_RE.match(stripped)
            if m:
                children.append((m.group(1), i))

    return children, block_end


def _reorder_children(lines, parent_line, parent_indent, canonical):
    """Reorder direct children of block at parent_line in-place. Returns True if changed."""
    children, block_end = _get_children_and_end(lines, parent_line, parent_indent)
    if not children:
        return False

    block_start = children[0][1]

    child_blocks = []
    for idx, (key, start) in enumerate(children):
        end = children[idx + 1][1] if idx + 1 < len(children) else block_end
        child_blocks.append((key, lines[start:end]))

    actual = [k for k, _ in child_blocks if k in canonical]
    expected = [k for k in canonical if k in actual]
    if actual == expected:
        return False

    key_pos = {k: i for i, k in enumerate(canonical)}
    child_blocks.sort(key=lambda b: key_pos.get(b[0], len(canonical)))

    lines[block_start:block_end] = [line for _, block in child_blocks for line in block]
    return True


def _find_line(lines, key, indent, start=0):
    pattern = re.compile(r'^' + ' ' * indent + re.escape(key) + r':')
    for i in range(start, len(lines)):
        if pattern.match(lines[i].rstrip('\n')):
            return i
    return -1


def fix_file(filepath):
    with open(filepath, encoding='utf-8') as f:
        content = f.read()

    if "name: app-template" not in content:
        return False

    lines = content.splitlines(keepends=True)
    changed = False

    values_line = _find_line(lines, 'values', 2)
    if values_line == -1:
        return False

    controllers_line = _find_line(lines, 'controllers', 4, values_line)
    if controllers_line != -1:
        ctrl_children, _ = _get_children_and_end(lines, controllers_line, 4)

        # Pass 1 (innermost): reorder container keys
        for _, ctrl_line in ctrl_children:
            ctrl_keys, _ = _get_children_and_end(lines, ctrl_line, 6)
            containers_line = next((li for k, li in ctrl_keys if k == 'containers'), -1)
            if containers_line != -1:
                for _, ctr_line in _get_children_and_end(lines, containers_line, 8)[0]:
                    if _reorder_children(lines, ctr_line, 10, CANONICAL_CONTAINER_ORDER):
                        changed = True

        # Pass 2: reorder controller keys
        for _, ctrl_line in ctrl_children:
            if _reorder_children(lines, ctrl_line, 6, CANONICAL_CONTROLLER_ORDER):
                changed = True

    # Pass 3 (outermost): reorder values keys
    if _reorder_children(lines, values_line, 2, CANONICAL_VALUES_ORDER):
        changed = True

    if changed:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(''.join(lines))
        return True
    return False


if __name__ == '__main__':
    fixed = []
    for dirpath, _, filenames in os.walk('k8s/apps/'):
        for filename in sorted(filenames):
            if filename != 'helm-release.yaml':
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

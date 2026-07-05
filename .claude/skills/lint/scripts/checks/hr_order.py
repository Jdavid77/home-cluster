import os
import re
from checks.ordering import get_order

CANONICAL_VALUES_ORDER = get_order('hr_values')
CANONICAL_CONTROLLER_ORDER = get_order('hr_controller')
CANONICAL_CONTAINER_ORDER = get_order('hr_container')

_KEY_RE = re.compile(r'^(\s*)(\w[\w-]*):\s*')


def _get_block_keys(lines, parent_line, parent_indent):
    """Return (key, line_idx) pairs for direct children of a mapping block."""
    child_indent = parent_indent + 2
    result = []
    i = parent_line + 1
    while i < len(lines):
        raw = lines[i]
        stripped = raw.lstrip()
        if not stripped or stripped.startswith('#'):
            i += 1
            continue
        current_indent = len(raw) - len(stripped)
        if current_indent <= parent_indent:
            break
        if current_indent == child_indent:
            m = _KEY_RE.match(raw)
            if m:
                result.append((m.group(2), i))
        i += 1
    return result


def _check_order(keys, canonical, label):
    actual = [k for k in keys if k in canonical]
    expected = [k for k in canonical if k in actual]
    if actual != expected:
        return (label, actual, expected)
    return None


def check_helm_release_order(root="k8s/apps/"):
    issues = []
    for dirpath, _, filenames in os.walk(root):
        for filename in sorted(filenames):
            if filename != "helm-release.yaml":
                continue
            filepath = os.path.join(dirpath, filename)
            with open(filepath, encoding="utf-8", errors="ignore") as f:
                content = f.read()

            if "name: app-template" not in content:
                continue

            lines = content.splitlines()

            # Find `values:` at indent 2 (direct child of spec:)
            values_line = next(
                (i for i, l in enumerate(lines) if re.match(r'^  values:\s*$', l)),
                -1,
            )
            if values_line == -1:
                continue

            values_children = _get_block_keys(lines, values_line, 2)
            values_keys = [k for k, _ in values_children]

            issue = _check_order(values_keys, CANONICAL_VALUES_ORDER, "values")
            if issue:
                issues.append((filepath, *issue))

            # controllers block
            controllers_line = next(
                (line_idx for k, line_idx in values_children if k == "controllers"),
                -1,
            )
            if controllers_line == -1:
                continue

            for ctrl_name, ctrl_line in _get_block_keys(lines, controllers_line, 4):
                ctrl_children = _get_block_keys(lines, ctrl_line, 6)
                ctrl_keys = [k for k, _ in ctrl_children]

                issue = _check_order(ctrl_keys, CANONICAL_CONTROLLER_ORDER, f"controllers.{ctrl_name}")
                if issue:
                    issues.append((filepath, *issue))

                containers_line = next(
                    (line_idx for k, line_idx in ctrl_children if k == "containers"),
                    -1,
                )
                if containers_line == -1:
                    continue

                for ctr_name, ctr_line in _get_block_keys(lines, containers_line, 8):
                    ctr_keys = [k for k, _ in _get_block_keys(lines, ctr_line, 10)]
                    issue = _check_order(ctr_keys, CANONICAL_CONTAINER_ORDER, f"controllers.{ctrl_name}.containers.{ctr_name}")
                    if issue:
                        issues.append((filepath, *issue))

    return issues

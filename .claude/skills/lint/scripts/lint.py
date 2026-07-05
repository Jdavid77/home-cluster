#!/usr/bin/env python3
import os
import re
import sys

CONVENTIONS_FILE = ".agents/conventions/app/schema-comments.md"
TOP_LEVEL_API_VERSION = re.compile(r'^apiVersion:\s*(\S+)')

CANONICAL_SPEC_ORDER = [
    "targetNamespace",
    "dependsOn",
    "path",
    "prune",
    "sourceRef",
    "healthChecks",
    "healthCheckExprs",
    "components",
    "postBuild",
    "wait",
    "interval",
    "retryInterval",
    "timeout",
]


def load_native_api_groups():
    with open(CONVENTIONS_FILE, encoding="utf-8") as f:
        content = f.read()
    section = re.search(
        r'## API groups that do NOT get schema comments\n(.*?)(?=\n##|\Z)',
        content,
        re.DOTALL,
    )
    if not section:
        print(f"WARNING: could not find native API groups section in {CONVENTIONS_FILE}", file=sys.stderr)
        return set()
    return set(re.findall(r'^- `(.+)`', section.group(1), re.MULTILINE))


def check_schema_comments(root="k8s/"):
    native_groups = load_native_api_groups()
    issues = []
    for dirpath, _, filenames in os.walk(root):
        for filename in sorted(filenames):
            if not filename.endswith(".yaml"):
                continue
            filepath = os.path.join(dirpath, filename)
            with open(filepath, encoding="utf-8", errors="ignore") as f:
                content = f.read()

            api_version = None
            for line in content.splitlines():
                m = TOP_LEVEL_API_VERSION.match(line)
                if m:
                    api_version = m.group(1)
                    break
            if api_version is None:
                continue

            if "# yaml-language-server" in content:
                continue

            if api_version in native_groups:
                continue

            issues.append(filepath)

    return issues


def extract_spec_key_sequences(content):
    """Return a list of spec key sequences, one per YAML document in content."""
    results = []
    in_spec = False
    keys = []

    for line in content.splitlines():
        if line == "---":
            if keys:
                results.append(keys)
            keys = []
            in_spec = False
            continue
        if line == "spec:":
            in_spec = True
            continue
        if in_spec:
            m = re.match(r'^  (\w+):', line)
            if m:
                keys.append(m.group(1))
            elif line and not line.startswith(" "):
                in_spec = False

    if keys:
        results.append(keys)

    return results


def check_ks_yaml_order(root="k8s/apps/"):
    issues = []
    for dirpath, _, filenames in os.walk(root):
        for filename in sorted(filenames):
            if filename != "ks.yaml":
                continue
            filepath = os.path.join(dirpath, filename)
            with open(filepath, encoding="utf-8", errors="ignore") as f:
                content = f.read()

            for doc_keys in extract_spec_key_sequences(content):
                known = [k for k in doc_keys if k in CANONICAL_SPEC_ORDER]
                expected = [k for k in CANONICAL_SPEC_ORDER if k in known]
                if known != expected:
                    issues.append((filepath, known, expected))
                    break  # one report per file is enough

    return issues


if __name__ == "__main__":
    all_passed = True

    schema_issues = check_schema_comments()
    if schema_issues:
        all_passed = False
        print(f"[Check 1] Missing yaml-language-server schema comment — {len(schema_issues)} file(s):")
        for f in schema_issues:
            print(f"  {f}")

    order_issues = check_ks_yaml_order()
    if order_issues:
        all_passed = False
        print(f"[Check 2] ks.yaml spec property order — {len(order_issues)} file(s):")
        for filepath, actual, expected in order_issues:
            print(f"  {filepath}")
            print(f"    found:    {', '.join(actual)}")
            print(f"    expected: {', '.join(expected)}")

    if all_passed:
        print("All checks passed.")
        sys.exit(0)
    else:
        sys.exit(1)

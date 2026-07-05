import os
import re
from checks.ordering import get_order

CANONICAL_SPEC_ORDER = get_order('ks_spec')


def _extract_spec_key_sequences(content):
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

            for doc_keys in _extract_spec_key_sequences(content):
                known = [k for k in doc_keys if k in CANONICAL_SPEC_ORDER]
                expected = [k for k in CANONICAL_SPEC_ORDER if k in known]
                if known != expected:
                    issues.append((filepath, known, expected))
                    break

    return issues

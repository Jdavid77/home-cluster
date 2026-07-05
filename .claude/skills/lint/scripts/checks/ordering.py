import os
import sys

_HERE = os.path.dirname(os.path.abspath(__file__))
_ORDERING_FILE = os.path.normpath(os.path.join(_HERE, *['..'] * 5, '.agents', 'conventions', 'app', 'ordering.yaml'))

_cache = None


def _load():
    global _cache
    if _cache is not None:
        return _cache

    try:
        with open(_ORDERING_FILE, encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        print(f'ERROR: ordering file not found: {_ORDERING_FILE}', file=sys.stderr)
        sys.exit(1)

    result = {}
    current_key = None
    for line in content.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith('#'):
            continue
        if not stripped.startswith('-') and stripped.endswith(':'):
            current_key = stripped[:-1]
            result[current_key] = []
        elif stripped.startswith('- ') and current_key is not None:
            result[current_key].append(stripped[2:].strip())

    _cache = result
    return result


def get_order(key):
    return _load()[key]

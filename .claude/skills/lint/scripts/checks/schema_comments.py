import os
import re
import sys

CONVENTIONS_FILE = ".agents/conventions/app/schema-comments.md"
_TOP_LEVEL_API_VERSION = re.compile(r'^apiVersion:\s*(\S+)')


def _load_native_api_groups():
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
    native_groups = _load_native_api_groups()
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
                m = _TOP_LEVEL_API_VERSION.match(line)
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

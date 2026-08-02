import os
import re
import sys

CONVENTIONS_FILE = ".agents/conventions/app/schema-comments.md"
_API_VERSION = re.compile(r'^apiVersion:\s*(\S+)', re.MULTILINE)
_DOC_SEP = re.compile(r'^---[ \t]*$', re.MULTILINE)


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

            for doc in _DOC_SEP.split(content):
                m = _API_VERSION.search(doc)
                if not m:
                    continue
                if m.group(1) in native_groups:
                    continue
                if "# yaml-language-server" in doc:
                    continue
                issues.append(filepath)
                break

    return issues

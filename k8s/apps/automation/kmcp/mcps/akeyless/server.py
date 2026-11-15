import json
import os
import ssl
import urllib.error
import urllib.request

from mcp.server.mcpserver import MCPServer
from mcp.server.mcpserver.exceptions import ToolError
from mcp.server.transport_security import TransportSecuritySettings

AKEYLESS = "https://api.akeyless.io"
K8S = "https://kubernetes.default.svc"
SA = "/var/run/secrets/kubernetes.io/serviceaccount"

mcp = MCPServer("akeyless")


def _request(url, body=None, headers=None, context=None):
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json", **(headers or {})})
    try:
        with urllib.request.urlopen(req, timeout=30, context=context) as resp:
            return json.load(resp)
    except urllib.error.HTTPError as e:
        raise ToolError(f"{url} returned {e.code}: {e.read().decode()[:500]}") from e


def _items(path):
    token = _request(f"{AKEYLESS}/auth", {
        "access-type": "access_key",
        "access-id": os.environ["AKEYLESS_ACCESS_ID"],
        "access-key": os.environ["AKEYLESS_ACCESS_KEY"],
    })["token"]
    # list-items returns one folder level (items + subfolders), so walk the tree
    items, folders, seen = {}, [path], set()
    while folders:
        folder = folders.pop()
        if folder in seen:
            continue
        seen.add(folder)
        page = None
        while True:
            body = {"token": token, "path": folder}
            if page:
                body["pagination-token"] = page
            out = _request(f"{AKEYLESS}/list-items", body)
            new = [i for i in out.get("items") or [] if i["item_name"] not in items]
            items |= {i["item_name"]: i for i in new}
            new_folders = [f for f in out.get("folders") or [] if f not in seen and f not in folders]
            folders += new_folders
            page = out.get("next_page")
            # next_page can come back set even on the last page
            if not page or not (new or new_folders):
                break
    return list(items.values())


def _k8s(version, resource):
    with open(f"{SA}/token") as f:
        token = f.read()
    ctx = ssl.create_default_context(cafile=f"{SA}/ca.crt")
    url = f"{K8S}/apis/external-secrets.io/{version}/{resource}"
    return _request(url, headers={"Authorization": f"Bearer {token}"}, context=ctx)["items"]


def _norm(key):
    return "/" + key.lstrip("/")


@mcp.tool()
def list_items(path: str = "/") -> list[dict]:
    """List Akeyless item names (not values) under a path, including subfolders."""
    return [
        {"name": i["item_name"], "type": i.get("item_type"), "last_accessed": i.get("access_date")}
        for i in _items(path)
    ]


@mcp.tool()
def find_unused_secrets() -> dict:
    """Compare every Akeyless item under / with the keys referenced by ExternalSecrets and PushSecrets in the cluster, and return the items nothing references."""
    used = set()
    for es in _k8s("v1", "externalsecrets"):
        spec = es["spec"]
        used |= {_norm(d["remoteRef"]["key"]) for d in spec.get("data") or []}
        used |= {_norm(d["extract"]["key"]) for d in spec.get("dataFrom") or [] if "extract" in d}
    for ps in _k8s("v1alpha1", "pushsecrets"):
        used |= {_norm(d["match"]["remoteRef"]["remoteKey"]) for d in ps["spec"].get("data") or []}
    items = _items("/")
    unused = [
        {"name": i["item_name"], "type": i.get("item_type"), "last_accessed": i.get("access_date")}
        for i in items
        if _norm(i["item_name"]) not in used
    ]
    return {"total_items": len(items), "referenced_keys": len(used), "unused": unused}


if __name__ == "__main__":
    mcp.run(
        "streamable-http",
        host="0.0.0.0",
        port=8080,
        stateless_http=True,
        # Reached by in-cluster Service names, not localhost
        transport_security=TransportSecuritySettings(enable_dns_rebinding_protection=False),
    )

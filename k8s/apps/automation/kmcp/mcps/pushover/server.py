import os
import urllib.error
import urllib.parse
import urllib.request

from mcp.server.mcpserver import MCPServer
from mcp.server.mcpserver.exceptions import ToolError
from mcp.server.transport_security import TransportSecuritySettings

mcp = MCPServer("pushover")


@mcp.tool()
def send_notification(title: str, message: str) -> str:
    """Send a push notification to the cluster owner's phone via Pushover."""
    body = urllib.parse.urlencode({
        "token": os.environ["PUSHOVER_TOKEN"],
        "user": os.environ["PUSHOVER_USER_KEY"],
        "title": title[:250],
        "message": message[:1024],
    }).encode()
    try:
        urllib.request.urlopen("https://api.pushover.net/1/messages.json", data=body, timeout=10)
    except urllib.error.HTTPError as e:
        raise ToolError(f"Pushover returned {e.code}: {e.read().decode()}") from e
    return "sent"


if __name__ == "__main__":
    mcp.run(
        "streamable-http",
        host="0.0.0.0",
        port=8080,
        stateless_http=True,
        # Reached by in-cluster Service names, not localhost
        transport_security=TransportSecuritySettings(enable_dns_rebinding_protection=False),
    )

# GitHub publishes its webhook source ranges here; the list follows them on every plan
data "http" "github_meta" {
  url = "https://api.github.com/meta"
  request_headers = {
    Accept = "application/vnd.github+json"
  }
}

# Used by the webhook_bypass security rule
resource "cloudflare_list" "github_webhook" {
  account_id  = local.account_id
  name        = "github_webhook"
  description = "Github Webhook Bypass"
  kind        = "ip"
  items = [
    for cidr in jsondecode(data.http.github_meta.response_body).hooks : {
      ip = cidr
    }
  ]
}

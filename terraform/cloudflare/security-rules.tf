# The zone's custom rules (Security → Security rules) are one ruleset, so this owns the whole list:
# a rule added in the dashboard is removed on the next apply.
# Rules run in order. The provider matches rules to the existing ones by ref, so keep each ref
# stable: changing it recreates that rule with a new ID.
resource "cloudflare_ruleset" "security_rules" {
  zone_id = local.zone_id
  name    = "default"
  kind    = "zone"
  phase   = "http_request_firewall_custom"

  rules = [
    {
      ref         = "skip-linkedin-bot"
      description = "Linkedin"
      expression  = "(http.user_agent contains \"LinkedInBot\")"
      action      = "skip"
      action_parameters = {
        ruleset = "current"
        phases = [
          "http_request_sbfm",
        ]
      }
    },
    {
      ref         = "skip-github-webhooks"
      description = "webhook_bypass"
      # The account IP list in lists.tf
      expression = "(ip.src in $github_webhook)"
      action     = "skip"
      action_parameters = {
        ruleset = "current"
        phases = [
          "http_ratelimit",
          "http_request_firewall_managed",
          "http_request_sbfm",
        ]
      }
    },
    {
      ref         = "block-countries"
      description = "Block Requests that come from Sketchy Places"
      expression  = "(ip.geoip.country in {\"AF\" \"CN\" \"IR\" \"IQ\" \"IL\" \"KP\" \"PH\" \"RU\" \"UA\"})"
      action      = "block"
    },
    {
      ref         = "block-known-bots"
      description = "Block Known Bots"
      expression  = "(cf.client.bot)"
      action      = "block"
    },
  ]
}

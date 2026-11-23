import {
  to = cloudflare_ruleset.security_rules
  id = "zones/${local.zone_id}/8a4a7407400d413bba8acb7adf30d6d5"
}

# The zone's custom rules (Security → Security rules) are one ruleset, so this owns the whole list:
# a rule added in the dashboard is removed on the next apply.
# Rules run in order; ref pins each one to the rule ID it had in the dashboard.
resource "cloudflare_ruleset" "security_rules" {
  zone_id = local.zone_id
  name    = "default"
  kind    = "zone"
  phase   = "http_request_firewall_custom"

  rules = [
    {
      ref         = "681e67c3355741399fa2e1b4652db7b4"
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
      ref         = "05fc30b9c3e34ea5bfaa8d7062c7c1d2"
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
      ref         = "74b177e409464398957d71091d071e96"
      description = "Block Requests that come from Sketchy Places"
      expression  = "(ip.geoip.country in {\"AF\" \"CN\" \"IR\" \"IQ\" \"IL\" \"KP\" \"PH\" \"RU\" \"UA\"})"
      action      = "block"
    },
    {
      ref         = "a3ba31b75da045a5a4850a2c8748b5aa"
      description = "Block Known Bots"
      expression  = "(cf.client.bot)"
      action      = "block"
    },
  ]
}

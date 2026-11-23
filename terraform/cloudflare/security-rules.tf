# The zone's custom rules (Security → Security rules) are one ruleset, so this owns the whole list:
# a rule added in the dashboard is removed on the next apply.
# Rules run in order. The provider matches rules to the existing ones by ref, so keep each ref
# stable: changing it recreates that rule with a new ID.
#
# Naming:
#   ref          <action>-<what it matches>, kebab-case (e.g. block-verified-bots). Names the match,
#                not the reason, so it survives edits to the expression.
#   description  <Action> <what>[ for <scope>], sentence case. Shown in the dashboard and logs;
#                free to change.
resource "cloudflare_ruleset" "security_rules" {
  zone_id = local.zone_id
  name    = "default"
  kind    = "zone"
  phase   = "http_request_firewall_custom"

  rules = [
    {
      ref         = "skip-linkedin-bot"
      description = "Skip the remaining security rules and Super Bot Fight Mode for LinkedInBot"
      # Verified only, so a spoofed LinkedInBot user agent doesn't get past the block rules
      expression = "(http.user_agent contains \"LinkedInBot\" and cf.client.bot)"
      action     = "skip"
      action_parameters = {
        ruleset = "current"
        phases = [
          "http_request_sbfm",
        ]
      }
    },
    {
      ref         = "skip-github-webhooks"
      description = "Skip the remaining security rules, rate limiting, managed rules and Super Bot Fight Mode for GitHub webhooks"
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
      description = "Block requests from high-risk countries"
      expression  = "(ip.geoip.country in {\"AF\" \"CN\" \"IR\" \"IQ\" \"IL\" \"KP\" \"PH\" \"RU\" \"UA\"})"
      action      = "block"
    },
    {
      # cf.client.bot is Cloudflare's verified bots (search engines, link previews), not malicious ones
      ref         = "block-verified-bots"
      description = "Block verified bots"
      expression  = "(cf.client.bot)"
      action      = "block"
    },
  ]
}

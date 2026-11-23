# API token: Account Filter Lists Edit (account), Zone WAF Edit and Zone Read (jnobrega.com)
data "sops_file" "secrets" {
  source_file = ".env"
  input_type  = "dotenv"
}

locals {
  api_token = data.sops_file.secrets.data["CLOUDFLARE_API_TOKEN"]
  zone_id   = data.sops_file.secrets.data["CLOUDFLARE_ZONE_ID"]
}

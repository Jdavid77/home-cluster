data "sops_file" "secrets" {
  source_file = ".env"
  input_type  = "dotenv"
}

locals {
  akeyless_access_id = data.sops_file.secrets.data["TF_VAR_akeyless_access_id"]
  akeyless_api_key   = data.sops_file.secrets.data["TF_VAR_akeyless_api_key"]
}

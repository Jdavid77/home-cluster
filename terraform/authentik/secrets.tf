data "sops_file" "secrets" {
  source_file = ".env"
  input_type  = "dotenv"
}

locals {
  authentik_api_url   = data.sops_file.secrets.data["TF_VAR_authentik_api_url"]
  authentik_api_token = data.sops_file.secrets.data["TF_VAR_authentik_api_token"]
  external_host       = data.sops_file.secrets.data["TF_VAR_external_host"]
  bind_password       = data.sops_file.secrets.data["TF_VAR_bind_password"]
  bind_cn             = data.sops_file.secrets.data["TF_VAR_bind_cn"]
}

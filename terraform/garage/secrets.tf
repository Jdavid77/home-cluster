data "sops_file" "secrets" {
  source_file = ".env"
  input_type  = "dotenv"
}

locals {
  server = data.sops_file.secrets.data["TF_VAR_server"]
  token  = data.sops_file.secrets.data["TF_VAR_token"]
}

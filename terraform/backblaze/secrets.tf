data "sops_file" "secrets" {
  source_file = ".env"
  input_type  = "dotenv"
}

locals {
  application_key_id = data.sops_file.secrets.data["TF_VAR_application_key_id"]
  application_key    = data.sops_file.secrets.data["TF_VAR_application_key"]
}

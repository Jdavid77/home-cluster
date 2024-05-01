provider "akeyless" {
  api_gateway_address = "https://api.akeyless.io"

  api_key_login {
    access_id  = var.akeyless_access_id
    access_key = var.akeyless_api_key
  }
}
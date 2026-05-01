provider "akeyless" {
  api_gateway_address = "https://api.akeyless.io"

  api_key_login {
    access_id  = local.akeyless_access_id
    access_key = local.akeyless_api_key
  }
}

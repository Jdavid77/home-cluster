terraform {

  backend "s3" {
    bucket = "authentik-state"
    key    = "authentik.tfstate"
    region = "weur"
    endpoints = {
      s3 = "https://015ce648cc705f6d069fe6068434a576.r2.cloudflarestorage.com/authentik-state"
    }
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }

  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2024.4.2"
    }
  }

}
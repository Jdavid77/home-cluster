terraform {

  backend "s3" {
    bucket                      = "authentik-state"
    key                         = "authentik.tfstate"
    region                      = "weur"
    endpoint                    = "https://015ce648cc705f6d069fe6068434a576.r2.cloudflarestorage.com/authentik-state"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
  }

  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2024.4.2"
    }
  }

}
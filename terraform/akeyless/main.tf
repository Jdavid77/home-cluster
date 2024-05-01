terraform {

  required_providers {
    akeyless = {
      version = ">= 1.0.0"
      source  = "akeyless-community/akeyless"
    }
  }

  backend "s3" {
    bucket                      = "akeyless"
    key                         = "cloudflare.tfstate"
    region                      = "weur"
    endpoint                    = "https://015ce648cc705f6d069fe6068434a576.r2.cloudflarestorage.com"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
  }
}



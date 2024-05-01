terraform {

  backend "s3" {
    bucket                      = "cloudflare"
    key                         = "cloudflare.tfstate"
    region                      = "weur"
    endpoint                    = "https://015ce648cc705f6d069fe6068434a576.r2.cloudflarestorage.com/cloudflare"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.30.0"
    }
  }

}

data "cloudflare_zones" "domain_com" {
  filter {
    name = var.cloudflare_domain_com
  }
}
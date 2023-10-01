terraform {

  cloud {
    organization = "jnobrega"

    workspaces {
      name = "cloudflare"
    }
  }
  
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }

}

data "cloudflare_zones" "domain_com" {
  filter {
    name = var.cloudflare_domain_com
  }
}
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
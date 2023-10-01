
terraform {

  cloud {
    organization = "jnobrega"

    workspaces {
      name = "authentik"
    }
  }

  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2023.8.0"
    }
  }
}



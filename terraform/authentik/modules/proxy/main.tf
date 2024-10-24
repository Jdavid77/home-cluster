terraform {

  required_providers {
    authentik = {
      source                = "goauthentik/authentik"
      version = "2024.8.3"
      configuration_aliases = [authentik]
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
}

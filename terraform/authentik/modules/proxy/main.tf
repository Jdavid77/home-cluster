terraform {

  required_providers {
    authentik = {
      source                = "goauthentik/authentik"
      configuration_aliases = [authentik]
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
  }
}

terraform {
  required_providers {
    akeyless = {
      version = "2.0.2"
      source  = "akeyless-community/akeyless"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.0"
    }
  }
}

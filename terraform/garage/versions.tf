terraform {
  required_providers {
    garage = {
      source  = "jkossis/garage"
      version = "1.0.5"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.0"
    }
  }
}

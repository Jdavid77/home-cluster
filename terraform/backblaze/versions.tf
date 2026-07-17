terraform {
  required_providers {
    b2 = {
      source  = "Backblaze/b2"
      version = "0.13.1"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.0"
    }
  }
}

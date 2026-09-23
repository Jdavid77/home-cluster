terraform {
  required_version = "~> 1.9"
  required_providers {
    b2 = {
      source  = "Backblaze/b2"
      version = "0.14.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.0"
    }
  }
}

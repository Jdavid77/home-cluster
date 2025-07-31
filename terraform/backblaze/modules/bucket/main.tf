terraform {

  required_providers {
    b2 = {
      source = "Backblaze/b2"
      configuration_aliases = [ b2 ]
    }
  }

}

terraform {

  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = "2.5.0"
      configuration_aliases = [ minio ]
    }
  }

}

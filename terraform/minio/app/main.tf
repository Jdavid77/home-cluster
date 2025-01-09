terraform {

  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = "3.2.2"
      configuration_aliases = [ minio ]
    }
  }

}

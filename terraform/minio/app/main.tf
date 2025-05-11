terraform {

  required_providers {
    minio = {
      source  = "aminueza/minio"
      configuration_aliases = [ minio ]
    }
  }

}

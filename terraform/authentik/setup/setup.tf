module "apps" {

  source = "./apps"

  providers = {
    authentik = authentik
  }

  oidc = var.oidc

  proxy = var.proxy

}

module "outpost" {

  source = "./outpost"

  providers = {
    authentik = authentik
  }

  authentik_proxy_provider_ids = module.apps.proxy_providers_id

}



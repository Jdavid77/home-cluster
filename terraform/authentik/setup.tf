module "home-cluster" {

  source                      = "./setup"
  authentik_application_group = "home-cluster"
  authentik_api_token         = var.authentik_api_token
  authentik_api_url           = var.authentik_api_url

  oidc = [
    {
      authentik_oidc_application_name     = "grafana"
      authentik_oidc_application_group    = "home-cluster"
      authentik_oidc_application_icon_url = "https://docs.checkmk.com/latest/images/grafana_logo.png"
    },
  ]

  proxy = [
    {
      authentik_proxy_application_name     = "uptime"
      authentik_proxy_application_group    = "home-cluster"
      authentik_proxy_application_icon_url = "https://cf.appdrag.com/dashboard-openvm-clo-b2d42c/uploads/Uptime-kuma-7fPG.png"
      authentik_proxy_external_host        = "https://uptime.${var.external_host}"
    },
  ]

  providers = {
    authentik = authentik
  }

}
locals {
  oidcs = [
    {
      authentik_oidc_application_name        = "Grafana"
      authentik_oidc_application_group       = "Monitoring"
      authentik_oidc_application_icon_url    = "https://w1.pngwing.com/pngs/950/813/png-transparent-github-logo-grafana-influxdb-dashboard-visualization-web-application-installation-data-plugin-thumbnail.png"
      authentik_oidc_application_description = "Grafana OAuth application"
    },
    {
      authentik_oidc_application_name        = "Paperless-Ngx"
      authentik_oidc_application_group       = "Documents"
      authentik_oidc_application_icon_url    = "https://avatars.githubusercontent.com/u/99562962?s=280&v=4"
      authentik_oidc_application_description = "Paperless OAuth application"
    },
    {
      authentik_oidc_application_name        = "NextCloud"
      authentik_oidc_application_group       = "Cloud"
      authentik_oidc_application_icon_url    = "https://nextcloud.com/c/uploads/2023/02/logo_nextcloud_white.svg"
      authentik_oidc_application_description = "NextCloud OAuth application"
    },
    {
      authentik_oidc_application_name        = "Minio"
      authentik_oidc_application_group       = "Storage"
      authentik_oidc_application_icon_url    = "https://min.io/resources/img/logo/MINIO_Bird.png"
      authentik_oidc_application_description = "Minio OAuth application"
    },
  ]
}

module "oidc" {

  for_each = { for oidc in local.oidcs : oidc.authentik_oidc_application_name => oidc }

  source = "./modules/oidc"

  providers = {
    authentik = authentik
  }

  authentik_oidc_application_name        = each.value.authentik_oidc_application_name
  authentik_oidc_application_group       = each.value.authentik_oidc_application_group
  authentik_oidc_application_icon_url    = each.value.authentik_oidc_application_icon_url
  authentik_oidc_application_description = each.value.authentik_oidc_application_description
}

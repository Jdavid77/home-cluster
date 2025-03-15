locals {
  oidcs = [
    {
      authentik_oidc_application_name        = "Grafana"
      authentik_oidc_application_icon_url    = "https://w1.pngwing.com/pngs/950/813/png-transparent-github-logo-grafana-influxdb-dashboard-visualization-web-application-installation-data-plugin-thumbnail.png"
      authentik_oidc_application_description = "Grafana OAuth application"
    },
    {
      authentik_oidc_application_name        = "Paperless-Ngx"
      authentik_oidc_application_icon_url    = "https://avatars.githubusercontent.com/u/99562962?s=280&v=4"
      authentik_oidc_application_description = "Paperless OAuth application"
    },
    {
      authentik_oidc_application_name        = "PGAdmin"
      authentik_oidc_application_icon_url    = "https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Postgresql_elephant.svg/1200px-Postgresql_elephant.svg.png"
      authentik_oidc_application_description = "PGAdmin OAuth application"
    },
    {
      authentik_oidc_application_name        = "Backstage-Dev"
      authentik_oidc_application_icon_url    = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQBzHHyxg-LtRQ5iGOxRQeP5VzxFoNjzDY3Lg&s"
      authentik_oidc_application_description = "Backstage-Dev OAuth application"
    },
    {
      authentik_oidc_application_name        = "Adventurelog"
      authentik_oidc_application_icon_url    = "https://github.com/seanmorley15/AdventureLog/raw/main/brand/adventurelog.png"
      authentik_oidc_application_description = "AdventureLog OAuth application"
    }
  ]
}

module "oidc" {

  for_each = { for oidc in local.oidcs : oidc.authentik_oidc_application_name => oidc }

  source = "./modules/oidc"

  providers = {
    authentik = authentik
  }

  authentik_oidc_application_name        = each.value.authentik_oidc_application_name
  authentik_oidc_application_icon_url    = each.value.authentik_oidc_application_icon_url
  authentik_oidc_application_description = each.value.authentik_oidc_application_description
}

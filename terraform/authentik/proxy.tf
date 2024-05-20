locals {
  proxies = [
    {
      application_name        = "Stirling PDF"
      application_group       = "Documents"
      application_icon_url    = "https://stirlingtools.com/img/logo.svg"
      application_description = "Stirling PDF Proxy Application"
      external_host           = "https://pdf.${var.external_host}"
    },
    {
      application_name        = "Excalidraw"
      application_group       = "Tools"
      application_icon_url    = "https://pbs.twimg.com/profile_images/1701265499357614080/4lGkkWCm_400x400.jpg"
      application_description = "Excaliraw Proxy Application"
      external_host           = "https://draw.${var.external_host}"
    },
    {
      application_name        = "IT-Tools"
      application_group       = "Tools"
      application_icon_url    = "https://github.com/CorentinTh/it-tools/raw/main/.github/logo.png"
      application_description = "IT-Tools Proxy Application"
      external_host           = "https://it-tools.${var.external_host}"
    },
    {
      application_name        = "Longhorn UI"
      application_group       = "Storage"
      application_icon_url    = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTquJBoCjTwNhw5MhHBzITJJbv-ZEo1sV2Rb559Bmivkw&s"
      application_description = "Longhorn UI Proxy Application"
      external_host           = "https://longhorn.${var.external_host}"
    },
    {
      application_name        = "Prometheus"
      application_group       = "Monitoring"
      application_icon_url    = "https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Prometheus_software_logo.svg/1200px-Prometheus_software_logo.svg.png"
      application_description = "Prometheus Proxy Application"
      external_host           = "https://prometheus.${var.external_host}"
    },
    {
      application_name        = "Alert-Manager"
      application_group       = "Storage"
      application_icon_url    = "https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Prometheus_software_logo.svg/1200px-Prometheus_software_logo.svg.png"
      application_description = "AlertManager Proxy Application"
      external_host           = "https://alerts.${var.external_host}"
    },
  ]
}

module "proxy" {

  for_each = { for proxy in local.proxies : proxy.application_name => proxy }

  source = "./modules/proxy"

  providers = {
    authentik = authentik
  }

  authentik_proxy_application_name        = each.value.application_name
  authentik_proxy_application_group       = each.value.application_group
  authentik_proxy_application_icon_url    = each.value.application_icon_url
  authentik_proxy_application_description = each.value.application_description
  authentik_proxy_external_host           = each.value.external_host

}
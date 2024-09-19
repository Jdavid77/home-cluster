locals {
  proxy = [
    {
      authentik_proxy_application_name     = "Stirling PDF"
      authentik_proxy_application_icon_url = "https://raw.githubusercontent.com/Stirling-Tools/Stirling-PDF/main/docs/stirling.png"
      authentik_proxy_external_host        = "https://pdf.${var.external_host}"
    },
    {
      authentik_proxy_application_name     = "IT-Tools"
      authentik_proxy_application_icon_url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSbQfvQ0xke1DiSodQnuPd9ayiH4LKkEfUDOA&s"
      authentik_proxy_external_host        = "https://it-tools.${var.external_host}"
    },
    {
      authentik_proxy_application_name     = "Hajimari"
      authentik_proxy_application_icon_url = "https://cdn-icons-png.flaticon.com/512/25/25694.png"
      authentik_proxy_external_host        = "https://dashboard.${var.external_host}"
    },
    {
      authentik_proxy_application_name     = "Alert-Manager"
      authentik_proxy_application_icon_url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ2x5gPl3VFda5rgQkPWsRB1d2zZ8zQKQgsgg&s"
      authentik_proxy_external_host        = "https://alerts.${var.external_host}"
    },
    {
      authentik_proxy_application_name     = "Prometheus"
      authentik_proxy_application_icon_url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ2x5gPl3VFda5rgQkPWsRB1d2zZ8zQKQgsgg&s"
      authentik_proxy_external_host        = "https://prometheus.${var.external_host}"
    },
    {
      authentik_proxy_application_name     = "N8N"
      authentik_proxy_application_icon_url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQTEiB39xDx7ypCCzO8_H3Oot9L_MnGz9XgkQ&s"
      authentik_proxy_external_host        = "https://n8n.${var.external_host}"
    }
  ]
}

module "proxy" {

  for_each = { for proxy in local.proxy : proxy.authentik_proxy_application_name => proxy }

  source = "./modules/proxy"

  providers = {
    authentik = authentik
  }

  authentik_proxy_application_name     = each.value.authentik_proxy_application_name
  authentik_proxy_application_icon_url = each.value.authentik_proxy_application_icon_url
  authentik_proxy_external_host        = each.value.authentik_proxy_external_host
}

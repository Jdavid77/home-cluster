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
      authentik_proxy_application_name     = "N8N"
      authentik_proxy_application_icon_url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQTEiB39xDx7ypCCzO8_H3Oot9L_MnGz9XgkQ&s"
      authentik_proxy_external_host        = "https://n8n.${var.external_host}"
    },
    {
      authentik_proxy_application_name     = "Drawio"
      authentik_proxy_application_icon_url = "https://store-images.s-microsoft.com/image/apps.1409.13851527096222888.2b60149a-04a5-4578-a6b2-d7b7377332d5.c22d8e97-4d44-4304-9bd2-55f9d29c0f82"
      authentik_proxy_external_host        = "https://draw.${var.external_host}"
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

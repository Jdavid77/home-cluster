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
      authentik_proxy_application_name     = "Vaultwarden"
      authentik_proxy_application_icon_url = "https://canada1.discourse-cdn.com/free1/uploads/vaultwarden/original/1X/26a1c808c7d5849039d47820eef7889b3415e5ec.png"
      authentik_proxy_external_host        = "https://vaultwarden.${var.external_host}"
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

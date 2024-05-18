locals {
  proxies = [
    {
      application_name        = "Stirling PDF"
      application_group       = "Documents"
      application_icon_url    = "https://stirlingtools.com/img/logo.svg"
      application_description = "Stirling PDF Proxy Application"
      external_host           = "https://pdf.${var.external_host}"
    }
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
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
      authentik_proxy_application_name     = "Traefik"
      authentik_proxy_application_icon_url = "https://upload.wikimedia.org/wikipedia/commons/1/1b/Traefik.logo.png"
      authentik_proxy_external_host        = "https://traefik.${var.external_host}"
    },{
      authentik_proxy_application_name     = "N8n"
      authentik_proxy_application_icon_url = "https://www.drupal.org/files/project-images/n8n-color.png"
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

data "authentik_service_connection_kubernetes" "local" {
  name = "Local Kubernetes Cluster"
}

resource "authentik_outpost" "proxy" {
  name               = "proxy"
  protocol_providers = values(module.proxy)[*].proxy_provider_id
  service_connection = data.authentik_service_connection_kubernetes.local.id
  config = jsonencode({
    log_level                        = "info"
    docker_labels                    = null
    authentik_host                   = var.authentik_api_url
    docker_network                   = null
    container_image                  = null
    docker_map_ports                 = true
    refresh_interval                 = "minutes=5"
    kubernetes_replicas              = 1
    kubernetes_namespace             = "security"
    authentik_host_browser           = ""
    object_naming_template           = "ak-outpost-%(name)s"
    authentik_host_insecure          = false
    kubernetes_json_patches          = null
    kubernetes_service_type          = "ClusterIP"
    kubernetes_ingress_path_type     = null
    kubernetes_image_pull_secrets    = []
    kubernetes_ingress_class_name    = null
    kubernetes_disabled_components   = ["ingress"]
    kubernetes_ingress_annotations   = {}
    kubernetes_ingress_secret_name   = "authentik-outpost-tls"
    kubernetes_httproute_annotations = {}
    kubernetes_httproute_parent_refs = [
      {
        kind        = "Gateway"
        name        = "external"
        group       = "gateway.networking.k8s.io"
        namespace   = "network"
        sectionName = "websecure"
      }
    ]
  })
}
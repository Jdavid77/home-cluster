# Minimalist theme by some random geezer
data "http" "custom_css" {
  url = "https://raw.githubusercontent.com/RatzzFatzz/minimalistic-authentik-theme/refs/heads/master/custom.css"
}

# Create/manage a default brand

resource "authentik_brand" "main" {
  domain         = "auth.${var.external_host}"
  default        = false
  branding_title = "Main"
  branding_custom_css = data.http.custom_css.response_body
  branding_logo = "/static/dist/assets/icons/icon_left_brand.svg"
  branding_favicon = "/static/dist/assets/icons/icon.png"
  branding_default_flow_background = "/static/dist/assets/images/flow_background.jpg"
}
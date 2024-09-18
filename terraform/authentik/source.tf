data "authentik_property_mapping_source_ldap" "user_property" {
  managed_list = [
    "goauthentik.io/sources/ldap/default-name",
    "goauthentik.io/sources/ldap/default-mail",
    "goauthentik.io/sources/ldap/ms-sn",
    "goauthentik.io/sources/ldap/ms-givenName",
    "goauthentik.io/sources/ldap/openldap-cn",
    "goauthentik.io/sources/ldap/openldap-uid"
  ]
}

data "authentik_property_mapping_source_ldap" "group_property" {
  managed_list = [
    "goauthentik.io/sources/ldap/openldap-cn",
  ]
}


resource "authentik_source_ldap" "lldap" {
  name = "lldap"
  slug = "lldap"

  server_uri              = "ldap://lldap.security.svc.cluster.local"
  bind_cn                 = var.bind_cn
  bind_password           = var.bind_password
  base_dn                 = "dc=jnobrega,dc=com"
  user_path_template      = "LDAP/users"
  property_mappings       = data.authentik_property_mapping_source_ldap.user_property.ids
  property_mappings_group = data.authentik_property_mapping_source_ldap.group_property.ids
  additional_user_dn      = "ou=people"
  additional_group_dn     = "ou=groups"
  user_object_filter      = "(objectClass=person)"
  group_object_filter     = "(objectClass=groupOfUniqueNames)"
  group_membership_field  = "member"
  object_uniqueness_field = "uid"
  start_tls               = false

  depends_on = [data.authentik_property_mapping_source_ldap.user_property, data.authentik_property_mapping_source_ldap.group_property]
}

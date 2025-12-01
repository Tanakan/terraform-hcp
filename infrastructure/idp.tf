#------------------------------------------------------------------------------
# Google Workspace Identity Provider
#------------------------------------------------------------------------------
resource "rhcs_identity_provider" "google" {
  count = var.google_idp_enabled ? 1 : 0

  # クラスター作成後に IDP を設定
  cluster        = module.rosa_hcp.cluster_id
  name           = var.google_idp_name
  mapping_method = "claim"

  google = {
    client_id     = var.google_client_id
    client_secret = var.google_client_secret
    hosted_domain = var.google_hosted_domain
  }
}

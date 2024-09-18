resource "minio_iam_user" "longhorn" {

  name          = "longhorn"
  force_destroy = false
  update_secret = false
  disable_user  = false

}
resource "minio_iam_service_account" "longhorn_service_account" {
  target_user = minio_iam_user.longhorn.name
}

resource "minio_iam_user" "this" {

  name          = "${var.name}-user"
  force_destroy = false
  update_secret = false
  disable_user  = false

}

resource "minio_iam_service_account" "this" {
  target_user = minio_iam_user.this.id

  depends_on = [ minio_iam_user.this ]
}

resource "minio_iam_policy" "this" {
  name = "${var.name}-policy"
  policy = templatefile("${path.module}/policy.json.tpl", { name = var.name })
}

resource "minio_iam_user_policy_attachment" "this" {
  user_name   = minio_iam_user.this.id
  policy_name = minio_iam_policy.this.id

  depends_on = [ minio_iam_policy.this, minio_iam_user.this ]
}

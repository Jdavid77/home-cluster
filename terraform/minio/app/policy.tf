resource "minio_iam_policy" "this" {
  name = "${var.name}-policy"
  policy= <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "GrantLonghornBackupstoreAccess0",
      "Effect": "Allow",
      "Action": [
        "s3:Get*",
        "s3:Put*",
        "s3:List*",
        "s3:DeleteObject",
        "s3:AbortMultipartUpload",
        "s3:ListMultipartUploadParts"
      ],
      "Resource": [
        "arn:aws:s3:::${var.name}",
        "arn:aws:s3:::${var.name}/*"
      ]
    }
  ]
}
EOF
}

resource "minio_iam_user_policy_attachment" "this" {
  user_name   = minio_iam_user.this.id
  policy_name = minio_iam_policy.this.id

  depends_on = [ minio_iam_policy.this, minio_iam_user.this ]
}

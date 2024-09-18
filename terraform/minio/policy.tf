resource "minio_iam_policy" "longhorn_backup_policy" {
  name = "longhorn-backup-policy"
  policy= <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "GrantLonghornBackupstoreAccess0",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::longhorn-backups",
        "arn:aws:s3:::longhorn-backups/*"
      ]
    }
  ]
}
EOF
}

resource "minio_iam_user_policy_attachment" "longhorn" {
  user_name   = minio_iam_user.longhorn.id
  policy_name = minio_iam_policy.longhorn_backup_policy.id
}

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Grant${name}Access",
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
        "arn:aws:s3:::${name}",
        "arn:aws:s3:::${name}/*"
      ]
    }
  ]
}

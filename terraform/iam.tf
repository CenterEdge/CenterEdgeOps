resource "aws_iam_user" "BackupUploader" {
  name          = "BackupUploader"
  path          = "/"
  force_destroy = "false"
}

resource "aws_iam_role" "backupadmin" {
    name               = "BackupAdmin"
    path               = "/"
    assume_role_policy = data.aws_iam_policy_document.backupadmin-assumepolicy.json
}

data "aws_iam_policy_document" "backupadmin" {
  statement {
    sid       = "NeedForAWSConsole"
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["arn:aws:s3:::*"]
  }

  statement {
    sid       = "BucketRead"
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = ["arn:aws:s3:::centeredge-db-backup"]
  }

  statement {
    sid     = "BucketObjAllActions"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:DeleteObject"
    ]
    resources = ["arn:aws:s3:::centeredge-db-backup/*"]
  }
}

resource "aws_iam_policy" "backupadmin" {
    name        = "BackupAdmin"
    path        = "/"
    description = "Allows readwrite to everything in centeredge-db-backup bucket"
    policy      = data.aws_iam_policy_document.backupadmin.json
}

data "aws_iam_policy_document" "backupadmin-assumepolicy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::833738481970:root"]
    }
  }

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::472171537141:root"]
    }
    condition  {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "backupadmin" {
  role       = aws_iam_role.backupadmin.name
  policy_arn = aws_iam_policy.backupadmin.arn
}

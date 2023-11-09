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
    sid = "BucketObjAllActions"
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
    condition {
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

# SupportOps

resource "aws_iam_instance_profile" "supportops-server" {
  name = "SupportBot"
  role = aws_iam_role.supportops-server.name
}

resource "aws_iam_role" "supportops-server" {
  name               = "SupportBot"
  description        = "Allows EC2 instances to call AWS services on your behalf."
  assume_role_policy = data.aws_iam_policy_document.ec2-assumepolicy.json
}

resource "aws_iam_role_policy_attachment" "supportops-pass-to-virtuals" {
  role       = aws_iam_role.supportops-server.name
  policy_arn = aws_iam_policy.pass-role-to-training-virtuals.arn
}

resource "aws_iam_role_policy_attachment" "supportops-assume-support-bot" {
  role       = aws_iam_role.supportops-server.name
  policy_arn = aws_iam_policy.assume-support-bot.arn
}

resource "aws_iam_role_policy_attachment" "supportops-ssm-full-access" {
  role       = aws_iam_role.supportops-server.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "supportops-ec2-full-access" {
  role       = aws_iam_role.supportops-server.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "supportops-cloudwatch-read-only" {
  role       = aws_iam_role.supportops-server.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "supportops-resource-groups-read-only" {
  role       = aws_iam_role.supportops-server.name
  policy_arn = "arn:aws:iam::aws:policy/ResourceGroupsandTagEditorReadOnlyAccess"
}

resource "aws_iam_policy" "pass-role-to-training-virtuals" {
  name   = "AllowPassRoleToVirtuals"
  policy = data.aws_iam_policy_document.pass-role-to-training-virtuals.json
}

data "aws_iam_policy_document" "pass-role-to-training-virtuals" {
  statement {
    sid       = "AllowPassRoleToEc2Instances"
    actions   = ["iam:PassRole"]
    resources = ["arn:aws:iam::833738481970:role/CustomerServer"]
  }
}

resource "aws_iam_policy" "assume-support-bot" {
  name   = "AssumeSupportBot"
  policy = data.aws_iam_policy_document.assume-support-bot.json
}

data "aws_iam_policy_document" "assume-support-bot" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = [
      "arn:aws:iam::356285239608:role/SupportBot",
      "arn:aws:iam::243399810067:role/SupportBot",
      "arn:aws:iam::833738481970:role/SupportOps"
    ]
  }
}

# Training Virtuals

resource "aws_iam_instance_profile" "training-virtuals" {
  name = "CustomerServer"
  role = aws_iam_role.training-virtuals.name
}

resource "aws_iam_role" "training-virtuals" {
  name               = "CustomerServer"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2-assumepolicy.json
}

resource "aws_iam_role_policy_attachment" "training-virtuals-self-tagging" {
  role       = aws_iam_role.training-virtuals.name
  policy_arn = aws_iam_policy.training-virtuals-self-tagging.arn
}

resource "aws_iam_role_policy_attachment" "training-virtuals-upload-backups" {
  role       = aws_iam_role.training-virtuals.name
  policy_arn = aws_iam_policy.upload-backups.arn
}

resource "aws_iam_policy" "training-virtuals-self-tagging" {
  policy = data.aws_iam_policy_document.allow-self-tagging.json
}

data "aws_iam_policy_document" "allow-self-tagging" {
  statement {
    sid = "SelfTaggingOnly"
    actions = [
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DescribeTags"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "upload-backups" {
  policy = data.aws_iam_policy_document.upload-backups.json
}

data "aws_iam_policy_document" "upload-backups" {
  statement {
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::centeredge-db-backup/*"]
  }

  statement {
    actions   = ["ec2:DescribeTags"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ec2-assumepolicy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# emailHandler lambda role

resource "aws_iam_role" "email-handler" {
  name               = "SESforLambda"
  path               = "/service-role/"
  assume_role_policy = data.aws_iam_policy_document.email-handler-assumepolicy.json

  managed_policy_arns = [
    "arn:aws:iam::833738481970:policy/service-role/AWSLambdaBasicExecutionRole-6439f5ce-0bf1-459b-8af8-e65491517140",
    "arn:aws:iam::833738481970:policy/service-role/AWSLambdaSESExecutionRole-51dde292-58f0-42e0-9f9f-ee69f08cadd5",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ]

  tags = {}
}

data "aws_iam_policy_document" "email-handler-assumepolicy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

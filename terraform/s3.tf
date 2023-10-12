resource "aws_s3_bucket" "centeredge-ops-emails" {
  bucket = "centeredge-ops-emails"
  tags   = {}
}

resource "aws_s3_bucket_policy" "centeredge-ops-emails" {
  bucket = aws_s3_bucket.centeredge-ops-emails.id
  policy = data.aws_iam_policy_document.allow-ses-put.json
}

data "aws_iam_policy_document" "allow-ses-put" {
  statement {
    sid       = "AllowSESPuts"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::centeredge-ops-emails/*"]
    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:Referer"
      values   = ["833738481970"]
    }
  }
}

resource "aws_s3_bucket_public_access_block" "centeredge-ops-emails" {
  bucket = aws_s3_bucket.centeredge-ops-emails.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "centeredge-ops-emails" {
  bucket = aws_s3_bucket.centeredge-ops-emails.id
  rule {
    id = "ExpireObjects"
    filter {}
    status = "Enabled"
    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket" "centeredge-install" {
  bucket = "centeredge-install"
  tags   = {}
}

resource "aws_s3_bucket_policy" "centeredge-install" {
  bucket = aws_s3_bucket.centeredge-install.id
  policy = data.aws_iam_policy_document.allow-public-read.json
}

data "aws_iam_policy_document" "allow-public-read" {
  statement {
    sid       = "PublicReadGetObject"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::centeredge-install/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_public_access_block" "centeredge-install" {
  bucket = aws_s3_bucket.centeredge-install.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "centeredge-install" {
  bucket = aws_s3_bucket.centeredge-install.id

  access_control_policy {
    grant {
      grantee {
        id   = "82f47eee41dcd98b5e5b48dab0ecbb5353004ac653094d9387867354c76dd925"
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }
    owner {
      display_name = "sreilly"
      id           = "82f47eee41dcd98b5e5b48dab0ecbb5353004ac653094d9387867354c76dd925"
    }
  }
}

resource "aws_s3_bucket" "centeredgeops" {
  bucket = "centeredgeops"
  tags   = {}
}

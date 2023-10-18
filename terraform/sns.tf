resource "aws_sns_topic" "adv-email-received" {
  name   = "support_email_saved_to_s3"
  policy = data.aws_iam_policy_document.adv-emails-access-policy.json
  tags   = {}

  content_based_deduplication = false
  fifo_topic                  = false
}

data "aws_iam_policy_document" "adv-emails-access-policy" {
  statement {
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish",
      "SNS:Receive"
    ]
    resources = ["arn:aws:sns:us-east-1:833738481970:support_email_saved_to_s3"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values   = ["833738481970"]
    }
  }
}
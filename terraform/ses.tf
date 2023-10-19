resource "aws_ses_receipt_rule_set" "adv-emails" {
  rule_set_name = "default-rule-set"
}

resource "aws_ses_receipt_rule" "adv-emails-parse" {
  name          = "ParseEmail"
  rule_set_name = "default-rule-set"

  enabled      = true
  scan_enabled = true
  recipients   = ["ops.centeredge.io"]

  s3_action {
    bucket_name = "centeredge-ops-emails"
    position    = 1
    topic_arn   = aws_sns_topic.adv-email-received.arn
  }
}

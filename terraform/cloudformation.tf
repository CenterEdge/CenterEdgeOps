# DevOpsAutomator
data "local_file" "DevOpsAutomator" {
  filename = "${path.module}/cloudformation-templates/DevOpsAutomator.json"
}

resource "aws_cloudformation_stack" "DevOpsAutomator" {
  name          = "DevOpsAutomator"
  capabilities  = ["CAPABILITY_IAM"]
  template_body = data.local_file.DevOpsAutomator.content
}

# Expire30
data "local_file" "Expire30" {
  filename = "${path.module}/cloudformation-templates/Expire30.json"
}

resource "aws_cloudformation_stack" "Expire30" {
  name          = "Expire30"
  template_body = data.local_file.Expire30.content
}

# Expire60
data "local_file" "Expire60" {
  filename = "${path.module}/cloudformation-templates/Expire60.json"
}

resource "aws_cloudformation_stack" "Expire60" {
  name          = "Expire60"
  template_body = data.local_file.Expire60.content
}

# Highlander
data "local_file" "Highlander" {
  filename = "${path.module}/cloudformation-templates/Highlander.json"
}

resource "aws_cloudformation_stack" "Highlander" {
  name          = "Highlander"
  template_body = data.local_file.Highlander.content
}

# Keep7
data "local_file" "Keep7" {
  filename = "${path.module}/cloudformation-templates/Keep7.json"
}

resource "aws_cloudformation_stack" "Keep7" {
  name          = "Keep7"
  template_body = data.local_file.Keep7.content
}

# Keep30
data "local_file" "Keep30" {
  filename = "${path.module}/cloudformation-templates/Keep30.json"
}

resource "aws_cloudformation_stack" "Keep30" {
  name          = "Keep30"
  template_body = data.local_file.Keep30.content
}

# SnapshotDaily
data "local_file" "SnapshotDaily" {
  filename = "${path.module}/cloudformation-templates/SnapshotDaily.json"
}

resource "aws_cloudformation_stack" "SnapshotDaily" {
  name          = "SnapshotDaily"
  template_body = data.local_file.SnapshotDaily.content
}

# SnapshotDaily30
data "local_file" "SnapshotDaily30" {
  filename = "${path.module}/cloudformation-templates/SnapshotDaily30.json"
}

resource "aws_cloudformation_stack" "SnapshotDaily30" {
  name          = "SnapshotDaily30"
  template_body = data.local_file.SnapshotDaily30.content
}

# SnapshotDailyMin
data "local_file" "SnapshotDailyMin" {
  filename = "${path.module}/cloudformation-templates/SnapshotDailyMin.json"
}

resource "aws_cloudformation_stack" "SnapshotDailyMin" {
  name          = "SnapshotDailyMin"
  template_body = data.local_file.SnapshotDailyMin.content
}


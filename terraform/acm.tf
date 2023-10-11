resource "aws_acm_certificate" "ops-dashboards-lb" {
  domain_name = "dashboard.ops.centeredgesoftware.com"
}

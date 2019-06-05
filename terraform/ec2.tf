locals {
  SupportOps {
    subnet_id       = "subnet-912380ba"
    instance_profile = "SupportBot"
  }
}

resource "aws_instance" "SupportOps" {
  ami                         = "ami-0204606704df03e7e"
  availability_zone           = "us-east-1b"
  ebs_optimized               = true
  instance_type               = "c5.large"
  monitoring                  = false
  key_name                    = "CenterEdgeOps"
  subnet_id                   = "${local.SupportOps["subnet_id"]}"
  vpc_security_group_ids      = ["sg-09f54559649a9d490"]
  associate_public_ip_address = true
  private_ip                  = "172.16.0.248"
  source_dest_check           = true
  iam_instance_profile         = "${local.SupportOps["instance_profile"]}"
  disable_api_termination     = "true"

  root_block_device {
      volume_type           = "gp2"
      volume_size           = 100
      delete_on_termination = true
  }

  tags = "${merge(
    local.default_tags,
    map(
      "Name",               "SupportOps",
      "BillingEnvironment", "Ops"
    )
  )}"
}

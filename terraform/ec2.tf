resource "aws_instance" "SupportOps" {
  ami                         = "ami-0204606704df03e7e"
  availability_zone           = "us-east-1b"
  ebs_optimized               = true
  instance_type               = "t3a.large"
  monitoring                  = false
  key_name                    = "CenterEdgeOps"
  subnet_id                   = aws_subnet.supportops-server-1.id
  vpc_security_group_ids      = [aws_security_group.supportops.id]
  associate_public_ip_address = true
  private_ip                  = "172.16.0.248"
  source_dest_check           = true
  iam_instance_profile        = aws_iam_instance_profile.supportops-server.name
  disable_api_termination     = "true"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 150
    delete_on_termination = true
  }

  tags = merge(
    local.default_tags,
    {
      "Name"               = "SupportOps"
      "BillingEnvironment" = "Ops"
    },
  )
}

resource "aws_eip" "supportops-server" {
  instance = aws_instance.SupportOps.id
}

# Training Virtuals
resource "aws_launch_template" "training-virtuals" {
  name            = "Training_Virtual_Server"
  instance_type   = "t3a.medium"
  key_name        = "CenterEdgeOps"
  tags            = {}
  default_version = 39

  disable_api_termination = true
  ebs_optimized           = false

  image_id  = aws_ami.training-virtuals-2023.id
  user_data = base64encode(file("./resources/training-virtual-user-data.txt"))

  iam_instance_profile {
    arn = aws_iam_instance_profile.training-virtuals.arn
  }

  network_interfaces {
    device_index       = 0
    ipv4_address_count = 0
    ipv4_addresses     = []
    ipv4_prefix_count  = 0
    ipv4_prefixes      = []
    ipv6_address_count = 0
    ipv6_addresses     = []
    ipv6_prefix_count  = 0
    ipv6_prefixes      = []
    security_groups = [
      aws_security_group.training-virtuals.id
    ]
    subnet_id = aws_subnet.training-virtuals-1.id
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      "BillingEnvironment"      = "Ops"
      "DevOpsAutomatorTaskList" = "SnapshotDailyMin"
      "Name"                    = ""
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      "BillingEnvironment" = "Ops"
      "Name"               = ""
    }
  }
}

resource "aws_ami" "training-virtuals-2023" {
  name                = "Training Virtual Template - v23.1.0"
  virtualization_type = "hvm"
  tags                = {}

  ena_support      = true
  root_device_name = "/dev/sda1"

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    encrypted             = false
    iops                  = 0
    snapshot_id           = aws_ebs_snapshot.training-virtuals-2023.id
    throughput            = 0
    volume_size           = 50
    volume_type           = "gp2"
  }
}

resource "aws_ebs_snapshot" "training-virtuals-2023" {
  description = "Created by CreateImage(i-0850362de4528c2a5) for ami-042c90987367ddb79"
  volume_id   = "vol-04134b8375577b07f"
  tags        = {}
}

# Training Virtuals

resource "aws_vpc" "training-virtuals" {
  cidr_block           = "172.31.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "training-virtuals" {
  vpc_id = aws_vpc.training-virtuals.id
}

resource "aws_route_table" "training-virtuals" {
  vpc_id = aws_vpc.training-virtuals.id
}

resource "aws_route" "training-virtuals-internet-access" {
  route_table_id         = aws_route_table.training-virtuals.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.training-virtuals.id
}

resource "aws_subnet" "training-virtuals-1" {
  vpc_id                  = aws_vpc.training-virtuals.id
  cidr_block              = "172.31.80.0/20"
  availability_zone       = "us-east-1f"
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "training-virtuals" {
  subnet_id      = aws_subnet.training-virtuals-1.id
  route_table_id = aws_route_table.training-virtuals.id
}

# SupportOps

resource "aws_vpc" "supportops" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true
  tags = {
    AWSServiceAccount = "697148468905"
  }
}

resource "aws_internet_gateway" "supportops" {
  vpc_id = aws_vpc.supportops.id
  tags = {
    AWSServiceAccount = "697148468905"
  }
}

resource "aws_route_table" "supportops" {
  vpc_id = aws_vpc.supportops.id
  tags = {
    AWSServiceAccount = "697148468905"
  }
}

resource "aws_route" "supportops-internet-access" {
  route_table_id         = aws_route_table.supportops.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.supportops.id
}

resource "aws_subnet" "supportops-server-1" {
  vpc_id            = aws_vpc.supportops.id
  cidr_block        = "172.16.0.0/24"
  availability_zone = "us-east-1b"
  tags = {
    AWSServiceAccount = "697148468905"
  }

  private_dns_hostname_type_on_launch = "ip-name"
}

resource "aws_subnet" "supportops-server-2" {
  vpc_id            = aws_vpc.supportops.id
  cidr_block        = "172.16.1.0/24"
  availability_zone = "us-east-1d"
  tags = {
    AWSServiceAccount = "697148468905"
  }

  private_dns_hostname_type_on_launch = "ip-name"
}

resource "aws_route_table_association" "supportops-server-1" {
  subnet_id      = aws_subnet.supportops-server-1.id
  route_table_id = aws_route_table.supportops.id
}

resource "aws_route_table_association" "supportops-server-2" {
  subnet_id      = aws_subnet.supportops-server-2.id
  route_table_id = aws_route_table.supportops.id
}

resource "aws_security_group" "supportops-db" {
  name        = "SupportOps-DB"
  description = "Created by RDS management console"
  vpc_id      = aws_vpc.supportops.id
  tags        = {}
}

resource "aws_vpc_security_group_egress_rule" "supportops-db-default" {
  security_group_id = aws_security_group.supportops-db.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "supportops-db-supportops-server" {
  description       = "DataServer"
  security_group_id = aws_security_group.supportops-db.id

  referenced_security_group_id = "sg-09f54559649a9d490"
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}

resource "aws_vpc_security_group_ingress_rule" "supportops-db-centeredge" {
  description       = "CE"
  security_group_id = aws_security_group.supportops-db.id

  cidr_ipv4   = "63.234.202.58/32"
  ip_protocol = "tcp"
  from_port   = 5432
  to_port     = 5432
}

resource "aws_vpc_security_group_ingress_rule" "supportops-db-quicksight" {
  description       = "QuickSight us-east-1"
  security_group_id = aws_security_group.supportops-db.id

  cidr_ipv4   = "52.23.63.224/27"
  ip_protocol = "tcp"
  from_port   = 5432
  to_port     = 5432
}

resource "aws_vpc_security_group_ingress_rule" "supportops-db-google-servers-1" {
  description       = "Google"
  security_group_id = aws_security_group.supportops-db.id

  cidr_ipv6   = "2001:4860:4807::/48"
  ip_protocol = "tcp"
  from_port   = 5432
  to_port     = 5432
}

resource "aws_vpc_security_group_ingress_rule" "supportops-db-google-servers-2" {
  description       = "Google"
  security_group_id = aws_security_group.supportops-db.id

  cidr_ipv4   = "74.125.0.0/16"
  ip_protocol = "tcp"
  from_port   = 5432
  to_port     = 5432
}

resource "aws_vpc_security_group_ingress_rule" "supportops-db-google-servers-3" {
  description       = "Google"
  security_group_id = aws_security_group.supportops-db.id

  cidr_ipv4   = "142.251.74.0/23"
  ip_protocol = "tcp"
  from_port   = 5432
  to_port     = 5432
}

resource "aws_security_group" "supportops" {
  name        = "SupportOps"
  description = "launch-wizard-6 created 2019-05-20T14:00:13.438-04:00"
  vpc_id      = aws_vpc.supportops.id
  tags        = {}
}

resource "aws_vpc_security_group_egress_rule" "supportops-default" {
  security_group_id = aws_security_group.supportops.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "supportops-centeredge-access" {
  description       = "CE"
  security_group_id = aws_security_group.supportops.id

  cidr_ipv4   = "68.191.23.70/32"
  ip_protocol = "tcp"
  from_port   = 3389
  to_port     = 3389
}

resource "aws_vpc_security_group_ingress_rule" "supportops-public-http-ipv4" {
  security_group_id = aws_security_group.supportops.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "supportops-public-https-ipv4" {
  security_group_id = aws_security_group.supportops.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}

resource "aws_vpc_security_group_ingress_rule" "supportops-public-http-ipv6" {
  security_group_id = aws_security_group.supportops.id

  cidr_ipv6   = "::/0"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "supportops-public-slack-ipv4" {
  description       = "Slack"
  security_group_id = aws_security_group.supportops.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 7117
  to_port     = 7117
}

resource "aws_vpc_security_group_ingress_rule" "supportops-public-slack-ipv6" {
  description       = "Slack"
  security_group_id = aws_security_group.supportops.id

  cidr_ipv6   = "::/0"
  ip_protocol = "tcp"
  from_port   = 7117
  to_port     = 7117
}

resource "aws_vpc_security_group_ingress_rule" "supportops-public-api-ipv4" {
  description       = "Api"
  security_group_id = aws_security_group.supportops.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 5050
  to_port     = 5050
}

resource "aws_vpc_security_group_ingress_rule" "supportops-public-api-ipv4-health-check" {
  description       = "Api Health"
  security_group_id = aws_security_group.supportops.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 5051
  to_port     = 5051
}

# Training Virtuals

resource "aws_security_group" "training-virtuals" {
  name        = "CustomerServer"
  description = "All access necessary for a customer server"
  vpc_id      = aws_vpc.training-virtuals.id
  tags        = {}
}

resource "aws_vpc_security_group_egress_rule" "training-virtuals-default" {
  security_group_id = aws_security_group.training-virtuals.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "training-virtuals-http" {
  security_group_id = aws_security_group.training-virtuals.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "training-virtuals-https" {
  security_group_id = aws_security_group.training-virtuals.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}

resource "aws_vpc_security_group_ingress_rule" "training-virtuals-smtp" {
  security_group_id = aws_security_group.training-virtuals.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 587
  to_port     = 587
}

resource "aws_vpc_security_group_ingress_rule" "training-virtuals-rdp" {
  security_group_id = aws_security_group.training-virtuals.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 3389
  to_port     = 3389
}

resource "aws_vpc_security_group_ingress_rule" "training-virtuals-vnc" {
  security_group_id = aws_security_group.training-virtuals.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 5900
  to_port     = 5900
}

resource "aws_vpc_security_group_ingress_rule" "training-virtuals-all-icmp" {
  security_group_id = aws_security_group.training-virtuals.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "icmp"
}

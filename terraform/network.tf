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

resource "aws_db_instance" "supportops-database" {
  instance_class = "db.t3.medium"
  db_name        = "grafana"
  identifier     = "supportops"
  engine         = "postgres"
  tags           = {}

  storage_type                    = "gp2"
  allocated_storage               = 20
  max_allocated_storage           = 40
  monitoring_interval             = 60
  backup_retention_period         = 3
  backup_window                   = "06:00-08:00"
  maintenance_window              = "Sun:00:00-Sun:04:00"
  parameter_group_name            = aws_db_parameter_group.supportops-db.name
  kms_key_id                      = data.aws_kms_key.rds-default.arn
  performance_insights_kms_key_id = data.aws_kms_key.rds-default.arn

  port                   = 5432
  network_type           = "IPV4"
  vpc_security_group_ids = [aws_security_group.supportops-db.id]
  db_subnet_group_name   = aws_db_subnet_group.supportops-db.name

  auto_minor_version_upgrade   = true
  storage_encrypted            = true
  copy_tags_to_snapshot        = true
  deletion_protection          = true
  performance_insights_enabled = true
  publicly_accessible          = true
  skip_final_snapshot          = true
}

data "aws_kms_key" "rds-default" {
  key_id = "arn:aws:kms:us-east-1:833738481970:key/a7e2e160-d781-4734-833b-2827180c850c"
}

resource "aws_db_subnet_group" "supportops-db" {
  name = "default-vpc-67692002"
  subnet_ids = [
    aws_subnet.supportops-server-1.id,
    aws_subnet.supportops-server-2.id
  ]
}

resource "aws_db_option_group" "supportops-db" {
  option_group_description = "Default option group for postgres 11"
  engine_name              = "postgres"
  major_engine_version     = "11"
  tags                     = {}
}

resource "aws_db_parameter_group" "supportops-db" {
  name        = "default-with-mod-logging"
  description = "Adds logging for mod statements (INSERT, UPDATE, DELETE, etc)."
  family      = "postgres11"
  tags        = {}

  parameter {
    apply_method = "immediate"
    name         = "log_statement"
    value        = "none"
  }
}

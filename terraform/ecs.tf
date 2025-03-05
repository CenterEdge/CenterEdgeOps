resource "aws_ecr_repository" "jarvis" {
  name = "jarvis"
  tags = local.default_tags

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = "arn:aws:kms:us-east-1:833738481970:key/9b73ca2b-d09a-4409-9120-6b9d5866c072"
  }

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecs_cluster" "ops" {
  name = "ops"
  tags = local.default_tags

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }

  service_connect_defaults {
    namespace = "arn:aws:servicediscovery:us-east-1:833738481970:namespace/ns-ww7pqjoncwsknlqc"
  }
}

resource "aws_ecs_task_definition" "jarvis" {
  family       = "jarvis"
  cpu          = 512
  memory       = 1024
  network_mode = "awsvpc"
  tags         = local.default_tags

  container_definitions    = file("resources/jarvis-container-definitions.json")
  task_role_arn            = aws_iam_role.jarvis.arn
  execution_role_arn       = aws_iam_role.ecs-execution-role.arn
  requires_compatibilities = ["FARGATE"]

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
}

resource "aws_ecs_service" "jarvis" {
  name             = "jarvis"
  launch_type      = "FARGATE"
  platform_version = "1.4.0"
  cluster          = aws_ecs_cluster.ops.id
  task_definition  = format("%s:%s", "jarvis", aws_ecs_task_definition.jarvis.revision)
  triggers         = {}
  desired_count    = 1
  iam_role         = "aws-service-role"
  propagate_tags   = "NONE"
  tags             = local.default_tags

  enable_ecs_managed_tags           = true
  health_check_grace_period_seconds = 0

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  load_balancer {
    // This can refer to jarvis-1 or jarvis-2, depending on the deployment status.
    // If it conflicts with the current state, please update to match AWS rather
    // than pushing this value.
    target_group_arn = aws_lb_target_group.jarvis-2.arn
    container_name   = "jarvis"
    container_port   = 8080
  }

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.jarvis.id]
    subnets = [
      aws_subnet.supportops-server-1.id,
      aws_subnet.supportops-server-2.id
    ]
  }

  # Optional: Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [task_definition]
  }
}

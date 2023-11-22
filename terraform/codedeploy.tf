resource "aws_codedeploy_app" "jarvis" {
  compute_platform = "ECS"
  name             = "AppECS-ops-jarvis"
  tags             = local.default_tags
}

resource "aws_codedeploy_deployment_group" "jarvis" {
  app_name               = aws_codedeploy_app.jarvis.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = "DgpECS-ops-jarvis"
  service_role_arn       = aws_iam_role.code-deploy-service-role.arn
  tags                   = local.default_tags

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_REQUEST"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 10
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.ops.name
    service_name = aws_ecs_service.jarvis.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.jarvis.arn]
      }

      target_group {
        name = aws_lb_target_group.jarvis-1.name
      }

      target_group {
        name = aws_lb_target_group.jarvis-2.name
      }
    }
  }
}

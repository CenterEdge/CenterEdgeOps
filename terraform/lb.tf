
resource "aws_lb" "ops-dashboards" {
  name            = "grafana"
  security_groups = ["sg-09f54559649a9d490"]
  tags            = local.default_tags

  subnet_mapping {
    subnet_id = "subnet-777cc62e"
  }
  subnet_mapping {
    subnet_id = "subnet-912380ba"
  }
}

resource "aws_lb_listener" "grafana" {
  load_balancer_arn = aws_lb.ops-dashboards.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.ops-dashboards-lb.arn
  tags              = local.default_tags

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }
}

resource "aws_lb_listener" "http-redirect" {
  load_balancer_arn = aws_lb.ops-dashboards.arn
  port              = 80
  protocol          = "HTTP"
  tags              = local.default_tags

  default_action {
    type = "redirect"
    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "slack-bot" {
  load_balancer_arn = aws_lb.ops-dashboards.arn
  port              = 7117
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.ops-dashboards-lb.arn
  tags              = local.default_tags

  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      host        = "#{host}"
      port        = "7119"
      path        = "/#{path}"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "jarvis" {
  load_balancer_arn = aws_lb.ops-dashboards.arn
  port              = 7119
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.ops-dashboards-lb.arn
  tags              = local.default_tags

  default_action {
    type = "forward"
    // This can refer to jarvis-1 or jarvis-2, depending on the deployment status.
    // If it conflicts with the current state, please update to match AWS rather
    // than pushing this value.
    target_group_arn = aws_lb_target_group.jarvis-2.arn
  }
}

resource "aws_lb_listener" "api" {
  load_balancer_arn = aws_lb.ops-dashboards.arn
  port              = 5050
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.ops-dashboards-lb.arn
  tags              = local.default_tags

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

resource "aws_lb_target_group" "grafana" {
  name                          = "grafana-server"
  port                          = 80
  protocol                      = "HTTP"
  protocol_version              = "HTTP1"
  connection_termination        = false
  ip_address_type               = "ipv4"
  load_balancing_algorithm_type = "round_robin"
  proxy_protocol_v2             = false
  tags                          = local.default_tags
  vpc_id                        = aws_vpc.supportops.id

  health_check {
    enabled             = true
    healthy_threshold   = 5
    interval            = 30
    matcher             = "200"
    path                = "/login"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  stickiness {
    cookie_duration = 86400
    enabled         = false
    type            = "lb_cookie"
  }
}

resource "aws_lb_target_group" "jarvis-1" {
  name                          = "jarvis"
  target_type                   = "ip"
  port                          = 8080
  protocol                      = "HTTP"
  protocol_version              = "HTTP1"
  connection_termination        = false
  ip_address_type               = "ipv4"
  load_balancing_algorithm_type = "round_robin"
  proxy_protocol_v2             = false
  tags                          = local.default_tags
  vpc_id                        = aws_vpc.supportops.id

  health_check {
    enabled             = true
    healthy_threshold   = 5
    interval            = 30
    matcher             = "200"
    path                = "/healthcheck"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  stickiness {
    cookie_duration = 86400
    enabled         = false
    type            = "lb_cookie"
  }
}

resource "aws_lb_target_group" "jarvis-2" {
  name                          = "jarvis-2"
  target_type                   = "ip"
  port                          = 8080
  protocol                      = "HTTP"
  protocol_version              = "HTTP1"
  connection_termination        = false
  ip_address_type               = "ipv4"
  load_balancing_algorithm_type = "round_robin"
  proxy_protocol_v2             = false
  tags                          = local.default_tags
  vpc_id                        = aws_vpc.supportops.id

  health_check {
    enabled             = true
    healthy_threshold   = 5
    interval            = 30
    matcher             = "200"
    path                = "/healthcheck"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  stickiness {
    cookie_duration = 86400
    enabled         = false
    type            = "lb_cookie"
  }
}

resource "aws_lb_target_group" "api" {
  name                          = "api"
  port                          = 5050
  protocol                      = "HTTP"
  protocol_version              = "HTTP1"
  connection_termination        = false
  ip_address_type               = "ipv4"
  load_balancing_algorithm_type = "round_robin"
  proxy_protocol_v2             = false
  tags                          = local.default_tags
  vpc_id                        = aws_vpc.supportops.id

  health_check {
    enabled             = true
    healthy_threshold   = 5
    interval            = 30
    matcher             = "200"
    path                = "/live"
    port                = 5051
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  stickiness {
    cookie_duration = 86400
    enabled         = false
    type            = "lb_cookie"
  }
}

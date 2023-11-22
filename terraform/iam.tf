resource "aws_iam_user" "BackupUploader" {
  name          = "BackupUploader"
  path          = "/"
  force_destroy = "false"
}

resource "aws_iam_role" "backupadmin" {
  name               = "BackupAdmin"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.backupadmin-assumepolicy.json
}

data "aws_iam_policy_document" "backupadmin" {
  statement {
    sid       = "NeedForAWSConsole"
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["arn:aws:s3:::*"]
  }

  statement {
    sid       = "BucketRead"
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = ["arn:aws:s3:::centeredge-db-backup"]
  }

  statement {
    sid = "BucketObjAllActions"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:DeleteObject"
    ]
    resources = ["arn:aws:s3:::centeredge-db-backup/*"]
  }
}

resource "aws_iam_policy" "backupadmin" {
  name        = "BackupAdmin"
  path        = "/"
  description = "Allows readwrite to everything in centeredge-db-backup bucket"
  policy      = data.aws_iam_policy_document.backupadmin.json
}

data "aws_iam_policy_document" "backupadmin-assumepolicy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::833738481970:root"]
    }
  }

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::472171537141:root"]
    }
    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "backupadmin" {
  role       = aws_iam_role.backupadmin.name
  policy_arn = aws_iam_policy.backupadmin.arn
}

# SupportOps

resource "aws_iam_instance_profile" "supportops-server" {
  name = "SupportBot"
  role = aws_iam_role.supportops-server.name
}

resource "aws_iam_role" "supportops-server" {
  name               = "SupportBot"
  description        = "Allows EC2 instances to call AWS services on your behalf."
  assume_role_policy = data.aws_iam_policy_document.ec2-assumepolicy.json
}

resource "aws_iam_role_policy_attachment" "supportops-pass-to-virtuals" {
  role       = aws_iam_role.supportops-server.name
  policy_arn = aws_iam_policy.pass-role-to-training-virtuals.arn
}

resource "aws_iam_role_policy_attachment" "supportops-assume-support-bot" {
  role       = aws_iam_role.supportops-server.name
  policy_arn = aws_iam_policy.assume-support-bot.arn
}

resource "aws_iam_role_policy_attachment" "supportops-ssm-full-access" {
  role       = aws_iam_role.supportops-server.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "supportops-ec2-full-access" {
  role       = aws_iam_role.supportops-server.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "supportops-cloudwatch-read-only" {
  role       = aws_iam_role.supportops-server.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "supportops-resource-groups-read-only" {
  role       = aws_iam_role.supportops-server.name
  policy_arn = "arn:aws:iam::aws:policy/ResourceGroupsandTagEditorReadOnlyAccess"
}

resource "aws_iam_policy" "pass-role-to-training-virtuals" {
  name   = "AllowPassRoleToVirtuals"
  policy = data.aws_iam_policy_document.pass-role-to-training-virtuals.json
}

data "aws_iam_policy_document" "pass-role-to-training-virtuals" {
  statement {
    sid       = "AllowPassRoleToEc2Instances"
    actions   = ["iam:PassRole"]
    resources = ["arn:aws:iam::833738481970:role/CustomerServer"]
  }
}

resource "aws_iam_policy" "assume-support-bot" {
  name   = "AssumeSupportBot"
  policy = data.aws_iam_policy_document.assume-support-bot.json
}

data "aws_iam_policy_document" "assume-support-bot" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = [
      "arn:aws:iam::356285239608:role/SupportBot",
      "arn:aws:iam::243399810067:role/SupportBot",
      "arn:aws:iam::833738481970:role/SupportOps"
    ]
  }
}

# Training Virtuals

resource "aws_iam_instance_profile" "training-virtuals" {
  name = "CustomerServer"
  role = aws_iam_role.training-virtuals.name
}

resource "aws_iam_role" "training-virtuals" {
  name               = "CustomerServer"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2-assumepolicy.json
}

resource "aws_iam_role_policy_attachment" "training-virtuals-self-tagging" {
  role       = aws_iam_role.training-virtuals.name
  policy_arn = aws_iam_policy.training-virtuals-self-tagging.arn
}

resource "aws_iam_role_policy_attachment" "training-virtuals-upload-backups" {
  role       = aws_iam_role.training-virtuals.name
  policy_arn = aws_iam_policy.upload-backups.arn
}

resource "aws_iam_policy" "training-virtuals-self-tagging" {
  policy = data.aws_iam_policy_document.allow-self-tagging.json
}

data "aws_iam_policy_document" "allow-self-tagging" {
  statement {
    sid = "SelfTaggingOnly"
    actions = [
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DescribeTags"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "upload-backups" {
  policy = data.aws_iam_policy_document.upload-backups.json
}

data "aws_iam_policy_document" "upload-backups" {
  statement {
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::centeredge-db-backup/*"]
  }

  statement {
    actions   = ["ec2:DescribeTags"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ec2-assumepolicy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# emailHandler lambda role

resource "aws_iam_role" "email-handler" {
  name               = "SESforLambda"
  path               = "/service-role/"
  assume_role_policy = data.aws_iam_policy_document.email-handler-assumepolicy.json

  managed_policy_arns = [
    "arn:aws:iam::833738481970:policy/service-role/AWSLambdaBasicExecutionRole-6439f5ce-0bf1-459b-8af8-e65491517140",
    "arn:aws:iam::833738481970:policy/service-role/AWSLambdaSESExecutionRole-51dde292-58f0-42e0-9f9f-ee69f08cadd5",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ]

  tags = {}
}

data "aws_iam_policy_document" "email-handler-assumepolicy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# jarvis ECS & CodeDeploy

resource "aws_iam_role" "code-deploy-service-role" {
  name               = "CodeDeployServiceRole"
  assume_role_policy = data.aws_iam_policy_document.code-deploy-service-role-assume-policy.json
  tags               = local.default_tags
}

data "aws_iam_policy_document" "code-deploy-service-role-assume-policy" {
  statement {
    sid     = ""
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
  statement {
    sid     = ""
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "code-deploy-service-role" {
  role       = aws_iam_role.code-deploy-service-role.name
  policy_arn = aws_iam_policy.code-deploy-service-role.arn
}

resource "aws_iam_policy" "code-deploy-service-role" {
  name        = "CodeDeployService"
  description = "Allows access to ECS to perform deployments."
  policy      = data.aws_iam_policy_document.code-deploy-service-role.json
  tags        = local.default_tags
}

data "aws_iam_policy_document" "code-deploy-service-role" {
  statement {
    sid = "CodeDeployAllow"
    actions = [
      "sns:Publish",
      "s3:GetObjectVersion",
      "s3:GetObject",
      "lambda:InvokeFunction",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeListeners",
      "ecs:UpdateServicePrimaryTaskSet",
      "ecs:DescribeServices",
      "ecs:DeleteTaskSet",
      "ecs:CreateTaskSet",
      "cloudwatch:DescribeAlarms"
    ]
    resources = ["*"]
  }

  statement {
    sid     = "PassRolesInTaskDefinition"
    actions = ["iam:PassRole"]
    resources = [
      "arn:aws:iam::833738481970:role/Jarvis",
      "arn:aws:iam::833738481970:role/ecsTaskExecutionRole"
    ]
  }
}

resource "aws_iam_user" "jarvis-deployer" {
  name = "jarvis-deployer"
  path = "/"
  tags = local.default_tags
}

resource "aws_iam_user_policy_attachment" "jarvis-deployer" {
  user       = aws_iam_user.jarvis-deployer.name
  policy_arn = aws_iam_policy.code-deploy-allow-ecs.arn
}

resource "aws_iam_policy" "code-deploy-allow-ecs" {
  name   = "CodeDeployAllowECS"
  path   = "/"
  policy = data.aws_iam_policy_document.code-deploy-allow-ecs.json
  tags   = local.default_tags
}

data "aws_iam_policy_document" "code-deploy-allow-ecs" {
  statement {
    sid       = "AccessRepository"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
  statement {
    sid = "AllowPushRepository"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
    resources = ["*"]
  }
  statement {
    sid = "RegisterTaskDefinition"
    actions = [
      "ecs:RegisterTaskDefinition",
      "ecs:DescribeTaskDefinition"
    ]
    resources = ["*"]
  }
  statement {
    sid     = "PassRolesInTaskDefinition"
    actions = ["iam:PassRole"]
    resources = [
      aws_iam_role.jarvis.arn,
      aws_iam_role.ecs-execution-role.arn
    ]
  }
  statement {
    sid = "DeployService"
    actions = [
      "ecs:DescribeServices",
      "codedeploy:GetDeploymentGroup",
      "codedeploy:CreateDeployment",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision"
    ]
    resources = [
      aws_ecs_service.jarvis.id,
      aws_codedeploy_app.jarvis.arn,
      aws_codedeploy_deployment_group.jarvis.arn,
      "arn:aws:codedeploy:us-east-1:833738481970:deploymentconfig:*"
    ]
  }
}

resource "aws_iam_role" "jarvis" {
  name               = "Jarvis"
  description        = "Allows ECS tasks to call AWS services on your behalf."
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.jarvis-assume-role-policy.json
  tags               = local.default_tags
}

data "aws_iam_policy_document" "jarvis-assume-role-policy" {
  statement {
    sid     = ""
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "jarvis-manage-virtuals" {
  role       = aws_iam_role.jarvis.name
  policy_arn = aws_iam_policy.jarvis-manage-virtuals.arn
}

resource "aws_iam_policy" "jarvis-manage-virtuals" {
  name   = "ManageTrainingVirtualsEc2"
  policy = data.aws_iam_policy_document.jarvis-manage-virtuals.json
  tags   = local.default_tags
}

data "aws_iam_policy_document" "jarvis-manage-virtuals" {
  statement {
    sid = "EditTrainingTemplateInstances"
    actions = [
      "ec2:RebootInstances",
      "ec2:TerminateInstances",
      "ec2:DeleteTags",
      "ec2:StartInstances",
      "ec2:CreateTags",
      "ec2:RunInstances",
      "ec2:ModifyInstanceAttribute",
      "ec2:StopInstances"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/aws:ec2launchtemplate:id"
      values   = ["lt-069a2a56619110d61"]
    }
  }

  statement {
    sid       = "DescribeAllInstances"
    actions   = ["ec2:DescribeInstances"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "ecs-execution-role" {
  name               = "ecsTaskExecutionRole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs-execution-role-assume-policy.json
  tags               = local.default_tags
}

data "aws_iam_policy_document" "ecs-execution-role-assume-policy" {
  statement {
    sid     = ""
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs-execution-role-ecs" {
  role       = aws_iam_role.ecs-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs-execution-role-ssm" {
  role       = aws_iam_role.ecs-execution-role.name
  policy_arn = aws_iam_policy.ecs-execution-role-ssm.arn
}

resource "aws_iam_policy" "ecs-execution-role-ssm" {
  name   = "SystemsManagerParameterAccess"
  policy = data.aws_iam_policy_document.ecs-execution-role-ssm.json
  tags   = local.default_tags
}

data "aws_iam_policy_document" "ecs-execution-role-ssm" {
  statement {
    sid       = "GetParams"
    actions   = ["ssm:GetParameters"]
    resources = ["arn:aws:ssm:us-east-1:833738481970:parameter/*"]
  }
}

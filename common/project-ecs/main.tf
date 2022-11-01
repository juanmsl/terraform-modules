variable "project" {}
variable "environment" {}
variable "region" {}
variable "vpc_id" {}
variable "fargate_spot" {
  default = false
}

module "ecs_cluster" {
  source       = "../../../modules/aws/ecs/cluster"
  environment  = var.environment
  project      = var.project
  fargate_spot = var.fargate_spot
}

data "aws_iam_policy_document" "ecs_policy" {
  statement {
    resources = ["*"]
    actions   = [
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage"
    ]
  }
  statement {
    resources = ["*"]
    actions   = [
      "ecs:CreateCluster",
      "ecs:StartTelemetrySession",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:Submit*"
    ]
  }
  statement {
    resources = ["arn:aws:logs:*:*:*"]
    actions   = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
  }
}

module "ecs_role" {
  source      = "../../aws/iam/role"
  project     = var.project
  environment = var.environment
  role        = "ecs"
  principals  = {
    "Service" : [
      "ec2.amazonaws.com",
      "ssm.amazonaws.com",
      "ecs-tasks.amazonaws.com"
    ]
  }
  actions   = ["sts:AssumeRole"]
  resources = null
}

module "ecs_role_policy" {
  source      = "../../aws/iam/policy"
  environment = var.environment
  project     = var.project
  role        = "ecs"
  roles       = [module.ecs_role.name]
  policy      = data.aws_iam_policy_document.ecs_policy.json
}

module "security_group" {
  source      = "../../aws/vpc/security-group"
  environment = var.environment
  project     = var.project
  role        = "ecs"
  vpc_id      = var.vpc_id
  rules             = {
    "-1,egress,0,0" = ["0.0.0.0/0"]
  }
}

module "log_group" {
  source      = "../../aws/cloudwatch/log-group"
  environment = var.environment
  project     = var.project
  role        = "cluster"
  service     = "ecs"
}

output "log_group" {
  value = module.log_group.name
}

output "name" {
  value = module.ecs_cluster.name
}

output "arn" {
  value = module.ecs_cluster.arn
}

output "security_group_id" {
  value = module.security_group.id
}

output "iam_role_arn" {
  value = module.ecs_role.arn
}

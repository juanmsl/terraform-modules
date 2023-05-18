variable "project" {}
variable "environment" {}
variable "region" {}
variable "account_id" {}
variable "environment_variables" {}
variable "certificate_arn" {}
variable "ecs_cluster_name" {}
variable "ecs_cluster_role_arn" {}
variable "ecs_security_group_id" {}
variable "ecs_log_group" {}
variable "private_subnets" {}
variable "public_subnets" {}
variable "vpc_cidr" {}
variable "vpc_default_security_group_id" {}
variable "vpc_id" {}
variable "extra_certificates_arns" {
  type    = list
  default = []
}
variable "container_port" {
  default = 80
}
variable "task_definition_cpu" {
  default = 256
}
variable "task_definition_memory" {
  default = 512
}
variable "volume_name" {
  default = "wordpress"
}
variable "volume_container_path" {
  default = "/var/www/html"
}

module "efs" {
  source      = "../../../modules/aws/efs"
  project     = var.project
  environment = var.environment
  role        = "wordpress-files"
  subnets     = var.private_subnets
}

module "security_group_efs_rule" {
  source                = "../../../modules/aws/vpc/security-group/rules"
  security_group_id     = var.vpc_default_security_group_id
  rules_security_groups = {
    "tcp,ingress,2049,2049" = module.service.service_security_group_id
  }
}

module "container_definition_wordpress" {
  source                = "../../../modules/aws/ecs/container-definition"
  name                  = "wordpress"
  service_name          = "wordpress"
  cpu                   = var.task_definition_cpu
  memory                = var.task_definition_memory
  portMappings          = [var.container_port]
  region                = var.region
  log_group             = var.ecs_log_group
  environment_variables = var.environment_variables
  image                 = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/wordpress:apache"
  mountPoints           = [
    {
      containerPath = var.volume_container_path
      sourceVolume  = var.volume_name
    }
  ]
}

module "task_definition" {
  source                = "../../../modules/aws/ecs/task-definition/efs"
  project               = var.project
  environment           = var.environment
  role                  = "service-${module.service.role}"
  cpu                   = var.task_definition_cpu
  memory                = var.task_definition_memory
  task_role_arn         = var.ecs_cluster_role_arn
  execution_role_arn    = var.ecs_cluster_role_arn
  efs_name              = var.volume_name
  efs_id                = module.efs.id
  efs_access_point_id   = module.efs.access_point_id
  container_definitions = jsonencode([
    module.container_definition_wordpress.definition
  ])
}

module "service" {
  source                       = "../../../modules/common/project-alb-service"
  project                      = var.project
  environment                  = var.environment
  certificate_arn              = var.certificate_arn
  container_port               = var.container_port
  ecs_cluster_name             = var.ecs_cluster_name
  ecs_security_group_id        = var.ecs_security_group_id
  health_check_path            = "/wp-admin/install.php"
  load_balancer_container_name = "wordpress"
  private_subnets              = var.private_subnets
  public_subnets               = var.public_subnets
  vpc_cidr                     = var.vpc_cidr
  vpc_id                       = var.vpc_id
  platform_version             = "1.4.0"
  task_definition_arn          = module.task_definition.arn
  extra_certificates_arns      = var.extra_certificates_arns
}

module "auto_scaling" {
  source           = "../../../modules/aws/ecs/auto-scaling"
  ecs_cluster_name = var.ecs_cluster_name
  ecs_service_name = module.service.service_name
}

output "load_balancer_dns_name" {
  value = module.service.load_balancer_dns_name
}

output "load_balancer_zone_id" {
  value = module.service.load_balancer_zone_id
}

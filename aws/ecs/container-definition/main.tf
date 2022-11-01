variable "name" {}
variable "image" {}
variable "cpu" {}
variable "memory" {}
variable "portMappings" {
  type = list
}
variable "log_group" {}
variable "region" {}
variable "service_name" {}
variable "command" {
  default = ""
}
variable "essential" {
  default = true
}
variable "mountPoints" {
  type    = list
  default = []
}
variable "environment_variables" {
  type    = map
  default = {}
}
variable "secrets" {
  type    = map
  default = {}
}
variable "volumesFrom" {
  type    = list
  default = []
}

locals {
  port_mappings = [
  for v in var.portMappings : {
    containerPort = v,
    hostPort      = v,
    protocol      = "tcp"
  }
  ]

  environment_variables = [
  for k, v in var.environment_variables : {
    name  = k,
    value = v
  }
  ]

  secrets = [
  for k, v in var.secrets : {
    name      = k
    valueFrom = v
  }
  ]

  volumes_from = [
  for v in var.volumesFrom : {
    readOnly        = true
    sourceContainer = v
  }
  ]

  container_definition = {
    name             = var.name
    image            = var.image
    cpu              = var.cpu
    memory           = var.memory
    essential        = var.essential
    mountPoints      = var.mountPoints
    portMappings     = local.port_mappings
    command          = var.command == "" ? null : split(" ", var.command)
    logConfiguration = {
      logDriver = "awslogs"
      options   = {
        awslogs-group         = var.log_group
        awslogs-region        = var.region
        awslogs-stream-prefix = var.service_name
      }
    },
    environment = local.environment_variables
    secrets     = local.secrets
    volumesFrom = local.volumes_from
  }
}

output "definition" {
  value = local.container_definition
}
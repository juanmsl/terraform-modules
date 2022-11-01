variable "load_balancer_arn" {}
variable "ssl_policy" {}
variable "certificate_arn" {}
variable "target_group_arn" {}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = var.load_balancer_arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    target_group_arn = var.target_group_arn
    type             = "forward"
  }
}

output "id" {
  value = aws_lb_listener.listener.id
}

output "arn" {
  value = aws_lb_listener.listener.arn
}
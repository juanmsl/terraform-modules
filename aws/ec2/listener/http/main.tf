variable "load_balancer_arn" {}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = var.load_balancer_arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

output "id" {
  value = aws_lb_listener.listener.id
}

output "arn" {
  value = aws_lb_listener.listener.arn
}
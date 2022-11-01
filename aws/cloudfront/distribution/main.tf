variable "project" {}
variable "environment" {}
variable "role" {}
variable "origin_id" {}
variable "origin_domain_name" {}
variable "acm_certificate_arn" {}
variable "price_class" {
  default = "PriceClass_100"
}
variable "http_version" {
  default = "http2"
}
variable "custom_headers" {
  type    = map
  default = {}
}
variable "custom_error_responses" {
  type    = list
  default = []
}
variable "root_object" {
  default = ""
}
variable "min_ttl" {
  default = 0
}
variable "default_ttl" {
  default = 3600
}
variable "max_ttl" {
  default = 86400
}
variable "compress" {
  default = true
}
variable "viewer_protocol_policy" {
  default = "redirect-to-https"
}
variable "aliases" {
  type    = list
  default = []
}
variable "geo_restriction_type" {
  default = "none"
}
variable "geo_restrictions" {
  type    = list
  default = []
}
variable "ssl_support_method" {
  default = "sni-only"
}
variable "minimum_protocol_version" {
  default = "TLSv1"
}
variable "cache_allowed_methods" {
  type    = list
  default = ["GET", "HEAD"]
}
variable "cache_methods" {
  type    = list
  default = ["GET", "HEAD"]
}
variable "cache_lambda_associations" {
  type    = list
  default = []
}
variable "is_ipv6_enabled" {
  default = false
}
variable "access_identity_path" {
  default = ""
}
variable "custom_origin_config" {
  type    = map
  default = {}
}
variable "forward_query_strings" {
  default = false
}
variable "forward_cookies" {
  default = "none"
}
variable "forward_whitelisted_cookies" {
  type = list
  default = []
}
variable "forward_headers" {
  type = list
  default = []
}

locals {
  name                 = join("-", [var.project, var.environment, var.role])
  s3_origin_config     = var.access_identity_path != "" ? [var.access_identity_path] : []
  custom_origin_config = var.custom_origin_config != {} ? [var.custom_origin_config] : []
  tags                 = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
    Role        = var.role
    AWSService  = "cloudfront"
  }
}

resource "aws_cloudfront_distribution" "distribution" {
  enabled             = true
  price_class         = var.price_class
  http_version        = var.http_version
  wait_for_deployment = false
  aliases             = var.aliases
  default_root_object = var.root_object
  is_ipv6_enabled     = var.is_ipv6_enabled
  tags                = local.tags

  origin {
    origin_id   = var.origin_id
    domain_name = var.origin_domain_name

    dynamic "s3_origin_config" {
      for_each = local.s3_origin_config
      content {
        origin_access_identity = s3_origin_config.value
      }
    }

    dynamic "custom_origin_config" {
      for_each = local.custom_origin_config
      content {
        origin_protocol_policy   = lookup(custom_origin_config.value, "origin_protocol_policy")
        origin_ssl_protocols     = lookup(custom_origin_config.value, "origin_ssl_protocols")
        http_port                = lookup(custom_origin_config.value, "http_port", 80)
        https_port               = lookup(custom_origin_config.value, "https_port", 443)
        origin_keepalive_timeout = lookup(custom_origin_config.value, "origin_keepalive_timeout", 60)
        origin_read_timeout      = lookup(custom_origin_config.value, "origin_read_timeout", 60)
      }
    }

    dynamic "custom_header" {
      for_each = var.custom_headers
      content {
        name  = custom_header.key
        value = custom_header.value
      }
    }
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_responses
    content {
      error_code            = lookup(custom_error_response.value, "error_code")
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl")
      response_code         = lookup(custom_error_response.value, "response_code")
      response_page_path    = lookup(custom_error_response.value, "response_page_path")
    }
  }

  default_cache_behavior {
    allowed_methods        = var.cache_allowed_methods
    cached_methods         = var.cache_methods
    compress               = var.compress
    min_ttl                = var.min_ttl
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl
    target_origin_id       = var.origin_id
    viewer_protocol_policy = var.viewer_protocol_policy

    forwarded_values {
      query_string = var.forward_query_strings
      headers = var.forward_headers
      cookies {
        forward = var.forward_cookies
        whitelisted_names = var.forward_whitelisted_cookies
      }
    }

    dynamic "lambda_function_association" {
      for_each = var.cache_lambda_associations
      content {
        event_type   = lookup(lambda_function_association.value, "event_type")
        lambda_arn   = lookup(lambda_function_association.value, "lambda_arn")
        include_body = lookup(lambda_function_association.value, "include_body", false)
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restrictions == [] ? "none" : var.geo_restriction_type
      locations        = var.geo_restrictions
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = var.ssl_support_method
    minimum_protocol_version = var.minimum_protocol_version
  }
}

output "id" {
  value = aws_cloudfront_distribution.distribution.id
}

output "domain_name" {
  value = aws_cloudfront_distribution.distribution.domain_name
}

output "arn" {
  value = aws_cloudfront_distribution.distribution.arn
}

output "hosted_zone_id" {
  value = aws_cloudfront_distribution.distribution.hosted_zone_id
}
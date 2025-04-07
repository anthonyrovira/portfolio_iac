# resource "aws_cloudfront_origin_access_identity" "frontend" {
#   comment = "OAI for Frontend S3 Bucket ${var.domain}"
# }

resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "default"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_function" "redirect_www" {
  name    = "redirect-www-to-root"
  code    = <<-EOT
    function handler(event) {
      var request = event.request;
      if (request.headers.host.value.startsWith("www.")) {
        return {
          statusCode: 301,
          statusDescription: "Moved Permanently",
          headers: {
            "location": { value: "https://${var.domain}" + request.uri }
          }
        };
      }
      return request;
    }
  EOT
  runtime = "cloudfront-js-1.0"
}

resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_200"

  aliases = [var.domain, "www.${var.domain}"]

  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.frontend.id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id

    # s3_origin_config {
    #   origin_access_identity = aws_cloudfront_origin_access_identity.frontend.cloudfront_access_identity_path
    # }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${aws_s3_bucket.frontend.id}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.redirect_www.arn
    }

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }



  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.issued.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }
}

resource "aws_cloudfront_origin_access_control" "backend" {
  name                              = "backend-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "backend" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = ""
  price_class         = "PriceClass_200"
  depends_on          = [aws_instance.backend]

  aliases = ["api.${var.domain}", "grafana.api.${var.domain}"]

  origin {
    domain_name = aws_instance.backend.public_dns
    origin_id   = "EC2-${aws_instance.backend.id}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = "EC2-${aws_instance.backend.id}"
    viewer_protocol_policy = "redirect-to-https"
    # compress               = true

    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" # Managed-AllViewer

    # forwarded_values {
    #   query_string = true
    #   headers      = ["*"]
    #   cookies {
    #     forward = "all"
    #   }
    # }

    # min_ttl     = 0
    # default_ttl = 0
    # max_ttl     = 0

  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.issued.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}


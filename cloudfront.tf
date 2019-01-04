resource "aws_cloudfront_distribution" "cdn" {
  origin {
    origin_id   = "${var.aws_aliases[0]}-origin"
    domain_name = "${var.aws_aliases[0]}.s3.amazonaws.com"
  }

  aliases = ["${var.aws_aliases}"]

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.aws_aliases[0]}-origin"

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  custom_error_response {
      error_code         = 404
      response_code      = 200
      response_page_path = "/error.html"
  } 

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${var.aws_cert_arn}"
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016" 
  }
}
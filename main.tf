# Note: The bucket name needs to carry the same name as the domain!
# http://stackoverflow.com/a/5048129/2966951
resource "aws_s3_bucket" "site" {
  bucket = "${var.site_prefix}.${var.site_name}"
  acl = "public-read"
  policy = <<EOF
{
  "Id": "bucket_policy_site",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "bucket_policy_site_main",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.site_prefix}.${var.site_name}/*",
      "Principal": "*"
    }
  ]
}
  EOF
  website {
      index_document = "index.html"
      error_document = "error.html"
  }
}

resource "aws_s3_bucket_object" "index" {
  bucket = "${aws_s3_bucket.site.bucket}"
  key = "index.html"
  source = "src/index.html"
  content_type = "text/html"
  etag = "${md5(file("src/index.html"))}"
}

resource "aws_s3_bucket_object" "err" {
  bucket = "${aws_s3_bucket.site.bucket}"
  key = "error.html"
  source = "src/error.html"
  content_type = "text/html"
  etag = "${md5(file("src/error.html"))}"
}

resource "aws_route53_record" "root_domain" {
  zone_id = "${var.hosted_zone_id}"
  name = "${var.site_prefix}.${var.site_name}"
  type = "A"

  alias {
    name = "${aws_cloudfront_distribution.cdn.domain_name}"
    zone_id = "${aws_cloudfront_distribution.cdn.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    origin_id   = "${var.site_prefix}.${var.site_name}-origin"
    domain_name = "${var.site_prefix}.${var.site_name}.s3.amazonaws.com"
  }

  # If using route53 aliases for DNS we need to declare it here too, otherwise we'll get 403s.
  aliases = ["${var.site_prefix}.${var.site_name}"]

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.site_prefix}.${var.site_name}-origin"

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  custom_error_response {
      error_code         = 404
      response_code      = 200
      response_page_path = "/error.html"
  } 

  # The cheapest priceclass
  price_class = "PriceClass_100"

  # This is required to be specified even if it's not used.
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${var.aws_cert_arn}"
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016" # defaults wrong, set
  }
}
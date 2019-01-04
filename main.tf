resource "aws_s3_bucket" "site" {
  bucket = "${var.aws_aliases[0]}"
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
      "Resource": "arn:aws:s3:::${var.aws_aliases[0]}/*",
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

resource "aws_route53_record" "domain" {
  count = "${length(var.aws_aliases)}"
  zone_id = "${var.hosted_zone_id}"
  name = "${element(var.aws_aliases, count.index)}"
  type = "A"

  alias {
    name = "${aws_cloudfront_distribution.cdn.domain_name}"
    zone_id = "${aws_cloudfront_distribution.cdn.hosted_zone_id}"
    evaluate_target_health = false
  }
}

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
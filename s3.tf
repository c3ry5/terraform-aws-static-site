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
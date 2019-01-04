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

variable "aws_region" {
    default = "us-east-1"
}

variable "aws_access_key" {
    description = "aws access key"
}

variable "aws_secret_key" {
    description = "aws secret key"
}

variable "aws_cert_arn" {
    description = "The certifate arn"
}

variable "hosted_zone_id" {
    description = "The ID for the cloudfront A name record to be applied"
}

variable "site_name" {
    description = "The DNS domain name of the site being created. e.g. domain.com"
}

variable "site_prefix" {
    description = "The site prefix domain name of the site being created. e.g. www"
}

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}
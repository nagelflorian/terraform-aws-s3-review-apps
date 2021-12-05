module "label" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.25.0"
  enabled     = var.enabled
  namespace   = var.namespace
  environment = var.environment
  stage       = var.stage
  name        = var.name
  delimiter   = var.delimiter
  attributes  = var.attributes
  tags        = var.tags
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE THE CERTIFICATE
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_acm_certificate" "cert" {
  count = var.enabled ? 1 : 0

  provider          = aws.virginia
  domain_name       = "*.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for option in aws_acm_certificate.cert[0].domain_validation_options : option.domain_name => {
      name   = option.resource_record_name
      type   = option.resource_record_type
      record = option.resource_record_value
    }
  }

  name     = each.value.name
  provider = aws.virginia
  records  = [each.value.record]
  ttl      = 60
  type     = each.value.type
  zone_id  = var.route_53_zone_id
}

resource "aws_acm_certificate_validation" "cert" {
  count = var.enabled ? 1 : 0

  provider                = aws.virginia
  certificate_arn         = aws_acm_certificate.cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE THE BUCKET
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "default" {
  count = var.enabled ? 1 : 0

  provider      = aws.virginia
  acl           = "private"
  bucket        = var.domain_name
  force_destroy = var.force_destroy
  policy        = var.policy

  versioning {
    enabled = var.versioning_enabled
  }

  lifecycle_rule {
    id      = module.label.id
    enabled = var.lifecycle_rule_enabled
    tags    = module.label.tags

    noncurrent_version_transition {
      days          = var.noncurrent_version_expiration_days
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = var.expiration_days
    }
  }

  # https://docs.aws.amazon.com/AmazonS3/latest/dev/bucket-encryption.html
  # https://www.terraform.io/docs/providers/aws/r/s3_bucket.html#enable-default-server-side-encryption
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = var.sse_algorithm
        kms_master_key_id = var.kms_master_key_arn
      }
    }
  }

  tags = module.label.tags
}

resource "aws_s3_bucket_policy" "default" {
  count = var.enabled ? 1 : 0

  provider = aws.virginia
  bucket   = aws_s3_bucket.default[0].id
  policy   = <<POLICY
{
  "Version": "2008-10-17",
  "Id": "${module.label.id}_cloudfront_access",
  "Statement": [
    {
      "Sid": "cloudfront_access",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_cloudfront_origin_access_identity.origin_access_identity[0].iam_arn}"
      },
      "Action": "s3:GetObject",
      "Resource": "${aws_s3_bucket.default[0].arn}/*"
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  count = var.enabled ? 1 : 0

  provider                = aws.virginia
  bucket                  = aws_s3_bucket.default[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE EDGE LAMBDA FUNCTIONS
# Used for rewriting headers to use a specific subdirectory within the target bucket for a given subdomain.
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "iam_for_lambda" {
  name = "${module.label.id}_iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "edgelambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy" "edge_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "edge_execution" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = data.aws_iam_policy.edge_execution.arn
}

data "archive_file" "lambda_origin_request_zip_file" {
  type        = "zip"
  output_path = "/tmp/${module.label.id}/lambda_origin_request.zip"

  source {
    content  = file("${path.module}/code/origin_request/index.js")
    filename = "index.js"
  }
}

resource "aws_lambda_function" "lambda_origin_request" {
  count    = var.enabled ? 1 : 0
  provider = aws.virginia

  role             = aws_iam_role.iam_for_lambda.arn
  function_name    = "${module.label.id}_lambda_origin_request"
  filename         = data.archive_file.lambda_origin_request_zip_file.output_path
  source_code_hash = data.archive_file.lambda_origin_request_zip_file.output_base64sha256
  runtime          = "nodejs14.x"
  handler          = "index.handler"
  publish          = true
}

data "archive_file" "lambda_viewer_request_zip_file" {
  type        = "zip"
  output_path = "/tmp/${module.label.id}/lambda_viewer_request.zip"

  source {
    content  = file("${path.module}/code/viewer_request/index.js")
    filename = "index.js"
  }
}

resource "aws_lambda_function" "lambda_viewer_request" {
  count    = var.enabled ? 1 : 0
  provider = aws.virginia

  role             = aws_iam_role.iam_for_lambda.arn
  function_name    = "${module.label.id}_lambda_viewer_request"
  filename         = data.archive_file.lambda_viewer_request_zip_file.output_path
  source_code_hash = data.archive_file.lambda_viewer_request_zip_file.output_base64sha256
  runtime          = "nodejs14.x"
  handler          = "index.handler"
  publish          = true
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE THE CLOUDFRONT DISTRIBUTION
# ----------------------------------------------------------------------------------------------------------------------

locals {
  s3_origin_id = "S3-${var.domain_name}"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  count = var.enabled ? 1 : 0
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  count = var.enabled ? 1 : 0

  origin {
    domain_name = "${var.domain_name}.s3.amazonaws.com"
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity[0].cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Managed by Terraform"
  default_root_object = "index.html"

  aliases = ["*.${var.domain_name}"]

  web_acl_id = var.web_acl_id

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }

      headers = ["X-Original-Host"]
    }

    lambda_function_association {
      event_type   = "origin-request"
      include_body = "false"
      lambda_arn   = aws_lambda_function.lambda_origin_request[0].qualified_arn
    }

    lambda_function_association {
      event_type   = "viewer-request"
      include_body = "false"
      lambda_arn   = aws_lambda_function.lambda_viewer_request[0].qualified_arn
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 60
    max_ttl                = 60
  }

  price_class = var.cloudfront_price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate_validation.cert[0].certificate_arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE THE DNS ENTRIES
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_route53_record" "a_record" {
  count = var.enabled ? 1 : 0

  zone_id = var.route_53_zone_id
  name    = "*.${var.domain_name}"
  type    = "A"

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.s3_distribution[0].domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution[0].hosted_zone_id
  }
}

resource "aws_route53_record" "c_record" {
  count = var.enabled ? 1 : 0

  zone_id = var.route_53_zone_id
  name    = "www.*.${var.domain_name}"
  type    = "CNAME"
  ttl     = "60"
  records = ["*.${var.domain_name}"]
}

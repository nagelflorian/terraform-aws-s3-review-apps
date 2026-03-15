locals {
  enabled      = var.enabled ? toset(["this"]) : toset([])
  s3_origin_id = "S3-${var.domain_name}"
}

module "label" {
  source      = "cloudposse/label/null"
  version     = "0.25.0"
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
  for_each = local.enabled

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
    for option in aws_acm_certificate.cert["this"].domain_validation_options : option.domain_name => {
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
  for_each = local.enabled

  provider                = aws.virginia
  certificate_arn         = aws_acm_certificate.cert["this"].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE THE BUCKET
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "default" {
  for_each = local.enabled

  provider      = aws.virginia
  bucket        = var.domain_name
  force_destroy = var.force_destroy

  lifecycle {
    ignore_changes = [
      server_side_encryption_configuration,
      lifecycle_rule,
    ]
  }

  tags = module.label.tags
}

resource "aws_s3_bucket_ownership_controls" "default" {
  for_each = local.enabled

  bucket   = aws_s3_bucket.default["this"].id
  provider = aws.virginia

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "default" {
  for_each   = local.enabled
  depends_on = [aws_s3_bucket_ownership_controls.default["this"]]

  bucket   = aws_s3_bucket.default["this"].id
  provider = aws.virginia
  acl      = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  for_each = local.enabled

  bucket   = aws_s3_bucket.default["this"].id
  provider = aws.virginia

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = var.kms_master_key_arn
    }
  }
}

resource "aws_s3_bucket_versioning" "default" {
  for_each = local.enabled

  bucket   = aws_s3_bucket.default["this"].id
  provider = aws.virginia
  versioning_configuration {
    status = var.versioning_enabled
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "default" {
  for_each = local.enabled

  bucket   = aws_s3_bucket.default["this"].id
  provider = aws.virginia

  rule {
    id     = module.label.id
    status = var.lifecycle_rule_enabled

    noncurrent_version_transition {
      noncurrent_days = var.noncurrent_version_expiration_days
      storage_class   = "STANDARD_IA"
    }

    expiration {
      days = var.expiration_days
    }
  }
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  for_each = local.enabled

  statement {
    sid    = "AllowCloudFrontServicePrincipal"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.default["this"].arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution["this"].arn]
    }
  }
}

resource "aws_s3_bucket_policy" "default" {
  for_each = local.enabled

  provider = aws.virginia
  bucket   = aws_s3_bucket.default["this"].id
  policy   = data.aws_iam_policy_document.s3_bucket_policy["this"].json
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  for_each = local.enabled

  provider                = aws.virginia
  bucket                  = aws_s3_bucket.default["this"].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE EDGE LAMBDA FUNCTIONS
# Used for rewriting headers to use a specific subdirectory within the target bucket for a given subdomain.
# ----------------------------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "${module.label.id}_iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
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
  for_each = local.enabled
  provider = aws.virginia

  role             = aws_iam_role.iam_for_lambda.arn
  function_name    = "${module.label.id}_lambda_origin_request"
  filename         = data.archive_file.lambda_origin_request_zip_file.output_path
  source_code_hash = data.archive_file.lambda_origin_request_zip_file.output_base64sha256
  runtime          = "nodejs22.x"
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
  for_each = local.enabled
  provider = aws.virginia

  role             = aws_iam_role.iam_for_lambda.arn
  function_name    = "${module.label.id}_lambda_viewer_request"
  filename         = data.archive_file.lambda_viewer_request_zip_file.output_path
  source_code_hash = data.archive_file.lambda_viewer_request_zip_file.output_base64sha256
  runtime          = "nodejs22.x"
  handler          = "index.handler"
  publish          = true
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE THE CLOUDFRONT DISTRIBUTION
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_cloudfront_origin_access_control" "default" {
  for_each = local.enabled

  name                              = var.domain_name
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_cache_policy" "default" {
  for_each = local.enabled

  name        = "${module.label.id}-cache-policy"
  min_ttl     = 0
  default_ttl = 60
  max_ttl     = 60

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["X-Original-Host"]
      }
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  for_each = local.enabled

  origin {
    domain_name              = aws_s3_bucket.default["this"].bucket_regional_domain_name
    origin_id                = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.default["this"].id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Managed by Terraform"
  default_root_object = "index.html"

  aliases = ["*.${var.domain_name}"]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    cache_policy_id        = aws_cloudfront_cache_policy.default["this"].id
    viewer_protocol_policy = "redirect-to-https"

    lambda_function_association {
      event_type   = "origin-request"
      include_body = false
      lambda_arn   = aws_lambda_function.lambda_origin_request["this"].qualified_arn
    }

    lambda_function_association {
      event_type   = "viewer-request"
      include_body = false
      lambda_arn   = aws_lambda_function.lambda_viewer_request["this"].qualified_arn
    }
  }

  price_class = var.cloudfront_price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate_validation.cert["this"].certificate_arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE THE DNS ENTRIES
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_route53_record" "a_record" {
  for_each = local.enabled

  zone_id = var.route_53_zone_id
  name    = "*.${var.domain_name}"
  type    = "A"

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.s3_distribution["this"].domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution["this"].hosted_zone_id
  }
}

resource "aws_route53_record" "c_record" {
  for_each = local.enabled

  zone_id = var.route_53_zone_id
  name    = "www.*.${var.domain_name}"
  type    = "CNAME"
  ttl     = "60"
  records = ["*.${var.domain_name}"]
}

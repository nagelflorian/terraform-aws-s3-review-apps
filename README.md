[![Terraform](https://img.shields.io/badge/Terraform-v1.1+-%23623CE4?style=flat&logo=terraform)](https://registry.terraform.io/modules/nagelflorian/s3-review-apps/aws/latest) [![CircleCI](https://circleci.com/gh/nagelflorian/terraform-aws-s3-review-apps/tree/master.svg?style=svg&circle-token=817dd9be1ab76a988003819c50a5f6a5435e4a45)](https://circleci.com/gh/nagelflorian/terraform-aws-s3-review-apps/tree/master) [![Maintainability](https://api.codeclimate.com/v1/badges/7f8e019a2b1fbc87b82d/maintainability)](https://codeclimate.com/github/nagelflorian/terraform-aws-s3-review-apps/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/7f8e019a2b1fbc87b82d/test_coverage)](https://codeclimate.com/github/nagelflorian/terraform-aws-s3-review-apps/test_coverage)

# Terraform - AWS S3 Review Apps

Terraform module designed to generate a AWS S3 based review-app setup used to preview for example SPA builds on their own subdomains, e.g. `{pr-or-branch-name}.example.com`. It's consisting of a object storage (S3) to store the various frontend builds with optional lifecycle policies, a CDN (CloudFront), two Lambda functions and some general DNS configuration (Route53). The resources are all serverless, i.e. you will only be billed for usage. This includes code-storage and request handling.

![Architecture Diagram](https://raw.githubusercontent.com/nagelflorian/terraform-aws-s3-review-apps/master/docs/architecture_diagram.png)

## Usage

```hcl
module "s3-review-apps" {
  source           = "nagelflorian/s3-review-apps/aws"
  version          = "1.4.1"
  domain_name      = "review.example.com"
  name             = "my_review_app"
  route_53_zone_id = "MY_ROUTE_53_ZONE_ID"
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | ~> 2.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.75.1 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.2.2 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.1.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | ~> 2.2 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.75.1 |
| <a name="provider_aws.virginia"></a> [aws.virginia](#provider\_aws.virginia) | ~> 3.75.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_label"></a> [label](#module\_label) | git::https://github.com/cloudposse/terraform-null-label.git | tags/0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_distribution.s3_distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_identity.origin_access_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_iam_role.iam_for_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.edge_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.lambda_origin_request](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.lambda_viewer_request](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_route53_record.a_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.c_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.cert_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_lifecycle_configuration.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.block_public_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [archive_file.lambda_origin_request_zip_file](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.lambda_viewer_request_zip_file](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_policy.edge_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| <a name="input_basic_auth_password"></a> [basic\_auth\_password](#input\_basic\_auth\_password) | The password to accept when using basic auth | `string` | `null` | no |
| <a name="input_basic_auth_username"></a> [basic\_auth\_username](#input\_basic\_auth\_username) | The username to accept when using basic auth | `string` | `null` | no |
| <a name="input_cloudfront_price_class"></a> [cloudfront\_price\_class](#input\_cloudfront\_price\_class) | AWS CloudFront Price Class | `string` | `"PriceClass_100"` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes` | `string` | `"-"` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The domain used for review app deployments. | `string` | n/a | yes |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment, e.g. 'prod', 'staging', 'dev', 'pre-prod', 'UAT' | `string` | `""` | no |
| <a name="input_expiration_days"></a> [expiration\_days](#input\_expiration\_days) | Specifies when objects expire | `number` | `90` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | A boolean string that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable | `bool` | `false` | no |
| <a name="input_kms_master_key_arn"></a> [kms\_master\_key\_arn](#input\_kms\_master\_key\_arn) | The AWS KMS master key ARN used for the `SSE-KMS` encryption. This can only be used when you set the value of `sse_algorithm` as `aws:kms`. The default aws/s3 AWS KMS master key is used if this element is absent while the `sse_algorithm` is `aws:kms` | `string` | `""` | no |
| <a name="input_lifecycle_rule_enabled"></a> [lifecycle\_rule\_enabled](#input\_lifecycle\_rule\_enabled) | Enable or disable lifecycle rule | `string` | `"Disabled"` | no |
| <a name="input_name"></a> [name](#input\_name) | Solution name, e.g. 'app' or 'jenkins' | `string` | `"review-apps"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `""` | no |
| <a name="input_noncurrent_version_expiration_days"></a> [noncurrent\_version\_expiration\_days](#input\_noncurrent\_version\_expiration\_days) | Number of days to persist in the standard storage tier before moving to the infrequent access tier | `number` | `30` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | If specified, the AWS region this bucket should reside in. Otherwise, the region used by the callee | `string` | `"us-east-1"` | no |
| <a name="input_route_53_zone_id"></a> [route\_53\_zone\_id](#input\_route\_53\_zone\_id) | AWS Route 53 Zone Id used by | `string` | n/a | yes |
| <a name="input_sse_algorithm"></a> [sse\_algorithm](#input\_sse\_algorithm) | The server-side encryption algorithm to use. Valid values are `AES256` and `aws:kms` | `string` | `"AES256"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | A state of versioning. Versioning is a means of keeping multiple variants of an object in the same bucket | `string` | `"Enabled"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_s3_bucket_arn"></a> [aws\_s3\_bucket\_arn](#output\_aws\_s3\_bucket\_arn) | AWS S3 Bucket ARN |
| <a name="output_aws_s3_bucket_name"></a> [aws\_s3\_bucket\_name](#output\_aws\_s3\_bucket\_name) | AWS S3 Bucket Name |

## Tests

You can run automated end-to-end tests using the following command, notice this will deploy actual resources in your AWS account which might result in charges for you:

```console
DOMAIN_NAME="foo" ROUTE_53_ROUTE_ID="bar" go test -v -count=1 -mod=vendor -timeout=1800s ./...
```

## License

This code is released under the MIT License. See `LICENSE` for full details.

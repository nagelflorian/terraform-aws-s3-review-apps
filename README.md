[![Terraform](https://img.shields.io/badge/Terraform-v1.0+-%23623CE4?style=flat&logo=terraform)](https://registry.terraform.io/modules/nagelflorian/s3-review-apps/aws/latest) [![CircleCI](https://circleci.com/gh/nagelflorian/terraform-aws-s3-review-apps/tree/master.svg?style=svg&circle-token=817dd9be1ab76a988003819c50a5f6a5435e4a45)](https://circleci.com/gh/nagelflorian/terraform-aws-s3-review-apps/tree/master) [![Maintainability](https://api.codeclimate.com/v1/badges/7f8e019a2b1fbc87b82d/maintainability)](https://codeclimate.com/github/nagelflorian/terraform-aws-s3-review-apps/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/7f8e019a2b1fbc87b82d/test_coverage)](https://codeclimate.com/github/nagelflorian/terraform-aws-s3-review-apps/test_coverage)

# Terraform - AWS S3 Review Apps

Terraform module designed to generate a AWS S3 based review-app setup used to preview for example SPA builds on their own subdomains, e.g. `{pr-or-branch-name}.example.com`. It's consisting of a object storage (S3) to store the various frontend builds with optional lifecycle policies, a CDN (CloudFront), two Lambda functions and some general DNS configuration (Route53). The resources are all serverless, i.e. you will only be billed for usage. This includes code-storage and request handling.

![Architecture Diagram](https://raw.githubusercontent.com/nagelflorian/terraform-aws-s3-review-apps/master/docs/architecture_diagram.png)

## Usage

```hcl
module "s3-review-apps" {
  source           = "nagelflorian/s3-review-apps/aws"
  version          = "1.0.0"
  domain_name      = "review.example.com"
  name             = "my_review_app"
  route_53_zone_id = "MY_ROUTE_53_ZONE_ID"
}
```

## Inputs

| Name                               | Description                                                                                                                                                                                                                                                                 | Type           | Default            | Required |
| ---------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------------------ | :------: |
| attributes                         | Additional attributes (e.g. `1`)                                                                                                                                                                                                                                            | `list(string)` | `[]`               |    no    |
| cloudfront_price_class             | AWS CloudFront Price Class                                                                                                                                                                                                                                                  | `string`       | `"PriceClass_100"` |    no    |
| delimiter                          | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`                                                                                                                                                                                   | `string`       | `"-"`              |    no    |
| domain_name                        | The domain used for review app deployments.                                                                                                                                                                                                                                 | `string`       | n/a                |   yes    |
| enabled                            | Set to false to prevent the module from creating any resources                                                                                                                                                                                                              | `bool`         | `true`             |    no    |
| environment                        | Environment, e.g. 'prod', 'staging', 'dev', 'pre-prod', 'UAT'                                                                                                                                                                                                               | `string`       | `""`               |    no    |
| expiration_days                    | Specifies when objects expire                                                                                                                                                                                                                                               | `number`       | `90`               |    no    |
| force_destroy                      | A boolean string that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable                                                                                                          | `bool`         | `false`            |    no    |
| kms_master_key_arn                 | The AWS KMS master key ARN used for the `SSE-KMS` encryption. This can only be used when you set the value of `sse_algorithm` as `aws:kms`. The default aws/s3 AWS KMS master key is used if this element is absent while the `sse_algorithm` is `aws:kms`                  | `string`       | `""`               |    no    |
| lifecycle_rule_enabled             | Enable or disable lifecycle rule                                                                                                                                                                                                                                            | `bool`         | `false`            |    no    |
| name                               | Solution name, e.g. 'app' or 'jenkins'                                                                                                                                                                                                                                      | `string`       | `"review-apps"`    |    no    |
| namespace                          | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'                                                                                                                                                                                         | `string`       | `""`               |    no    |
| noncurrent_version_expiration_days | Number of days to persist in the standard storage tier before moving to the infrequent access tier                                                                                                                                                                          | `number`       | `30`               |    no    |
| policy                             | A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy | `string`       | `""`               |    no    |
| region                             | If specified, the AWS region this bucket should reside in. Otherwise, the region used by the callee                                                                                                                                                                         | `string`       | `""`               |    no    |
| route_53_zone_id                   | AWS Route 53 Zone Id used by                                                                                                                                                                                                                                                | `string`       | n/a                |   yes    |
| sse_algorithm                      | The server-side encryption algorithm to use. Valid values are `AES256` and `aws:kms`                                                                                                                                                                                        | `string`       | `"AES256"`         |    no    |
| stage                              | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release'                                                                                                                                                                                     | `string`       | `""`               |    no    |
| tags                               | Additional tags (e.g. `map('BusinessUnit','XYZ')`                                                                                                                                                                                                                           | `map(string)`  | `{}`               |    no    |
| versioning_enabled                 | A state of versioning. Versioning is a means of keeping multiple variants of an object in the same bucket                                                                                                                                                                   | `bool`         | `true`             |    no    |

## Outputs

| Name               | Description        |
| ------------------ | ------------------ |
| aws_s3_bucket_arn  | AWS S3 Bucket ARN  |
| aws_s3_bucket_name | AWS S3 Bucket Name |

## Tests

You can run automated end-to-end tests using the following command, notice this will deploy actual resources in your AWS account which might result in charges for you:

```console
DOMAIN_NAME="foo" ROUTE_53_ROUTE_ID="bar" go test -v -count=1 -mod=vendor -timeout=1800s ./...
```

## License

This code is released under the MIT License. See `LICENSE` for full details.

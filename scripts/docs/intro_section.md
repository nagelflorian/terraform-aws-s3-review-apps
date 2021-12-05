[![Terraform](https://img.shields.io/badge/Terraform-v1.0+-%23623CE4?style=flat&logo=terraform)](https://registry.terraform.io/modules/nagelflorian/s3-review-apps/aws/latest) [![CircleCI](https://circleci.com/gh/nagelflorian/terraform-aws-s3-review-apps/tree/master.svg?style=svg&circle-token=817dd9be1ab76a988003819c50a5f6a5435e4a45)](https://circleci.com/gh/nagelflorian/terraform-aws-s3-review-apps/tree/master) [![Maintainability](https://api.codeclimate.com/v1/badges/7f8e019a2b1fbc87b82d/maintainability)](https://codeclimate.com/github/nagelflorian/terraform-aws-s3-review-apps/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/7f8e019a2b1fbc87b82d/test_coverage)](https://codeclimate.com/github/nagelflorian/terraform-aws-s3-review-apps/test_coverage)

# Terraform - AWS S3 Review Apps

Terraform module designed to generate a AWS S3 based review-app setup used to preview for example SPA builds on their own subdomains, e.g. `{pr-or-branch-name}.example.com`. It's consisting of a object storage (S3) to store the various frontend builds with optional lifecycle policies, a CDN (CloudFront), two Lambda functions and some general DNS configuration (Route53). The resources are all serverless, i.e. you will only be billed for usage. This includes code-storage and request handling.

![Architecture Diagram](https://raw.githubusercontent.com/nagelflorian/terraform-aws-s3-review-apps/master/docs/architecture_diagram.png)

## Usage

```hcl
module "s3-review-apps" {
  source           = "nagelflorian/s3-review-apps/aws"
  version          = "1.2.0"
  domain_name      = "review.example.com"
  name             = "my_review_app"
  route_53_zone_id = "MY_ROUTE_53_ZONE_ID"
}
```


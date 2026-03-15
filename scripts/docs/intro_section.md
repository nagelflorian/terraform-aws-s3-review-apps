[![Terraform](https://img.shields.io/badge/Terraform-v1.5+-%23623CE4?style=flat&logo=terraform)](https://registry.terraform.io/modules/nagelflorian/s3-review-apps/aws/latest)

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

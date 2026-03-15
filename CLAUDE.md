# CLAUDE.md

See [README.md](README.md) for project overview, usage examples, inputs/outputs, and architecture diagram.

## Project structure

- `main.tf` — All AWS resources (ACM, S3, CloudFront, Lambda@Edge, Route53, IAM)
- `versions.tf` — Terraform and provider version constraints, provider config (dual `aws` providers: default + `aws.virginia`)
- `variables.tf` / `outputs.tf` — Module interface
- `code/` — Lambda@Edge functions (Node.js)
  - `origin_request/` — Rewrites S3 origin path based on subdomain
  - `viewer_request/` — Rewrites viewer request headers
  - Each has `__tests__/` with Jest tests and sample CloudFront events
- `tests/main_test.go` — End-to-end Terratest (deploys real AWS resources)
- `scripts/generate_docs.sh` — Regenerates README.md using `terraform-docs` (runs via lint-staged pre-commit hook)
- `docs/` — Partial markdown files assembled into README.md by the generate_docs script

## Testing

### Unit tests (Lambda functions)
```sh
npm test
```

### End-to-end tests (Terraform — deploys real AWS resources, incurs costs)
```sh
DOMAIN_NAME="foo" ROUTE_53_ROUTE_ID="bar" go test -v -count=1 -timeout=1800s ./...
```

## CI

- **GitHub Actions** (`.github/workflows/ci.yml`): Runs `npm test` on Node 20 and 22
- **CodeQL** (`.github/workflows/codeql-analysis.yml`): Scans Go and JavaScript

## Key conventions

- README.md is auto-generated — edit files in `docs/` and `variables.tf`/`outputs.tf` instead, then run `scripts/generate_docs.sh`
- All AWS resources requiring a region use `provider = aws.virginia` (us-east-1) since CloudFront/Lambda@Edge require it
- Pre-commit hooks: husky + lint-staged runs `generate_docs.sh` on all files and prettier on JS/CSS/MD
- The module uses [cloudposse/terraform-null-label](https://github.com/cloudposse/terraform-null-label) (pinned at 0.25.0) for consistent resource naming/tagging

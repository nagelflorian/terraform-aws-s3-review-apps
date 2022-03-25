package tests

import (
	"os"
	"testing"

	"github.com/google/uuid"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestReviewAppResources(t *testing.T) {
	t.Parallel()

	name := uuid.New().String()[0:12]
	domainName := os.Getenv("DOMAIN_NAME")
	route53ZoneID := os.Getenv("ROUTE_53_ROUTE_ID")

	if domainName == "" {
		t.Skip("skipping test; $DOMAIN_NAME not set")
	}
	if route53ZoneID == "" {
		t.Skip("skipping test; $ROUTE_53_ROUTE_ID not set")
	}

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"domain_name":      domainName,
			"name":             name,
			"namespace":        "gh",
			"stage":            "dev",
			"route_53_zone_id": route53ZoneID,
		},
		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	expectedBucketName := domainName
	actualBucketName := terraform.Output(t, terraformOptions, "aws_s3_bucket_name")
	assert.Equal(t, expectedBucketName, actualBucketName)
}

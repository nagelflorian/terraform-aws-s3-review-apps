package tests

import (
	"testing"

	"github.com/google/uuid"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestReviewAppResources(t *testing.T) {
	t.Parallel()

	randomBucketName := uuid.New().String()

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"name": randomBucketName,
		},
		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	expectedBucketName := randomBucketName
	actualBucketName := terraform.Output(t, terraformOptions, "aws_s3_bucket_name")
	assert.Equal(t, expectedBucketName, actualBucketName)
}

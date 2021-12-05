#!/usr/bin/env bash

current_dir=$(dirname "$0")

intro_section=$(cat $current_dir/docs/intro_section.md)
terraform_docs=$(terraform-docs markdown table ./);
test_section=$(cat $current_dir/docs/test_section.md)
license_section=$(cat $current_dir/docs/license_section.md)

cat > README.md <<EOF
$intro_section

$terraform_docs

$test_section

$license_section
EOF

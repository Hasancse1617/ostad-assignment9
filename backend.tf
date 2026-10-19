# OPTIONAL REMOTE BACKEND
# 1) Create a globally unique S3 bucket manually, enable versioning and default encryption.
# 2) Uncomment the block below and replace the bucket name/key values.
# 3) Run: terraform init -migrate-state
#
# Keep backend configuration separate per environment (recommended: separate keys).
# The backend bucket must exist before terraform init. Never commit backend credentials.
#
# terraform {
#   backend "s3" {
#     bucket       = "REPLACE-WITH-YOUR-UNIQUE-STATE-BUCKET"
#     key          = "novacart/dev/terraform.tfstate"
#     region       = "ap-southeast-1"
#     encrypt      = true
#     use_lockfile = true
#   }
# }
#
# S3 native lockfiles require a recent Terraform version that supports use_lockfile.
# For older Terraform versions, configure a DynamoDB lock table as documented by HashiCorp.

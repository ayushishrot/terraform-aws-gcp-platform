# Remote state in S3 with a DynamoDB lock table.
# Bootstrap the bucket/table once, then `terraform init` against this backend.
terraform {
  backend "s3" {
    bucket         = "compliance-tfstate-apsouth1"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "compliance-tflock"
    encrypt        = true
  }
}

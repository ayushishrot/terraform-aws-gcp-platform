# Remote state in S3 with a DynamoDB lock table.
terraform {
  backend "s3" {
    bucket         = "compliance-tfstate-apsouth1"
    key            = "prod/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "compliance-tflock"
    encrypt        = true
  }
}

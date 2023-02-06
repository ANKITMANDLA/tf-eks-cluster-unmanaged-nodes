terraform {
  required_version = ">=0.12.18"
  backend "s3" {
    bucket = "hansencx-prov-vm-terraform-states"
    region = "us-east-1"
    key    = "terraform-test-smp-eks"
    dynamodb_table = "terraform-state-lock"
  }
}
terraform {

  backend "s3" {
    dynamodb_table = "terraform-state-lock"
    encrypt        = "true"
  }
}
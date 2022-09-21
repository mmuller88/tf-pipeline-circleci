resource "aws_s3_bucket" "b" {

  bucket = "martti-hello-world-${var.environment}"

  tags = {
    Name        = "example-param-${var.environment}"
    Owner       = "Martti"
    Environment = var.environment
    Region      = var.region
  }

}
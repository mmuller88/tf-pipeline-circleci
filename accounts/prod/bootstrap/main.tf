module "bootstrap" {
  source = "trussworks/bootstrap/aws"

  region        = var.region
  account_alias = "martti-data-management-${var.environment}"
}
provider "aws" {
  # region = "eu-central-1"
  dynamic "assume_role" {
    for_each = var.provider_role_arn != "" ? [1] : []
    content {
      role_arn = var.provider_role_arn
    }
  }
}
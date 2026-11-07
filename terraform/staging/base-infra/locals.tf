locals {
  # Workspaces: the "default" workspace uses var.env; any other workspace name
  # becomes the environment (e.g. `terraform workspace new staging-feature`)
  # so a parallel copy gets its own resource names and its own state file.
  env  = terraform.workspace == "default" ? var.env : terraform.workspace
  name = "${var.project}-${local.env}"

  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Project     = var.project
    Environment = local.env
    Workspace   = terraform.workspace
    ManagedBy   = "terraform"
  }
}

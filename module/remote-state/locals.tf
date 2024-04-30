locals {
  bucket_name     = join("-", ["terraform", var.bucket_name, var.env, "state"])
  lock_table_name = join("-", ["terraform", var.bucket_name, var.env, "lock"])

  tags = {
    Environment = var.env
    Project     = var.project
    Subproject  = var.module_name
  }
}

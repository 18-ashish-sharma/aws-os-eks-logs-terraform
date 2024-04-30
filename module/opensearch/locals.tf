locals {
  cluster_name = join("-", [var.cluster_name, var.env])
}

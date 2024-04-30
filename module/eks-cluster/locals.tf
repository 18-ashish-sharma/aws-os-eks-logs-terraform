locals {
  cluster_name     = join("-", [var.cluster_name, var.env])
  nodegroup1_label = join("-", ["ng1", var.env])
}
locals {
  domain_name = join("-", [var.cluster_name, var.env])

  # Spread data nodes across two AZs whenever there is more than one.
  zone_awareness = var.instance_count > 1

  tags = merge(var.tags, {
    Environment = var.env
  })
}

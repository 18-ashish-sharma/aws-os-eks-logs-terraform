# Bootstrap stack: creates the S3 bucket and DynamoDB table that every other
# stack in this environment uses as its backend. It starts with local state
# (chicken-and-egg); after the first apply you can move its own state into
# the bucket with `terraform init -migrate-state`.
module "remote_state" {
  source = "../../../module/remote-state"

  bucket_name = var.bucket_name
  env         = var.env
  project     = var.project
}

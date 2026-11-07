terraform {
  # >= 1.10 for S3-native state locking (use_lockfile) and optional() defaults.
  required_version = ">= 1.10.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "~> 2.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}

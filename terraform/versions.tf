terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0" # Use a compatible version
    }
  }
  required_version = ">= 1.0.0"
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

# internal namespaces

resource "kubernetes_namespace" "internal_staging" {
  metadata {
    name = "internal-staging"
    labels = {
      environment = "staging"
      app_type    = "internal"
    }
  }
}

resource "kubernetes_namespace" "internal_production" {
  metadata {
    name = "internal-production"
    labels = {
      environment = "production"
      app_type    = "internal"
    }
  }
}

# external namespaces

resource "kubernetes_namespace" "external_staging" {
  metadata {
    name = "external-staging"
    labels = {
      environment = "staging"
      app_type    = "external"
    }
  }
}

resource "kubernetes_namespace" "external_production" {
  metadata {
    name = "external-production"
    labels = {
      environment = "production"
      app_type    = "external"
    }
  }
}

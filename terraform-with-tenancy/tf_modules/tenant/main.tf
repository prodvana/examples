
terraform {
  backend "gcs" { } # placeholder, injected by the terraform init --backend-config flag

  required_providers {
    prodvana = {
        source = "prodvana/prodvana"
        version = "0.1.20"
    }
    google = {
      source = "hashicorp/google"
      version = "4.77.0"
    }

    kubernetes = {
        source = "hashicorp/kubernetes"
        version = "2.27.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

resource "google_storage_bucket" "tenant_bucket" {
  name          = "tenant-${var.id}"
  location      = "US"
  force_destroy = true
}

data "google_client_config" "default" {}

data "google_container_cluster" "cluster" {
  name     =  var.k8s_cluster_name
  location =  var.region
}

provider "kubernetes" {
  host = data.google_container_cluster.cluster.endpoint
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.cluster.master_auth.0.cluster_ca_certificate)
}

resource "kubernetes_namespace" "tenant_namespace" {
  metadata {
    name = var.id
  }
}

resource "prodvana_release_channel" "rc" {
  name = var.tenant
  application = "photo-stack"

  policy = {
    default_env = {
      "BUCKET_URL" = {
        value = google_storage_bucket.tenant_bucket.url
      }
    }
  }
  manual_approval_preconditions = [
    {
      every_action = true,
    },
  ]
  runtimes = [
    {
      runtime = prodvana_managed_k8s_runtime.runtime
      k8s_namespace = kubernetes_namespace.tenant_namespace.metadata.0.name
    }
  ]
}

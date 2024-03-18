# create a gke cluster
provider "google" {}

provider "prodvana" {}

variable "tenants" {
  type = list(object({
    name = string
    id = string
    project = string
    region = string
  }))
}

resource "google_container_cluster" "cluster" {
  name     = "shared-cluster"
  location = "us-central1"
  initial_node_count = 3
}

resource "prodvana_managed_k8s_runtime" "runtime" {
  name = "shared-runtime"

  host                   = data.google_container_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.google_container_cluster.cluster.master_auth.0.cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}

resource "prodvana_application" "photo_stack" {
    name = "photo-stack"
    runtime = google_container_cluster.cluster
}

resource "prodvana_application" "tenant_terraform" {
    name = "tenant-terraform"
    runtime = google_container_cluster.cluster
}

resource "prodvana_release_channel" "rc" {
    for_each = { for tenant in var.tenants : tenant.id => tenant }

    name = each.value.name
    application = prodvana_application.tenant_terraform

    policy = {
        default_env = {
            "TF_VAR_tenant" = {
                value = each.value.name
            },
            "TF_VAR_id" = {
                value = each.value.id
            },
            "TF_VAR_project" = {
                value = each.value.project
            },
            "TF_VAR_region" = {
                value = each.value.region
            },
            "TF_VAR_k8s_cluster_name" = {
                value = google_container_cluster.cluster.name
            },
            "TF_VAR_pvn_runtime_name" = {
                value = prodvana_managed_k8s_runtime.runtime.name
            },

        }
    }

    manual_approval_preconditions = [
        {
            every_action = true,
        },
    ]

    runtimes = [
        {
            runtime = "terraform-runner"
        }
    ]
}

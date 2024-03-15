# Terraform

These configs show how to create an Application, Service, and Terraform Runner Runtime to run a Terraform Module in Prodvana. The Terraform Runner Runtime uses a Kubernetes Runtime to run the Terraform jobs.

## Prerequisites

- a Kubernetes cluster linked to Prodvana [these docs](https://docs.prodvana.io/docs/link-kubernetes-cluster). Update the `proxyRuntime` field in `runtimes/terraform-runner.pvn.yaml`.
- a Terraform [backend](https://developer.hashicorp.com/terraform/language/settings/backends/configuration) to store state in. Update the `backend` block in `tf_modules/{staging,production}main.tf` with this information.
- A Namespace and Service Account created in the Kubernetes cluster, with permissions to access the state backend. Update the `namespace` and `serviceAccount` fields in `runtimes/terraform-runner.pvn.yaml`. See the documentation for other ways of [passing credentials](prod/prodvana-cont-testing-prod/runtimes/terraform-runner.pvn.yaml).
- A Docker registry you can push container images to. [Add](https://docs.prodvana.io/docs/container-image-registries) this registry to your Prodvana organization. Update the `imageRegistryInfo` values in `applications/terraform/services/infra.pvn.yaml` with the registry details.
- `pvnctl` [installed](https://docs.prodvana.io/docs/pvnctl) and configured

## Setup

1. Build the docker image with the Terraform configuration:

   ```bash
   > cd tf_modules
   > docker build . -t <your_docker_registry>tf:v1 --push
   ```

2. Apply the Prodvana configs:

   ```bash
   # apply the Terraform Runner Runtime config
   > pvnctl config apply runtimes/terraform-runner.pvn.yaml

   # apply the Application config
   > pvnctl config apply applications/terraform/terraform.pvn.yaml

   # apply the Service config
   > pvnctl config apply applications/terraform/services/infra.pvn.yaml
   ```

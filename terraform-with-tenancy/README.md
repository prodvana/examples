# Terraform with Tenancy

This example shows how to setup and configure Prodvana and Terraform to implement single tenancy. In this case, a tenant represents a dedicated set of infrastructure components (created through a Prodvana Terraform Runner) and software Services (deployed through Prodvana) for a single customer.

For this example, we will use a fictitious Photo backup service called Photo Stack. Photo Stack runs a separate instance of it's API and Web services per customer to provide isolation.

## Setup

```text
applications/
├─ main-terraform/
│  ├─ services/
│  │  ├─ setup.pvn.yaml          # runs tf_modules/main
│  ├─ main-terraform.pvn.yaml
├─ photo-stack/
│  ├─ services/                  #  the Photo Stack services
│  │  ├─ api.pvn.yaml
│  │  ├─ web.pvn.yaml
├─ tenant-terraform/
│  ├─ services/
│  │  ├─ setup.pvn.yaml        # runs tf_modules/tenant
runtimes/
├─ terraform-runner.pvn.yaml
tf_modules/
├─ main/                      # creates shared resources and creates Release Channels in `tenant-terraform`
├─ tenant/                    # creates tenant specific resources and creates Release Channels in `photo-stack`
```

The `main-terraform` Prodvana Application defined in `applications/main-terraform.pvn.yaml` is the entrypoint for this setup. It defines a single `production` Release Channel, configured with a single service named `setup` that runs the `tf_modules/main` Terraform module using the Terraform Runner defined in `runtimes/terraform-runner.yaml.`

This `main` Terraform module creates a Kubernetes Cluster where the `photo-stack` tenants will be deployed. It also creates the `photo-stack` Application, which will be used to deploy the `web` and `api` Photo Stack services. This module then creates the `tenant-terraform` Application, and then generates a Release Channel per tenant in it (the tenant list is provided as a Terraform Variable in this example).

The `tenant-terraform` Application has a service named `setup` that is configured to run the `tf_modules/tenant` module. Through the `extraInitArgs` parameter, the Terraform backend config is parameterized with the Release Channel name -- this way each tenant (represented as a Release Channel) has an independent "stack" of Terraform state. Each Release Channel passes along tenant-specific Terraform variables to the module.

The `tenant` Terraform module allocates a dedicated GCS bucket, creates a dedicated namespace in the shared Kubernetes cluster, and then creates a Release Channel in the `photo-stack` Application for this tenant, passing in the bucket's URL as an environment variable.

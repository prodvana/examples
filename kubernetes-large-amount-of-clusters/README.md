# Kubernetes + a Large Amount of Clusters

This example shows how to use Prodvana to manage a large number of clusters.

Consider a product that needs to deploy the same set of Services to every customer-owned environment. Each environment should get the same set of Services with slight variations (e.g. to enable certain features or point at a customer-specific configuration file). Broadly, there are two categories of Runtimes (reminder: Runtimes is Prodvana's abstraction for clusters): staging, which are internal copies used for testing purposes, and production, which are Runtimes in customer-owned environments. Additionally, production Runtimes are further split into three tiers based on the plan the customers are on: startup, teams, and enterprise.

To summarize:

- staging - used for internal testing
- production - customer-facing Runtimes
  - tiers
    - startup
    - teams
    - enterprise

This example uses Kubernetes, but can be adapted to any type of Runtimes. The example also applies to regional deployments or single-tenant SaaS deployments, with minimal changes.

## Managing Multiple Runtimes with Labels

This example uses [labels](https://docs.prodvana.io/docs/labels) to manage Runtimes. Labels allow each Runtime to define its own attributes, independent of how the attribute will be used. Through labels, for example, you can identify which Runtime is staging or prod, and which Runtime is on which tier. You can also make application-level decisions independently, like choosing to deploy an app first to staging, then startup, teams, and enterprise, without making changes to the Runtimes.

## Connecting Runtimes to Prodvana

### IaC

When defining a large number of Runtimes on Prodvana, it is recommended to use IaC tooling like Terraform. Here is an example Terraform code to define a Runtime:

```terraform
resource "prodvana_managed_k8s_runtime" "example" {
  name = "customer-a"

  labels = [
    {
      label = "env"
      value = "production"
    },
    {
      label = "tier"
      value = "startup"
    },
  ]

  host                   = ...
  cluster_ca_certificate = ...
  token                  = ...
}
```

This Terraform resource will connect the Runtime to Prodvana by installing the [Prodvana agent](https://docs.prodvana.io/docs/prodvana-kubernetes-agent) using the provided Kubernetes credentials. The credentials themselves are never passed to Prodvana. Alternative means of providing the credentials are available, see our [Terraform provider docs](https://registry.terraform.io/providers/prodvana/prodvana/latest/docs/resources/managed_k8s_runtime).

### Connecting Manually

If Terraform is not feasible, it is possible to connect the Runtime via the Prodvana UI.

For each Runtime:

1. Go to $org.runprodvana.com -> Runtimes
2. Click on Link and choose Kubernetes
3. Follow on-screen instructions.

Once this is done, create a new configuration file for the Runtime to define the labels:

```yaml
runtime:
  name: name-of-runtime-from-the-ui
  labels:
    - label: env
      value: production
    - label: tier
      value: startup
```

### Emulated Runtimes

If you'd like to try out the example without connecting a Runtime, use the configs under `emulated-runtimes/` which will configure a few emulated Runtimes.

## Defining Applications and Services

There are two Applications defined:

1. staging-prod-tiered - This Application deploys to staging then production in stages based on tiers.
2. staging-prod-custom-namespace - This Application deploys to staging then production and also explicitly specifies the namespace to use, instead of relying on the Prodvana-generated namespace.

All Applications have a basic `nginx` Service defined with examples for how to pass Runtime differences to the Service.

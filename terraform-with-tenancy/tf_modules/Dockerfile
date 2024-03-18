FROM us-docker.pkg.dev/pvn-infra/pvn-public/pvn-wrapper:v0.1 as pvn-wrapper

FROM hashicorp/terraform:1.5 AS base

# copy in the pvn-wrapper binary
COPY --from=pvn-wrapper /pvn-wrapper /bin/pvn-wrapper

# copy your module code into the image
COPY . /terraform

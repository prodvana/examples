variable "name" {
    type = string
    description = "the name of the tenant"
}

variable "id" {
    type = string
    description = "tenant id"
}

variable "project" {
    type = string
    description = "the gcp project"
}

variable "region" {
    type = string
    description = "the gcp region"
}

variable "k8s_cluster_name" {
    type = string
    description = "the name of the k8s cluster where the tenant will be deployed"
}

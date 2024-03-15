terraform {
  backend "s3" {
    bucket = "my-tf-state-bucket" # update this to your bucket name
    key    = "staging-state" # update this to your state file name
    region = "us-east-1" # update this to your region
    dynamodb_table = "tf-lock-table" # update this to your lock table name
  }

  # If you use GCS, uncomment the following block and comment the above block
  # backend "gcs" {
  #   bucket = "my-tf-state-bucket" # update this to your bucket name
  #   prefix = "staging-state" # update this to your state file prefix
  # }

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~>3.6.0"
    }
  }
}

resource "random_string" "staging_random" {
  length = 16
  special = true
  override_special = "/@£$"
}

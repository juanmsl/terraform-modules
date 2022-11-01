variable "region" {}
variable "type" {}
variable "key" {}

data "terraform_remote_state" "remote" {
  backend = "s3"
  config  = {
    skip_metadata_api_check = true
    region                  = var.region
    key                     = "${var.type}/${var.key}.tfstate"
    bucket                  = "spot-beauty-account-terraform-backend"
    profile                 = "spot-beauty"
  }
}

output "outputs" {
  value = data.terraform_remote_state.remote.outputs
}
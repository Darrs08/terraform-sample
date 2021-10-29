# --- root/backend.tf ---

terraform {
  backend "s3" {
    key    = "remote.tfstate"
    region = "us-east-1"
  }
}
